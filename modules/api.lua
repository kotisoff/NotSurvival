local hunger = require "survival/hunger";
local health = require "survival/health";
local oxygen = require "survival/oxygen";
local experience = require "survival/experience";
local death = require "survival/death_manager";
local effects = require "survival/effects";

local gamemode = require "game/gamemode";
local title = require "game/title";

local registry = require "game/registry";

local movement = require "player/movement_controller";
local sleeping = require "player/sleep_controller";
local variables = require "player/variables";

local not_utils = require "utility/utils";
local ResourceLoader = require "utility/resource_loader";
local Logger = require "utility/logger";
local base_effect = require "survival/base_effect";

PACK_ID = PACK_ID or "not_survival";

local not_survival_api = {
  survival = {
    health = health,
    hunger = hunger,
    oxygen = oxygen,
    experience = experience,
    death = death,
    effects = effects
  },
  game = {
    gamemode = gamemode,
    title = title
  },
  player = {
    movement = movement,
    sleeping = sleeping,
    variables = variables
  },
  utils = {
    utils = not_utils,
    Logger = Logger,
    ResourceLoader = ResourceLoader,
    BaseEffect = base_effect
  },
  registry = registry
};

return not_survival_api;
