local api = require "api";
local hunger = api.survival.hunger;
local Registry = api.registry;
local Effect = require "utility/base_effect";

local Saturation = Effect.new("not_survival:saturation");

Saturation.tick = function(self, pid, level, duration, time_passed)
  hunger.add(pid, 1, 2);
end

Registry:register(Registry.TYPES.EFFECTS, Saturation.identifier, Saturation);
