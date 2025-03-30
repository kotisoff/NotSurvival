local mp_api = require("mp_api/init")();
local sounds = require "client/utils/sounds";

local function knockback(pid, source, knockback_multiplier)
  source = source or { player.get_pos(pid) };
  knockback_multiplier = knockback_multiplier or 6;

  local player_vel = { player.get_vel(pid) };
  local knockback_vel = vec3.normalize(vec3.sub({ player.get_pos(pid) }, source));

  local vel = vec3.add(player_vel, vec3.mul(knockback_vel, knockback_multiplier));

  player.set_vel(pid, unpack(vel));
end

---@param playerdamage ns.api.health.DamageSource
---@param sound boolean | { pos: number[], name: string, volume: number, pitch: number, channel: string }
mp_api.client.on("player_damage", function(playerdamage, sound)
  if sound then
    local x, y, z = unpack(sounds.normalize_source(playerdamage.source));
    if type(sound) == "boolean" then
      sounds.play_sound(x, y, z, sounds.random_damage_sound(playerdamage.type));
    elseif type(sound) == "table" then
      x, y, z = unpack(sound.pos);
      sounds.play_sound(x, y, z, sound.name, sound.volume, sound.pitch, sound.channel);
    end
  end

  if playerdamage.knockback then
    knockback(hud.get_player(), playerdamage.source, 6);
  end
end)
