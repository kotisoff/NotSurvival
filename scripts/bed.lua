local not_utils = require "utility/utils";
local title = require "utility/title";
local sleeping = require "player/sleeping";

function on_interact(x, y, z, pid)
  player.set_spawnpoint(x, y, z);

  if world.get_day_time() < 0.75 then
    title.actionbar:show("Вы можете спать только ночью. Точка возрождения установлена.");
    return true;
  end;

  sleeping.sleep({ x, y, z }, 0.333, true, 4);
  return true;
end
