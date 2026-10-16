local m = _G["$Multiplayer"];
local path = string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron.latest);

---@type neutron.api | table<string, neutron.client | neutron.server>
local api = require(path);

---@class ns.lib.multiplayer
local module = {};

module.side = m.side;
module.api = api;

return module;
