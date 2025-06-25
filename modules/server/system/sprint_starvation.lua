local mp = require "shared/utils/not_utils".multiplayer.api.server
local packets = require "shared/utils/declarations/packets"
local hunger = require "server/lib/hunger"
local server_utils = require "server/lib/server_utils"

local pack_id = "not_survival"

---@type bool[]
local sprinting = {}

mp.events.on(pack_id, packets.player_sprinting, function(client, bytes)
  local status = unpack(mp.bson.deserialize(bytes))

  sprinting[client.player.pid] = status
end)

local tick = {}
local function add_tick(pid, val)
  tick[pid] = (tick[pid] or 1) + val
end

events.on(server_utils.get_player_event(), function(pid, def_tps)
  local tps = server_utils.tps
  local is_sprinting = sprinting[pid] or false

  if is_sprinting then
    add_tick(pid, 1)
  end

  if (tick[pid] or 1) > (tps * 10) then
    hunger.consume(pid, 1)
    tick[pid] = 1
  end
end)
