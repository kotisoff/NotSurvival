local mp            = require "shared/lib/multiplayer";
local constants     = require "shared/core/constants"
local registry      = require "shared/net/messages/registry"

local messages      = mp.api[mp.side].messages;

local DealKnockback = messages.new(constants.pack_id, registry.deal_knockback, {
  velocity = "Vec3<float32>"
})

return DealKnockback;
