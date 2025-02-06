local variables = require "player/variables";

local health = {};

local hit_sounds = {
  "not_survival/damage/hit1",
  "not_survival/damage/hit2",
  "not_survival/damage/hit3",
}

function health.get(pid)
  return variables.get_player_data(pid).health;
end

function health.get_max(pid)
  return variables.get_player_attributes(pid).health;
end

-- Heal player to his max.
function health.full(pid)
  health.set(pid, variables.get_player_attributes(pid).health);
end

function health.heal(pid, amount)
  if not amount then
    amount = 1
  end

  local hp = health.get(pid);
  health.set(pid, hp + amount);
end

function health.set(pid, amount)
  local max = health.get_max(pid);
  ---@diagnostic disable-next-line: undefined-field
  variables.get_player_data(pid).health = math.clamp(amount, 0, max);
end

---Damage player
---@param pid number Player id
---@param damage number Damage amount
---@param damage_type string | nil Damage type
---@param source number[] | nil Position of damage source.
---@param do_knockback boolean | nil Knockback player or not.
---@param playsound string | boolean | nil Damage sound name or boolean.
function health.damage(pid, damage, damage_type, source, do_knockback, playsound)
  source = source or { player.get_pos(pid) };
  playsound = playsound or true;

  if type(playsound) == "boolean" and playsound then
    playsound = hit_sounds[math.random(#hit_sounds)]
  end

  health.heal(pid, -damage);

  if playsound then
    local sound_source = vec3.mul(
      vec3.normalize(source),
      vec3.length({ player.get_pos(pid) })
    )

    local x, y, z = unpack(sound_source);

    local upper_block = vec3.add({ player.get_pos(pid) }, { 0, 1, 0 });
    if block.get(unpack(upper_block)) == 0 then
      audio.play_sound(playsound, x, y, z, 1.0, 1.0, "regular")
    else
      audio.play_sound_2d(playsound, 1.0, 1.0, "regular")
    end
  end

  local playerdamage = variables.get_player_damage(pid)
  playerdamage.amount = damage;
  playerdamage.type = damage_type or playerdamage.type;
  playerdamage.source = source;

  if do_knockback then
    if vec3.tostring(source) == vec3.tostring({ 0, 0, 0 }) then return end;

    health.knockback(pid, source, 6);
  end
end

function health.knockback(pid, source, knockback_multiplier)
  local playerdamage = variables.get_player_damage(pid);
  source = source or playerdamage.source;
  knockback_multiplier = knockback_multiplier or 6;

  local player_vel = { player.get_vel(pid) };
  local knockback_vel = vec3.normalize(vec3.sub({ player.get_pos(pid) }, source));

  local vel = vec3.add(player_vel, vec3.mul(knockback_vel, knockback_multiplier));
  local kx, ky, kz = unpack(vel);

  player.set_vel(pid, kx, ky, kz);
end

return health;
