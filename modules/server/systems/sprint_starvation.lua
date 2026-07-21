local mp              = require "shared/utils/not_utils".multiplayer.api.server
local net_events      = require "shared/net/utils/net_events"
local hunger          = require "shared/player/stats/hunger"
local system_instance = require "shared/lib/system_instance"
local Counter         = require "shared/lib/Counter"

-- А это тут нужно чтобы работали приколы типа добавления кастомных полей и методов.
---@class ns.ecs.system.server.sprinting:ns.ecs.system
local SprintingSystem = system_instance.new("ns.system.sprint_starvation")

function SprintingSystem:init()
  ---@type bool[]
  self.sprinting = {};
end

function SprintingSystem:on_player_remove(id)
  Counter.get_or_create(id, self.name):destroy();
end

net_events.server.on(net_events.packets.player_sprinting, function(client, bytes)
  local status = unpack(mp.bson.deserialize(bytes))

  SprintingSystem.sprinting[client.player.pid] = status
end)

function SprintingSystem:update(pid, tps)
  local sprint = Counter.get_or_create(pid, self.name);

  local is_sprinting = self.sprinting[pid] or false

  if is_sprinting then
    sprint:add(1)
  end

  if sprint:get(0) > tps * 10 then
    hunger.consume(pid, 1)
    sprint:set(1)
  end
end

return SprintingSystem;
