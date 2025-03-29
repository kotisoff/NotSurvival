local resource = require "utils/resource_func";

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
    local pid = hud.get_player();
    local name = player.get_name(pid);
    events.emit(resource(event), { pid = pid, username = name }, ...);
  end,
  on = function(event, callback)
    events.on(resource(event), callback);
  end
}

return module;
