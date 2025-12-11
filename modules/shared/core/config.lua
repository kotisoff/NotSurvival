local config = {
  player = {
    base = {
      health = { init = 20, max = 20 },
      hunger = { init = 20, max = 20 },
      saturation = { init = 20, max = 20 },
      oxygen = { init = 20, max = 20 },
      armor = { init = 0, max = 20 }
    },
    combat = {
      punch_damage = 1,
      punch_cooldown = 0.5
    },
    reach = {
      block = 4.5,
      entity = 3
    },
    movement = {
      sneak_speed = 3,
      walk_speed = 4.5,
      run_speed = 6,
      bhop_speed = 7,   -- Не bhop в привычном понимании, а бег в припрыжку.
      jump_height = 1.2 -- Заглушка
    }
  },

  debug = {
    log_events = true
  }
};

return config;
