local logger     = require "shared/core/logger"
local controller = {
  ---@type ns.ecs.system[]
  systems = {},
  ---@type table<string, (fun(id:int):bool)>
  filters = {}
};

local function filter_entity(id)
  for _, filter in pairs(controller.filters) do
    if not filter(id) then
      return false;
    end
  end

  return true;
end


---@param system ns.ecs.system
function controller:register(system)
  assert(system.init, "System should be instance of system_instance!");

  system:init();
  table.insert(self.systems, system);
  logger:println("I", string.format("Register system: %s", system.name));
end

---@param name str
---@param filter fun(id: int): bool
function controller:register_filter(name, filter)
  assert(type(filter) == "function", "Filter should be function!");

  table.insert(self.filters, filter);
  logger:println("I", string.format("Register high-level filter: %s", name))
end

function controller:update(id, tps)
  for _, system in ipairs(self.systems) do
    if system.enabled and system:should_update(id) and filter_entity(id) then
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
