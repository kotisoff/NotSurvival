local mp = require "shared/utils/not_utils".multiplayer.api.server
local packets = require "shared/utils/declarations/packets"
local hunger = require "server/lib/hunger"
local system_handlers = require "server/lib/util/system_handlers"

local pack_id = "not_survival"

---@type bool[]
local sprinting = {}

mp.events.on(pack_id, packets.player_sprinting, function(client, bytes)
  local status = unpack(mp.bson.deserialize(bytes))

  sprinting[client.player.pid] = status
end)

system_handlers.set_ticking_event("ns.sprinting", function(pid, tps, sprint)
  is_sprinting = sprinting[pid] or false

  if is_sprinting then
    sprint:add(1)
  end

  if sprint:get(0) > tps * 10 then
    hunger.consume(pid, 1)
    sprint:set(1)
  end
end)
