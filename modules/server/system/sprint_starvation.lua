local mp = require "shared/utils/not_utils".multiplayer.api.server
local packets = require "shared/utils/declarations/packets"
local hunger = require "shared/survival/hunger"
local system_handlers = require "server/lib/util/system_handlers"

local constants = require "constants";
local pack_id = constants.pack_id;

---@type bool[]
local sprinting = {}

mp.events.on(pack_id, packets.player_sprinting, function(client, bytes)
  local status = unpack(mp.bson.deserialize(bytes))

  sprinting[client.player.pid] = status
end)

system_handlers.add_ticking_event("ns.sprinting", function(pid, tps, sprint)
  is_sprinting = sprinting[pid] or false

  if is_sprinting then
    sprint:add(1)
  end

  if sprint:get(0) > tps * 10 then
    hunger.consume(pid, 1)
    sprint:set(1)
  end
end)
