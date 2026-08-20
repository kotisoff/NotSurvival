local death         = require "shared/player/stats/death"
local logger        = require "shared/core/logger"

local PlayerRespawn = require "shared/net/messages/PlayerRespawn"
---@cast PlayerRespawn neutron.server.messages.Message

PlayerRespawn:on(function(client)
  local pid = client.player.pid;

  if not death.revive(pid) then
    logger:println("W", string.format("Player %s tried to respawn while alive"))
  end
end)
