local hunger = require "survival/hunger";
local health = require "survival/health";
local oxygen = require "survival/oxygen";
local exp = require "survival/exp";

local gamemode = require "player/gamemode";
local movement = require "player/movement_controller";

local variables = require "utility/variables";
local not_utils = require "utility/utils";
local ResourceLoader = require "utility/resource_loader"

PACK_ID = PACK_ID or "not_survival";

local not_survival_api = {
  health = health,
  hunger = hunger,
  oxygen = oxygen,
  exp = exp,

  gamemode = gamemode,
  variables = variables,
  movement = movement,

  utils = not_utils,
  ResourceLoader = ResourceLoader
};

return not_survival_api;
