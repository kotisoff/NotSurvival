local hunger = require("survival/hunger");
local health = require("survival/health");
local oxygen = require("survival/oxygen");
local exp = require("survival/exp");
local gamemode = require("utility/gamemode");
local variables = require("utility/variables");
local movement = require("utility/movement_controller");

local not_survival_api = {
  health = health,
  hunger = hunger,
  oxygen = oxygen,
  exp = exp,
  gamemode = gamemode,
  variables = variables,
  movement = movement
};

return not_survival_api;
