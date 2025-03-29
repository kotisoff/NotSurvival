local mp_api = require("mp_api/init")();
local client_storage = require "client/utils/player_data";
local server_storage = require "server/game/player_data";

local module = {};

---Get player data. I.e.: health, hunger, etc.
---@param pid number
---@return PlayerData
function module.get_data(pid)
  if mp_api.server then
    return server_storage.get_data(pid);
  else
    return client_storage.data;
  end
end

---Get player status. I.e.: death, effects
---@param pid number
---@return PlayerStatus
function module.get_status(pid)
  if mp_api.server then
    return server_storage.get_status(pid);
  else
    return client_storage.status;
  end
end

---Get player attributes. I.e. max health, max hunger, etc.
---@param pid number
---@return PlayerAttributes
function module.get_attributes(pid)
  if mp_api.server then
    return server_storage.get_attributes(pid);
  else
    return client_storage.attributes;
  end
end

return module;
