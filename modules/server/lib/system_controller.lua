local logger     = require "shared/core/logger"
local controller = {
  ---@type ns.ecs.system[]
  systems = {},
};


---@param system ns.ecs.system
function controller:register(system)
  system:init();
  table.insert(self.systems, system);
  logger:println("I", string.format("Register system: %s", system.name));
end

function controller:update(id, tps)
  for _, system in ipairs(self.systems) do
    if system.enabled and system:should_update(id) then
      system:update(id, tps);
    end;
  end
end

function controller:remove_player(id)
  for _, system in ipairs(self.systems) do
    system:on_player_remove(id);
  end
end

function controller:register_player(id)
  for _, system in ipairs(self.systems) do
    system:on_player_register(id);
  end
end

return controller;
