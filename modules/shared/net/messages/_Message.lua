local mp        = require "shared/lib/multiplayer";
local constants = require "shared/core/constants"

local Message   = mp.api[mp.side].messages;

---@class ns.net.MessageRegistry
local module    = {};

---@param event string
---@param schema table
function module.new(event, schema)
  return Message.new(constants.pack_id, event, schema);
end

module.ids = {
  player_respawn = "1",
  deal_knockback = "2",
  start_eating = "3",
  start_sprinting = "4"
}

return module;
