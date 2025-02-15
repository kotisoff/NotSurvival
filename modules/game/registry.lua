local Logger = require "utility/logger";

local Registry = setmetatable({ logger = Logger.new("not_survival", "registry") }, { __index = {} });

---@enum registry_types
Registry.TYPES = {
  EFFECTS = 1
}

local keys = {};
local Registries = {};
for key, type in pairs(Registry.TYPES) do
  table.insert(keys, key);
  Registries[type] = {};
end

---@param type registry_types
---@param identifier string
---@param object table
---@param overwrite? boolean
function Registry:register(type, identifier, object, overwrite)
  if Registries[type][identifier] then
    Registry.logger:println("ERROR: Registry object with that identifier already exists. " ..
      "Overwrited." and overwrite or "Ignored."
    )
    if not overwrite then return end;
  end

  Registries[type][identifier] = object;
end

---Do not modify if you don't know what you're doing.
---@param type registry_types
---@param identifier string
function Registry:get(type, identifier)
  return Registries[type][identifier];
end

---Do not modify.
---@param type registry_types
function Registry:get_all_of(type)
  return Registries[type];
end

return Registry;
