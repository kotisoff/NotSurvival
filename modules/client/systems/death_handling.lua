local ns_events       = require "shared/core/ns_events"
local net_events      = require "shared/network/utils/net_events"
local data            = require "shared/player/data/manager";
local compression     = require "shared/network/compression/player_data"
local death           = require "shared/player/stats/death";
local experience      = require "shared/player/stats/experience";

---@type voxelcore.libinput.bindings[]
local movement_inputs = {
  "movement.forward",
  "movement.back",
  "movement.right",
  "movement.left",
  "movement.jump"
}

local function block_inputs(flag)
  for _, bind in pairs(movement_inputs) do
    input.set_enabled(bind, not flag)
  end
end

net_events.client.on(net_events.packets.update_player_data, function(bytes)
  local category, field, value = compression.from_bytes(bytes);

  if category ~= "status"
      or not field
      or field ~= "dead"
      or data.get_status(hud.get_player()).gamemode ~= 0
  then
    return
  end

  if value == true then
    death.show_overlay(experience.get_exp())
    block_inputs(true)
  else
    death.close_overlay()
    hud.close_inventory()
    block_inputs(false)
  end
end)

ns_events.on(("player_tick"), function()
  if death.get() then
    if not hud.is_inventory_open() then
      death.show_overlay(experience.get_exp())
    end
  end
end)
