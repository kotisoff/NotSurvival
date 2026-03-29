local logger     = require "shared/lib/logger"
local controller = {
  ---@type ns.ecs.system[]
  systems = {},
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
  local id = hud.get_player();

  for _, system in ipairs(self.systems) do
    if system:should_update(id) then
      system:update(id, tps);
    end;
  end
end

function controller:remove_player()
  local id = hud.get_player()

  for _, system in ipairs(self.systems) do
    system:on_player_remove(id);
  end
end

function controller:register_player()
  local id = hud.get_player()

  for _, system in ipairs(self.systems) do
    system:on_player_register(id);
  end
end

return controller;
