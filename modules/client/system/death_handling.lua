local mp = require "shared/utils/not_utils".multiplayer.api.client;
local packets = require "shared/utils/declarations/packets";
local data = require "shared/player/data_manager";
local compression = require "shared/compression/player_data";
local resource = require "shared/utils/resource_func";
local death = require "shared/survival/death";
local experience = require "shared/survival/experience";
local constants = require "constants";
local pack_id = constants.pack_id;

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

mp.events.on(pack_id, packets.update_player_data, function(bytes)
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

events.on(resource("player_tick"), function()
  if death.get() then
    if not hud.is_inventory_open() then
      death.show_overlay(experience.get_exp())
    end
  end
end)
