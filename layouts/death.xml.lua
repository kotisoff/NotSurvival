local mp = require "shared/lib/not_utils".multiplayer
local mode = mp.mode

local PlayerRespawn = require "shared/net/messages/PlayerRespawn"
---@cast PlayerRespawn neutron.client.messages.Message

function on_open(invid, x, y, z)
  document.score.pos = {
    (document.death_window.size[1] - document.score.size[1]) / 2,
    40
  }

  document.pause_btn.visible = mode == "standalone"
end

function respawn()
  PlayerRespawn:send({});
end

function pause()
  hud.pause()
end
