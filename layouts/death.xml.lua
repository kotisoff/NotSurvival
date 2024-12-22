local death = require "survival/death";

function on_open(invid, x, y, z)
  document.reason.pos = {
    (document.death_window.size[1] - document.reason.size[1]) / 2,
    40
  }
end

function respawn()
  return death.revive(hud.get_player());
end
