local ns_events     = require "shared/core/ns_events";
local hand_animator = require "client/systems/hand_animator";
local config        = require "shared/core/config"

ns_events.on("hud_open", function()
  input.add_callback("player.destroy", function()
    local pid = hud.get_player();
    local itemid = inventory.get(player.get_inventory(pid))

    local props = item.properties[itemid] or {};
    local damage_props = props[config.properties.weapon];

    if damage_props and table.has(damage_props.type, "melee") then
      hand_animator:reset_hit(true);
    end
  end)
end)
