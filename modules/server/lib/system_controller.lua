local controller = {
  ---@type ns.ecs.system[]
  systems = {},
};


---@param system ns.ecs.system
function controller:register(system)
  system:init();
  table.insert(self.systems, system);
end

function controller:update(id, tps)
  for _, system in ipairs(self.systems) do
    if system:should_update(id) then
      system:update(id, tps);
    end;
  end
end

function controller:remove_entity(id)
  for _, system in ipairs(self.systems) do
    system:on_entity_remove(id);
  end
end

function controller:register_entity(id)
  for _, system in ipairs(self.systems) do
    system:on_entity_register(id);
  end
end

--TODO: дописать, привязать к world.lua сервера.
--TODO: UPD: привязать к world.lua сервера.

return controller;
