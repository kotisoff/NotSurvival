local not_utils = require "utility/utils";
local title = require "utility/title";

function on_interact(x, y, z, pid)
  player.set_spawnpoint(x, y, z);

  if world.is_day() then
    title.actionbar:show("Вы можете спать только ночью. Точка возрождения установлена.");
    return true;
  end;

  local prev = { pos = { player.get_pos(pid) }, rot = { player.get_rot(pid) } };

  local function teleport_on_bed()
    player.set_pos(pid, x + 0.5, y, z + 0.5);
    player.set_rot(pid, -90, 90, 0);
  end

  local el = title.document["sleep"];
  not_utils.create_coroutine(function()
    el.hidden = false;
    title.utils.set_opacity("sleep", 0);
    title.actionbar:show("Нажмите movement.crouch для того, чтобы встать с кровати.");

    local status = not_utils.sleep_with_break(4,
      function()
        return input.is_active("movement.crouch")
      end,
      function(data, time)
        teleport_on_bed();
        title.utils.fade_in_cycle("sleep", data, time, 0, 4);
      end
    )

    title.utils.set_opacity("sleep", 0);
    el.hidden = true;

    if status then
      world.set_day_time(0.333);
    end

    player.set_pos(pid, unpack(prev.pos));
    player.set_rot(pid, unpack(prev.rot));
  end)
end
