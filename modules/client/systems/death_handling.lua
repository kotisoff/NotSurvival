local net_events      = require "shared/net/utils/net_events"
local data            = require "shared/player/data/manager";
local compression     = require "shared/net/compression/player_data"
local death           = require "shared/player/stats/death";
local experience      = require "shared/player/stats/experience";
local system_instance = require "shared/lib/system_instance"
local ns_events       = require "shared/core/ns_events"

local system          = system_instance.new("ns.system.death_handling")

---@type voxelcore.libinput.bindings[]
local movement_inputs = {
  "movement.forward",
  "movement.back",
  "movement.right",
  "movement.left",
  "movement.jump"
}

local function enable_inputs(flag)
  if type(flag) ~= "boolean" then flag = true end

  for _, bind in pairs(movement_inputs) do
    input.set_enabled(bind, flag)
  end
end

ns_events.on("__set_player_data", function(pid, category, field, value)
  if category == "status" and field == "dead" then
    if value then
      death.show_overlay(experience.get_exp(pid));
    else
      death.close_overlay();
      hud.close_inventory();
    end

    enable_inputs(not value)
    return;
  end
end)

function system:update()
  local dead = death.get()

  if dead and not hud.is_inventory_open() then
    death.show_overlay(experience.get_exp())
  end

  enable_inputs(not dead);
end

return system
