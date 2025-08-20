local mp           = require "shared/utils/not_utils".multiplayer;

local data         = require "shared/player/data_manager";
local module_utils = require "server/lib/util/module_utils"

local health       = require "shared/survival/health";
local experience   = require "shared/survival/experience";
local hunger       = require "shared/survival/hunger";
local oxygen       = require "shared/survival/oxygen";

local base_util    = require "base:util";

---@type ns.categories, ns.statusfield
local cat, field   = "status", "dead";

local module       = {}

-- ========================shared===========================

---@return bool
function module.get(pid)
  if not pid then pid = hud.get_player() end
  return data.get_status(pid).dead
end

-- ========================server===========================

mp.as_server(function(server, mode)
  ---Server side only
  ---@param pid int
  ---@param flag bool
  function module.set(pid, flag)
    data.set_field(pid, cat, field, flag)
    module_utils.update(pid, cat, field, flag)
  end

  ---Server side only
  ---@param pid int
  ---@param damage_type damage_types
  function module.kill(pid, damage_type)
    if data.get_status(pid).gamemode ~= 0 then return end

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

    --TODO: add ns rules.
    local client = server.accounts.get_client_by_name(player.get_name(pid))

    if not true then
      local pos = { player.get_pos(pid) }

      local orbs = math.random(6)
      for _ = 1, orbs do
        ---@type voxelcore.class.entity
        local entity = experience.summon(pos, experience.get_exp(pid) / orbs)

        if mode == "standalone" then
          entity.rigidbody:set_vel(vec3.spherical_rand(4))
        end
      end
      experience.set_xp(pid, 0)

      module.drop_items(pid)
    end
    server.console.tell("You died at " .. table.concat(vec3.round({ player.get_pos(pid) }), " "), client)

    -- Телепорт на спавн
    local x, y, z = player.get_spawnpoint(pid)
    local status = pcall(function()
      server.sandbox.players.sync_states(client.player,
        { pos = { x = x, y = y, z = z }, rot = { yaw = 0, pitch = 0 } })
    end)
    if not status then
      player.set_pos(pid, x, y, z)
      player.set_rot(pid, 0, 0, 0)
      player.set_vel(pid, 0, 0, 0)
    end

    -- Восстановление игрока
    health.full(pid)
    hunger.full(pid)
    oxygen.full(pid)
    -- effects.remove(pid) ну типа потом добавлю лол

    module.set(pid, false)
  end
end)

-- ========================client===========================

mp.as_client(function(client, mode)
  local death_overlay = "not_survival:death"
  local document = Document.new(death_overlay)

  ---Client side only
  ---@param score? int
  function module.show_overlay(score)
    if score then
      document.score.text = string.format("Score: [#FFFF00]%d", score)
    end

    hud.show_overlay(death_overlay, false)
  end

  ---Client side only
  function module.close_overlay()
    hud.close(death_overlay)
  end
end)

return module
