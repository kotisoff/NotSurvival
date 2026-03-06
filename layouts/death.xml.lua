local mp = require "shared/utils/not_utils".multiplayer
local mode = mp.mode
local bson = require "shared/utils/bson"
local net_events = require "shared/network/utils/net_events"

function on_open(invid, x, y, z)
  document.score.pos = {
    (document.death_window.size[1] - document.score.size[1]) / 2,
    40
  }

  document.pause_btn.visible = mode == "standalone"
end

function respawn()
  net_events.client.send(net_events.packets.player_respawn, bson.serialize({}))
end

function pause()
  hud.pause()
end
