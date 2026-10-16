local BlockDestruction = require "shared/net/predicted_events/BlockDestruction";
---@cast BlockDestruction neutron.client.predicted_events.PredictedEvent

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
      instance = BlockDestruction:start({ pos = { x, y, z }, block = blockid, pid = pid });
    end
  elseif instance and instance.active then
    instance:interrupt();
  end
end)
