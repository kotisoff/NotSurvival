local mp_api = require("mp_api/init")();
local resource = require "utils/resource_func";
local not_utils = require "utils/not_utils";

local server_storage = require "server/utils/player_data";

---@class ns.sstore.player
---@field data PlayerData
---@field attributes PlayerAttributes
---@field status PlayerStatus
local module = {
  data = server_storage.new_data(),
  attributes = server_storage.new_attributes(),
  status = server_storage.new_status()
};

events.on(resource("hud_open"), function()
  not_utils.coroutines.create(function()
    not_utils.coroutines.set_interval(function()
        for _, value in ipairs({ "data", "attributes", "status" }) do
          mp_api.client.send("get_player_data", value);
        end
      end,
      3)
  end)
end)

-- Update storage from server
mp_api.client.on("get_player_data.cb", function(type, data)
  module[type] = data;
end)

module.new_data = server_storage.new_data;
module.new_attributes = server_storage.new_attributes;
module.new_status = server_storage.new_status;

return module;
