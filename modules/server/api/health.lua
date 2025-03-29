local mp_api = require("mp_api/init")();
local player_data = require "server/utils/player_data";
local vector3 = require "core:vector3";

local health = {};

---@class ns.api.health.DamageSource
local DamageSource = {
  source = { 0, 0, 0 },
  knockback = true,
  type = "ns.damage.nothing",
  amount = 0
}

---@param source number[] | nil
---@param type string | nil
---@param amount number | nil
---@param knockback boolean | nil
---@return ns.api.health.DamageSource
function health.new_damage_source(source, knockback, type, amount)
  return {
    source = source or DamageSource.source,
    type = type or DamageSource.type,
    amount = amount or DamageSource.amount,
    knockback = knockback or DamageSource.knockback
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

  local playerdamage = health.new_damage_source(options.source, options.do_knockback, options.damage_type, damage);
  mp_api.server.send("player_damage", player.get_name(pid), playerdamage, options.sound or true);
end

return health;
