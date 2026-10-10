local Message = require "shared/net/messages/_Message"

---TODO: replace with replica
local M = Message.new(Message.ids.player_data_request, {
	category = "string",
	field = "Nilable<string>"
})

return M;
