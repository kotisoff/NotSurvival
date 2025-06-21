local mp       = require "utils/not_utils".multiplayer.api.server
local packets  = require "utils/packets"
local resource = require "utils/resource_func"

local packid   = "not_survival"

local breaking = {}

mp.events.on(packid, packets.block_breaking, function(client, bytes)
  local pid = client.player.pid
  local status, pos = pcall(mp.bson.deserialize, bytes)
  if status then
    breaking[client]
    mp.blockwraps.wrap(pos, "cracks/cracks_0")
  else
    print(client.player.pid, "кончай ломать блоки сука")
  end
end)

events.on(resource("player_tick"), function(pid, tps)
end)
