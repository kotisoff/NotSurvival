local not_utils = require "utility/utils";
local title = require "utility/title";

local sleeping = {};

local sleeping_players = {};
local get_out_key = "movement.crouch";

---@param block_pos number[] Position of bed block.
---@param day_time number When player will wake up.
---@param animate boolean | nil Animate sleep or not.
---@param animation_time number | nil How many seconds will take sleep animation.
function sleeping.sleep(block_pos, day_time, animate, animation_time)
  local pid = hud.get_player();
  if sleeping_players[pid] then return end;

  animate = animate or true;
  animation_time = animation_time or 4;
  local pos = { block.seek_origin(unpack(block_pos)) };
  local sleep_el = title.document["sleep"];

  not_utils.create_coroutine(function()
    sleeping_players[pid] = true;
    local status = true;

    if animate then
      -- Camera positioning

      local cam = cameras.get("not_survival:sleeping");
      local cam_pos = vec3.add(pos, { 0.5, 0.7, 0.5 });
      cam:set_pos(cam_pos);

      local rot = mat4.rotate(
        { 0, 1, 0 },
        block.get_rotation(unpack(pos)) * 90 - 180
      );

      mat4.rotate(rot, { 1, 0, 0 }, 50, rot);

      cam:set_rot(rot);
      cam:set_fov(100);

      player.set_camera(pid, cam:get_index());

      -- Screen fade in setup.

      sleep_el.hidden = false;
      title.utils.set_opacity("sleep", 255);

      local binding = input.get_binding_text(get_out_key);
      title.actionbar:show(
        'Нажмите "' .. binding .. '" для того, чтобы встать с кровати.',
        animation_time,
        function()
          return input.is_active(get_out_key);
        end
      );

      -- Sleeping loop with fade in.

      status = not_utils.sleep_with_break(
        animation_time,
        function()
          return input.is_active(get_out_key);
        end,
        function(data, time)
          -- Fade in
          local fadestep = 255 / (20 * animation_time);
          local opacity = data.opacity or 0;
          opacity = opacity + fadestep;
          title.utils.set_opacity("sleep", math.floor(opacity));
          data.opacity = opacity;
        end
      );

      -- Restore opacity

      sleep_el.hidden = true;
      title.utils.set_opacity("sleep", 0);

      player.set_camera(pid, cameras.index("base:first-person"));
    end;

    if status then
      world.set_day_time(day_time);
    end

    sleeping_players[pid] = false;
  end)
end

-- Reset camera.
events.on("not_survival:hud_open", function()
  local pid = hud.get_player();

  local cam = cameras.get("not_survival:sleeping");
  if cam:get_index() == player.get_camera(pid) then
    player.set_camera(pid, cameras.index("base:first-person"));
  end
end)

return sleeping;
