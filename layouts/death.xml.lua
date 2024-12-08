function resource(name) return PACK_ID .. ":" .. name end

require("variables");
require("survival/health");
require("survival/hunger");
require("survival/exp");
require("survival/oxygen")

local dead = false;
events.on(resource("world_tick"), function()
  local pid = hud.get_player();

  if health.get(pid) <= 0 and not dead then
    document.reason.text = "Died " .. variables.get_player_damage(pid).type
    dead = true;
    hud.show_overlay(resource("death"));
  end
  if dead and not hud.is_inventory_open() then
    hud.show_overlay(resource("death"))
  end
end)

function drop_items(pid)
  local invid = player.get_inventory(pid);

  if invid then
    local pos = { player.get_pos(pid) }
    local size = inventory.size(invid)
    for i = 0, size - 1 do
      local itemid, count = inventory.get(invid, i)
      if itemid ~= 0 then
        base_util.drop(vec3.add(pos, 0.5), itemid, count).rigidbody:set_vel(vec3.spherical_rand(3))
        inventory.set(invid, i, 0)
      end
    end
  end
end

function respawn()
  local pid = hud.get_player();

  if not rules.get("ns-keep-inventory") then
    local pos = player.get_pos(pid);
    --exp.summon(pos, exp.get_xp(pid));
    --exp.set_xp(pid, 0); xp орбы доделаю позже :P
    drop_items(pid);
    console.log("You died at " .. table.concat(vec3.round({ player.get_pos(pid) }), " "));
  end

  player.set_pos(pid, player.get_spawnpoint(pid))
  player.set_vel(pid, { 0, 0, 0 })
  player.set_rot(pid, { 0, 0, 0 });

  health.full(pid);
  hunger.full(pid);
  oxygen.set(pid, 20);

  dead = false;
  hud.close_inventory();
end

function on_open(invid, x, y, z)
  document.reason.pos = {
    (document.death_window.size[1] - document.reason.size[1]) / 2,
    40
  }
end
