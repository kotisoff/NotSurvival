local mp        = require "shared/utils/not_utils".multiplayer;
local logger    = require "shared/core/logger"
local ns_events = require "shared/core/ns_events";
local data      = require "shared/player/data/manager";

local health    = require "shared/player/stats/health";

local base_util = require "base:util";

---@class ns.stat.death
local module    = {}

-- ========================shared===========================

---@return bool
function module.get(pid)
  if not pid then pid = hud.get_player() end
  return data.get_status(pid).dead
end

---@return vec3
function module.get_location(pid)
  if not pid then pid = hud.get_player() end
  return data.get_status(pid).death_location
end

---@return bool
function module.is_invulnerable(pid)
  if not pid then pid = hud.get_player() end;
  return data.get_status(pid).gamemode == 1;
end

-- ========================server===========================

mp.as_server(function(server, mode)
  ---Server side only
  ---@param pid int
  ---@param flag bool
  function module.set(pid, flag)
    data.set(pid, "status", "dead", flag)
  end

  ---Server side only
  ---@param pid int
  ---@param pos vec3
  function module.set_location(pid, pos)
    data.set(pid, "status", "death_location", pos);
  end

  ---Server side only
  ---@param pid int
  ---@param damage_type damage_types
  function module.kill(pid, damage_type)
    if module.is_invulnerable(pid) then return end

    local max = health.get(pid)
    health.damage(pid, max, { damage_type = damage_type, do_knockback = false })
  end

  ---Server side only
  ---@param pid int
  function module.drop_items(pid)
    local inv = player.get_inventory(pid)

    if inv then
      local pos = { player.get_pos(pid) }
      local size = inventory.size(inv)
      for i = 0, size - 1 do
        local itemid, count = inventory.get(inv, i)
        if itemid ~= 0 then
          base_util.drop(vec3.add(pos, 0.5), itemid, count)
          inventory.decrement(inv, i, count)
        end
      end
    end
  end

  ---Server side only
  ---@param pid int
  function module.revive(pid)
    if not module.get(pid) then return end

    local identity = server.sandbox.players.get_by_pid(pid).identity;
    local client = server.accounts.by_identity.get_client(identity);

    local death_pos = module.get_location(pid);
    local death_pos_str = table.concat(vec3.round(death_pos), " ");

    server.console.tell("You died at " .. death_pos_str, client)
    logger:println(
      "I",
      string.format(
        "%s died at %s",
        client.player.username,
        death_pos_str
      )
    )

    -- Телепорт на спавн
    local x, y, z = player.get_spawnpoint(pid)

    player.set_pos(pid, x, y, z)
    player.set_rot(pid, 0, 0, 0)
    player.set_vel(pid, 0, 0, 0)

    -- Восстановление игрока
    ns_events.emit("player_revived", pid);

    module.set(pid, false)
  end
end)

return module
