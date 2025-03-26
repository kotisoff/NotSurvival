local resource = require "utility/resource_func";

---@type ns.api.mp
local module = {
  mode = "standalone",
  valid = true
};

module.server = {
  send = function(event, _, ...)
    events.emit(resource(event), ...);
  end,
  on = function(event, callback)
    events.on(resource(event), callback);
  end,
  echo = function(event, ...)
    events.emit(resource(event), ...);
  end
};

module.client = {
  send = function(event, ...)
    events.emit(resource(event), player.get_name(hud.get_player()), ...);
  end,
  on = function(event, callback)
    events.on(resource(event), callback);
  end
}

return module;
