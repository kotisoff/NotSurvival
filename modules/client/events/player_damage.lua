local mp_api = require("mp_api/init")();

local damage_sounds = {
  ["ns.damage.fall"] = {
    "not_survival/damage/fallsmall",
    "not_survival/damage/fallbig1",
    "not_survival/damage/fallbig2"
  },
  ["ns.damage.hit"] = {
    "not_survival/damage/hit1",
    "not_survival/damage/hit2",
    "not_survival/damage/hit3"
  }
}
local default_damage_sound = "ns.damage.hit";

local function random_damage_sound(type)
  local sounds = damage_sounds[type] or damage_sounds[default_damage_sound];
  return sounds[math.random(#sounds)];
end

local function normalize_source(source)
  return vec3.mul(
    vec3.normalize(source),
    vec3.length({ player.get_pos(hud.get_player()) })
  )
end

local function knockback(pid, source, knockback_multiplier)
  source = source or { player.get_pos(pid) };
  knockback_multiplier = knockback_multiplier or 6;

  local player_vel = { player.get_vel(pid) };
  local knockback_vel = vec3.normalize(vec3.sub({ player.get_pos(pid) }, source));

  local vel = vec3.add(player_vel, vec3.mul(knockback_vel, knockback_multiplier));

  player.set_vel(pid, unpack(vel));
end

---@param x number
---@param y number
---@param z number
---@param sound string
---@param volume number | nil
---@param pitch number | nil
---@param channel string | nil
local function play_sound(x, y, z, sound, volume, pitch, channel)
  volume = volume or 1;
  pitch = pitch or 1;
  channel = channel or "regular";

  local upper_block = vec3.add({ player.get_pos(hud.get_player()) }, { 0, 1, 0 });
  if block.get(unpack(upper_block)) == 0 then
    audio.play_sound(sound, x, y, z, volume, pitch, channel)
  else
    audio.play_sound_2d(sound, volume, pitch, channel)
  end
end

---@param playerdamage ns.api.health.DamageSource
---@param sound boolean | { pos: number[], name: string, volume: number, pitch: number, channel: string }
mp_api.client.on("player_damage", function(playerdamage, sound)
  if sound then
    local x, y, z = unpack(normalize_source(playerdamage.source));
    if type(sound) == "boolean" then
      play_sound(x, y, z, random_damage_sound(playerdamage.type));
    elseif type(sound) == "table" then
      x, y, z = unpack(sound.pos);
      play_sound(x, y, z, sound.name, sound.volume, sound.pitch, sound.channel);
    end
  end

  if playerdamage.knockback then
    knockback(hud.get_player(), playerdamage.source, 6);
  end
end)
