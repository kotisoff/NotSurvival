local mp_api = require("mp_api/init")();
local health = require "server/api/health"

mp_api.server.on("player_attacked", function(user, attackerid, playerid, damage)
  local pos = { player.get_pos(playerid) };

  health.damage(playerid, damage, {
    source = pos,
    attacker = attackerid,
    damage_type = "ns.damage.hit",
    do_knockback = true
  });
end)
