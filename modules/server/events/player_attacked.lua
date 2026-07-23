local health     = require "shared/player/stats/health"
local ns_events  = require "shared/core/ns_events"
local config     = require "shared/core/config"
local combat     = require "server/systems/combat"
local item_props = require "shared/api/v1/item_props"

local function damage_multiplier(cooldown)
  local n1 = config.player.combat.min_cooldown;
  local n2 = 1 - n1;

  return n1 + n2 * (cooldown ^ 2);
end

ns_events.on("player_attacked", function(victim_pid, attacker_pid, attacker_eid)
  ---@type vec3
  local attacker_pos;

  if attacker_pid then
    attacker_pos = { player.get_pos(attacker_pid) };               -- По идее быстрее
  else
    attacker_pos = entities.get(attacker_eid).transform:get_pos(); -- По идее медленнее
  end

  if not attacker_pos then return end; -- Ну по идее оно никогда сюда не дойдёт, но чёрт его знает.

  local victim_pos = { player.get_pos(victim_pid) };
  local distance = vec3.distance(attacker_pos, victim_pos);

  if distance > config.player.reach.entity then
    return;
  end

  local damage = 1;

  if attacker_pid then
    local itemid = inventory.get(player.get_inventory(attacker_pid));
    local weapon = item_props.get_weapon(itemid);
    local cooldown = combat:consume_cooldown(attacker_pid);

    damage = damage_multiplier(cooldown) * weapon.damage;
  end

  health.damage(victim_pid, damage,
    { damage_type = "ns.damage.hit", source = vec3.sub(attacker_pos, { 0, 1, 0 }), attacker = attacker_eid })
end)
