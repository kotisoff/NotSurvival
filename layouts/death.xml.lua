local PlayerRespawn = require "shared/net/messages/PlayerRespawn"
---@cast PlayerRespawn neutron.client.messages.Message

function on_open(invid, x, y, z)
  document.score.pos = {
    (document.death_window.size[1] - document.score.size[1]) / 2,
    40
  }

  -- TODO: dead code. maybe reactivate with MicroN
  document.pause_btn.visible = false; -- mp.side == "standalone"
end

function respawn()
  PlayerRespawn:send({});
end

function pause()
  hud.pause()
end
