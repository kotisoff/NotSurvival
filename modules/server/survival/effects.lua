local Registry = require "game/registry";
local variables = require "player/variables";

local logger = require("utility/logger").new("not_survival", "Effects")
local EFFECTSTYPE = Registry.TYPES.EFFECTS;

local effects = {};

---@param pid number
---@param identifier string
---@param level? number Default: 1
---@param duration? number Default: 30
---@param log? boolean Default: true
function effects.give(pid, identifier, level, duration, log)
  ---@type Effect
  local effect = Registry:get(EFFECTSTYPE, identifier);
  if not effect then
    logger:println("Effect \"" .. identifier .. "\" not found!");
    return false;
  end

  effect:apply(pid, level or 1, duration or 30);
  if log or true then
    console.log(
      "Effect **" .. identifier .. "** (x"
      .. level .. ") applied to " .. player.get_name(pid)
      .. " for " .. duration .. " seconds."
    )
  end
  return true;
end

---@param pid number
---@param identifier? string If empty will remove all.
---@param log? boolean Default: true
function effects.remove(pid, identifier, log)
  ---@type Effect[]
  local Effects = {}

  local status = { { identifier = identifier } }
  if not identifier then
    status = variables.get_player_status(pid).effects;
  end

  for _, value in ipairs(status) do
    local effect = Registry:get(EFFECTSTYPE, value.identifier);
    if not effect then
      logger:println("Effect \"" .. value.identifier .. "\" not found!");
      goto continue
    end
    table.insert(Effects, effect);
    ::continue::
  end

  for _, effect in ipairs(Effects) do
    effect:remove(pid);
    if log or true then
      console.log(
        "Effect **" .. effect.identifier .. "** removed from " .. player.get_name(pid)
      )
    end
  end
end

return effects;
