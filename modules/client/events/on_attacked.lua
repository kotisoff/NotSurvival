local resource = require "utils/resource_func"
local mp_api = require("mp_api/init")();
local sounds = require "client/utils/sounds";

local basic_player_damage = 1;

events.on(resource("attacked"), function(attackerid, playerid)
  local source = { player.get_pos(playerid) };
  local x, y, z = unpack(sounds.normalize_source(source));

  sounds.play_sound(x, y, z, sounds.random_damage_sound("ns.damage.hit"));

  mp_api.client.send("player_attacked", attackerid, playerid, basic_player_damage);
end)
