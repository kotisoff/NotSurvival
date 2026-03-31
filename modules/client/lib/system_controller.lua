local logger     = require "shared/core/logger"
local controller = {
  ---@type ns.ecs.system[]
  systems = {},
  pid = 0,
};


---@param system ns.ecs.system
function controller:register(system)
  if not system.init then
    logger:println("W", "System init failed: not system.");
    return;
  end
  system:init();
  table.insert(self.systems, system);
  logger:println("I", string.format("Register system: %s", system.name));
end

function controller:update(tps)
  for _, system in ipairs(self.systems) do
    if system:should_update(self.pid) then
      system:update(self.pid, tps);
    end;
  end
end

function controller:remove_player()
  for _, system in ipairs(self.systems) do
    system:on_player_remove(self.pid);
  end
end

function controller:register_player()
  self.pid = hud.get_player()

  for _, system in ipairs(self.systems) do
    system:on_player_register(self.pid);
  end
end

return controller;
