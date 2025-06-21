local resource = require "utils/resource_func";
local mp = require "utils/not_utils".multiplayer
local player_data = require "shared/player/data"

local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

if mp.api.server then
  if #SAVED_DATA ~= 3 then
    ARGS = { player_data.new_data(), player_data.new_attributes(), player_data.new_status() }
  else
    ARGS = SAVED_DATA
  end
end;

function on_save()
  if mp.api.server then
    SAVED_DATA = ARGS
  end
end

function on_grounded(velocity)
  if ARGS.pid then
    events.emit(resource("grounded"), ARGS.pid, velocity);
  end
end

function on_attacked(attackerid, pid)
  if mp.api.client then
    events.emit(resource("attacked"), attackerid, pid);
  end
end

-- local function first_tick()
--   gamemode.set_player_mode(ARGS.pid, gamemode.get_player_mode(ARGS.pid));
-- end

-- local first_player_tick = true;
-- events.on(resource("player_tick"), function(pid)
--   if pid ~= ARGS.pid then return end;

--   if first_player_tick then
--     first_player_tick = false;
--     first_tick();
--   end

--   -- Check if player variable out of bounds.
--   for key, value in pairs(ARGS.data) do
--     if type(value) ~= "number" then goto continue end;

--     if ARGS.attributes[key] and value > ARGS.attributes[key] then
--       ARGS.data[key] = ARGS.attributes[key];
--     elseif value < 0 then
--       ARGS.data[key] = 0;
--     end

--     ::continue::
--   end
-- end)
