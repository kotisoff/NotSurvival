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

---@param type string
---@return string
local function random_damage_sound(type)
  local sounds = damage_sounds[type] or damage_sounds[default_damage_sound];
  return sounds[math.random(#sounds)];
end

---@param source number[]
---@return number[]
local function normalize_source(source)
  return vec3.mul(
    vec3.normalize(source),
    vec3.length({ player.get_pos(hud.get_player()) })
  )
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

return {
  random_damage_sound = random_damage_sound,
  normalize_source = normalize_source,
  play_sound = play_sound
};
