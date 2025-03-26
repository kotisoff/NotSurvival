---@class ns.api.mp.client
---@field send fun(event: string, ...: any) Emit event. No callback.
---@field on fun(event: string, callback: fun(...: any)) Catch event.

---@class ns.api.mp.server
---@field send fun(event: string, player: string, ...: any) Emit event to selected player.
---@field echo fun(event: string, ...: any) Emit event to everyone. No callback.
---@field on fun(event: string, callback: fun(player: string, ...: any)) Catch event.

---@class ns.api.mp
---@field mode "standalone" | "server" | "client"
---@field valid boolean
---@field client? ns.api.mp.client Available if mode = client/standalone
---@field server? ns.api.mp.server Available if mode = server/standalone

local apis = {
  "apis/VoxelOnline"
}

table.insert(apis, "standalone");

---@type ns.api.mp
local api = nil;

---@return ns.api.mp
local get_mp = function()
  if api then return api end;

  for _, value in ipairs(apis) do
    ---@type ns.api.mp
    local temp = require("mp_api/" .. value);
    if temp.valid then
      api = temp;
      break;
    end
  end

  return api;
end

return get_mp;
