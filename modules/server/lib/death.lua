local _mp          = require "shared/utils/not_utils".multiplayer;
local mode         = _mp.mode;
local mp           = _mp.api.server;

local data         = require "shared/player/data_manager";
local module_utils = require "server/lib/util/module_utils"

local health       = require "server/lib/health";
local experience   = require "server/lib/experience";
local hunger       = require "server/lib/hunger";
local oxygen       = require "server/lib/oxygen";

local base_util    = require "base:util";

---@type ns.categories, ns.statusfield
local cat, field   = "status", "dead";

local module       = {}

---@return bool
function module.get(pid)
  return data.get_status(pid).dead
end

---@param pid int
---@param flag bool
function module.set(pid, flag)
  data.set_field(pid, cat, field, flag)
  module_utils.update(pid, cat, field, flag)
end

---@param pid int
---@param damage_type damage_types
function module.kill(pid, damage_type)
  if data.get_status(pid).gamemode ~= 0 then return end

  local max = health.get(pid)
  health.damage(pid, max, { damage_type = damage_type, do_knockback = false })
end

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

function module.revive(pid)
  if not module.get(pid) then return end

  --TODO: add ns rules.
  local client = mp.accounts.get_client_by_name(player.get_name(pid))

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
  mp.console.tell("You died at " .. table.concat(vec3.round({ player.get_pos(pid) }), " "), client)

  -- Телепорт на спавн
  local x, y, z = player.get_spawnpoint(pid)
  local status = pcall(function()
    mp.sandbox.players.sync_states(client.player,
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

return module
