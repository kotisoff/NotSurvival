local hunger = require "survival/hunger";
local health = require "survival/health";
local oxygen = require "survival/oxygen";
local exp = require "survival/exp";
local death = require "survival/death";

local gamemode = require "player/gamemode";
local movement = require "player/movement_controller";

local variables = require "utility/variables";
local not_utils = require "utility/utils";
local title = require "utility/title";
local ResourceLoader = require "utility/resource_loader"

PACK_ID = PACK_ID or "not_survival";

local not_survival_api = {
  health = health,
  hunger = hunger,
  oxygen = oxygen,
  exp = exp,
  death = death,

  gamemode = gamemode,
  movement = movement,
  variables = variables,

  title = title,
  utils = not_utils,
  ResourceLoader = ResourceLoader
};

return not_survival_api;
