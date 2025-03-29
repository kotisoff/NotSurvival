local mp_api = require("mp_api/init")();
local player_data = require "server/utils/player_data";
local vector3 = require "core:vector3";

local health = {};

---@class ns.api.health.DamageSource
local DamageSource = {
  source = { 0, 0, 0 },
  knockback = true,
  type = "ns.damage.nothing",
  attacker = nil,
  amount = 0
}

---@param options? ns.api.health.DamageSource
---@return ns.api.health.DamageSource
function health.new_damage_source(options)
  options = options or {};
  return {
    source = options.source or DamageSource.source,
    type = options.type or DamageSource.type,
    attacker = options.attacker or DamageSource.attacker,
    amount = options.amount or DamageSource.amount,
    knockback = options.knockback or DamageSource.knockback
  }
end

function health.get(pid)
  return player_data.get_data(pid).health;
end

function health.get_max(pid)
  return player_data.get_attributes(pid).health;
end

function health.set(pid, amount)
  local max = health.get_max(pid);

  local data = player_data.get_data(pid);
  ---@diagnostic disable-next-line: undefined-field
  data.health = math.clamp(amount, 0, max);
  mp_api.server.send("set_player_data", player.get_name(pid), data.health, "data", "health");
end

-- Heal player to his max.
function health.full(pid)
  health.set(pid, health.get_max(pid));
end

function health.heal(pid, amount)
  local hp = health.get(pid);
  health.set(pid, hp + (amount or 1));
end

---@class ns.api.health.damage_options
---@field damage_type? string
---@field source? number[] Position of damage source.
---@field attacker? number
---@field do_knockback? boolean Knockback player.
---@field sound? boolean | { pos: number[], name: string, volume: number, pitch: number, channel: string } Sound name, sound options or boolean.

---Damage player
---@param pid number Player id
---@param damage number Damage amount
---@param options? ns.api.health.damage_options
function health.damage(pid, damage, options)
  health.heal(pid, -damage);

  options = options or {};
  options.source = options.source or { player.get_pos(pid) };
  options.do_knockback = vector3(unpack(options.source)) ~= vector3(0, 0, 0) and options.do_knockback
  local playerdamage = health.new_damage_source({
    source = options.source,
    knockback = options.do_knockback,
    type = options.damage_type,
    amount = damage,
    attacker = options.attacker
  });
  mp_api.server.send("player_damage", player.get_name(pid), playerdamage, options.sound or true);
end

return health;
