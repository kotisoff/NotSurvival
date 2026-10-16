local BlockDestruction        = require "shared/net/predicted_events/BlockDestruction";
local InstantBlockDestruction = require "shared/net/messages/InstantBlockDestruction"
local destruction             = require "shared/lib/destruction"
local camera_position         = require "shared/utils/camera_position"

---@cast BlockDestruction neutron.server.predicted_events.PredictedEvent
---@cast InstantBlockDestruction neutron.server.messages.Message

local RAYCAST_VERIFY          = true;

local function raycast(client)
  local pid = client.player.pid;
  local pos = camera_position.by_client(client)

  return block.raycast(pos, player.get_dir(pid), player.get_interaction_distance(pid));
end

---@param client neutron.class.client
---@param data { pos: vec3, block: int, states: int }
InstantBlockDestruction:on(function(client, data)
  local x, y, z = unpack(data.pos);
  if block.get(x, y, z) ~= data.block then return end;

  if RAYCAST_VERIFY then
    local ray = raycast(client);
    if not ray or not vec3.equals(ray.iendpoint, data.pos) then
      return
    end
  end

  if destruction.get_durability(data.block) <= 0 then
    destruction.break_block(x, y, z, data.block, client.player.pid);
  else
    local states = block.get_states(x, y, z);
    data.states = states;

    InstantBlockDestruction:tell(client, data);
  end
end)
