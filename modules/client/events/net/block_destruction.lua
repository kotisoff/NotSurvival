local BlockDestruction        = require "shared/net/predicted_events/BlockDestruction";
local destruction             = require "shared/lib/destruction"
local InstantBlockDestruction = require "shared/net/messages/InstantBlockDestruction"

---@cast BlockDestruction neutron.client.predicted_events.PredictedEvent
---@cast InstantBlockDestruction neutron.client.messages.Message

---@type ns.net.PredictedEvent.BlockDestruction.client.Instance | neutron.client.predicted_events.Instance | nil
local instance

ns_events.on("player_tick", function(pid, tps)
  if hud.get_player() ~= pid then return end;
  if player.is_instant_destruction(pid) then return end;

  if input.is_active("player.destroy") and not hud.is_inventory_open() and not hud.is_paused() then
    local x, y, z = player.get_selected_block(pid);

    if instance and instance.active then
      if block.get(x, y, z) ~= instance.data.block or not vec3.equals({ x, y, z }, instance.data.pos) then
        instance:interrupt();
        return;
      end
    elseif x ~= nil then
      local blockid = block.get(x, y, z);

      local data = {
        pos = { x, y, z },
        block = blockid
      }

      if destruction.get_durability(blockid) <= 0 then
        InstantBlockDestruction:send(data)
      else
        data.pid = pid;
        instance = BlockDestruction:start(data);
      end
    end
  elseif instance and instance.active then
    instance:interrupt();
  end
end)

---@param data { pos: vec3, block: int, states: int }
InstantBlockDestruction:on(function(data)
  local x, y, z = unpack(data.pos);
  block.set(x, y, z, data.block, data.states, true);
end)
