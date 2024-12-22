local PACK_ID = PACK_ID or "not_survival"; local function resource(name) return PACK_ID .. ":" .. name end;

local variables = require "utility/variables";
local health = require "survival/health";
local hunger = require "survival/hunger";
local oxygen = require "survival/oxygen";
local exp = require "survival/exp";
local base_util = require "base:util";

local death = {};

---Kill player.
---@param pid number
---@param reason string | nil I.g.: "by bee" or "in void"
death.kill = function(pid, reason)
  reason = reason or "in void";
  local maxhp = variables.get_player_attributes(pid).health;
  health.damage(pid, maxhp, reason);
end

---Drop every item from player inventory
---@param pid number
death.drop_items = function(pid)
  local invid = player.get_inventory(pid);

  if invid then
    local pos = { player.get_pos(pid) }
    local size = inventory.size(invid)
    for i = 0, size - 1 do
      local itemid, count = inventory.get(invid, i)
      if itemid ~= 0 then
        base_util.drop(vec3.add(pos, 0.5), itemid, count).rigidbody:set_vel(vec3.spherical_rand(3))
        inventory.set(invid, i, 0)
      end
    end
  end
end

death.revive = function(pid)
  local status = variables.get_player_status(pid);

  if not status.dead then return end;

  if not rules.get("ns-keep-inventory") then
    local pos = { player.get_pos(pid) };

    local orbs = math.random(6);
    for _ = 1, orbs do
      exp.summon(pos, exp.get_xp(pid) / orbs)
          .rigidbody:set_vel(vec3.spherical_rand(4));
    end
    exp.set_xp(pid, 0);

    death.drop_items(pid);
    console.log("You died at " .. table.concat(vec3.round({ player.get_pos(pid) }), " "));
  end

  player.set_pos(pid, player.get_spawnpoint(pid))
  player.set_vel(pid, { 0, 0, 0 })
  player.set_rot(pid, { 0, 0, 0 });

  health.full(pid);
  hunger.full(pid);
  oxygen.set(pid, 20);

  status.dead = false;
  hud.close_inventory();
end

return death;
