local Message = require "shared/net/messages/_Message"

local M = Message.new(Message.ids.deal_knockback, {
  velocity = "Vec3<float32>"
})

return M;
