require("survival/hunger");
require("survival/health");
require("survival/oxygen");
require("survival/exp");
require("gamemode");
require("variables");
require("movement_controller");

not_survival_api = {
  health = health,
  hunger = hunger,
  oxygen = oxygen,
  exp = exp,
  gamemode = gamemode,
  variables = variables,
  movement = movement
};

return not_survival_api;
