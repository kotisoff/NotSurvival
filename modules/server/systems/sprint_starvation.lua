local hunger          = require "shared/player/stats/hunger"
local system_instance = require "shared/lib/system_instance"
local Counter         = require "shared/lib/Counter"

local StartSprinting  = require "shared/net/messages/StartSprinting";
---@cast StartSprinting neutron.server.messages.Message

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

StartSprinting:on(function(client, data)
  local status = data.state;
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
