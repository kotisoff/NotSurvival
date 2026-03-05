local mp               = require "shared/utils/not_utils".multiplayer.api.server
local packets          = require "shared/utils/declarations/packets"
local hunger           = require "shared/survival/hunger"
local system_instance  = require "shared/lib/system_instance"
local Counter          = require "shared/lib/Counter"

local constants        = require "constants";
local pack_id          = constants.pack_id;

local Sprinting_system = system_instance.new("ns.system.sprint_starvation")

function Sprinting_system:init()
  ---@type bool[]
  self.sprinting = {};
end

function Sprinting_system:on_entity_remove(id)
  Counter.get_or_create(id, self.name):destroy();
end

mp.events.on(pack_id, packets.player_sprinting, function(client, bytes)
  local status = unpack(mp.bson.deserialize(bytes))

  Sprinting_system.sprinting[client.player.pid] = status
end)

function Sprinting_system:update(pid, tps)
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

return Sprinting_system;
