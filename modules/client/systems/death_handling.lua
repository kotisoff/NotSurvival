local death           = require "shared/player/stats/death";
local experience      = require "shared/player/stats/experience";
local system_instance = require "shared/lib/system_instance"
local ns_events       = require "shared/core/ns_events"

local system          = system_instance.new("ns.system.death_handling")

local death_overlay   = "not_survival:death";

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

local _doc;
local function req_doc()
  if not _doc then
    _doc = Document.new(death_overlay);
  end
  return _doc;
end

local function show_overlay(score)
  if score then
    local document = req_doc();
    document.score.text = string.format("Score: [#FFFF00]%d", score);
  end

  hud.show_overlay(death_overlay, false);
end

local function close_overlay()
  hud.close(death_overlay);
end

ns_events.on("__set_player_data", function(pid, category, field, value)
  if category == "status" and field == "dead" then
    if value then
      show_overlay(experience.get(pid));
    else
      close_overlay();
      hud.close_inventory();
    end

    enable_inputs(not value)
    return;
  end
end)

function system:update()
  local dead = death.get()

  if dead and not hud.is_inventory_open() then
    show_overlay(experience.get())
  end

  enable_inputs(not dead);
end

return system
