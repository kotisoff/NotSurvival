local Message = require "shared/net/messages/_Message"

local M = Message.new(Message.ids.start_sprinting, { state = "boolean" })

return M;
