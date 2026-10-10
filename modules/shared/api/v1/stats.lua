local death = require "shared/player/stats/death"
local health = require "shared/player/stats/health"
local hunger = require "shared/player/stats/hunger"
local oxygen = require "shared/player/stats/oxygen"
local experience = require "shared/player/stats/experience"

local module = {};

module.death = death;
module.health = health;
module.hunger = hunger;
module.oxygen = oxygen;
module.experience = experience;

return module;
