local mp = require "shared/utils/not_utils".multiplayer.api.client
local packets = require "shared/utils/declarations/packets"
local data = require "shared/player/data"
local resource = require "shared/utils/resource_func"
local death = require "client/lib/death"
local experience = require "client/lib/experience"
local pack_id = "not_survival"

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
  ---@type [int, int, bool]
  local args = mp.bson.deserialize(bytes)
  local c, f, d = unpack(args)

  if f == 0 then return end

  local cat = data.Categories[c]
  ---@type ns.statusfield | ns.attributefield | str
  local field = data.CategoryFields[cat][f]

  if field ~= "dead" or data.get_status(hud.get_player(), "gamemode") ~= 0 then return end

  if d then
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
    if not hud.is_paused() then
      death.show_overlay(experience.get_exp())
    end
  end
end)
