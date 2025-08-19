local _mp = require "shared/utils/not_utils".multiplayer
local mode = _mp.mode
local mp = _mp.api.client

local packets = require "shared/utils/declarations/packets"
local constants = require "constants";
local pack_id = constants.pack_id;

function on_open(invid, x, y, z)
  document.score.pos = {
    (document.death_window.size[1] - document.score.size[1]) / 2,
    40
  }

  document.pause_btn.visible = mode == "standalone"
end

function respawn()
  mp.events.send(pack_id, packets.player_respawn, mp.bson.serialize({}))
end

function pause()
  hud.pause()
end
