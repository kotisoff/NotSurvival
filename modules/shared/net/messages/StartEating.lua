local Message = require "shared/net/messages/_Message"

local M = Message.new(Message.ids.start_eating, { state = "boolean" })

return M;
