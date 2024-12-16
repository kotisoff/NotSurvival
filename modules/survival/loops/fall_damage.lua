local health = require("survival/health");
local variables = require("utility/variables");

local gravity = 22.18;

local fall_damage_sounds = {
  "not_survival/damage/fallsmall",
  "not_survival/damage/fallbig1",
  "not_survival/damage/fallbig2"
}

-- Fall damage.
events.on(resource("grounded"), function(pid, velocity)
  if variables.get_player_data(pid).gamemode ~= 0 then return end

  local x, y, z = player.get_pos(pid);

  local water = block.index("base:water");
  if block.get(x, y, z) == water then
    if block.get(x, y + 1, z) ~= water then
      audio.play_sound("not_survival/random/splash",
        x, y - 0.5, z, 0.8, math.rand(0.9, 1.2), "regular"
      )
    end;

    return;
  end;

  local fall_distance = (velocity ^ 2) / (2 * gravity);

  local damage = math.floor(fall_distance) - 3;
  if damage <= 0 then return end;

  audio.play_sound(fall_damage_sounds[math.random(#fall_damage_sounds)],
    x, y - 0.5, z, 0.8, math.rand(0.8, 1.2), "regular"
  )

  health.damage(
    pid,
    damage,
    "from falling",
    nil,
    nil,
    false
  );
end)
