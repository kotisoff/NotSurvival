local PACK_ID = "not_survival"; local function resource(name) return PACK_ID .. ":" .. name end

require("utility/variables");
require("utility/gamemode");

local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

local attributes = ARGS.attributes
    or SAVED_DATA.attributes
    or variables.new_player_attributes();

local data = ARGS.data
    or SAVED_DATA.data
    or variables.new_player_data();

local damage_source = ARGS.damage_source
    or variables.new_player_damage();

ARGS.damage_source = damage_source;
ARGS.data = data;
ARGS.attributes = attributes;

function set_player_id(pid)
  ARGS.pid = pid;
end

function on_save()
  SAVED_DATA.data = data;
  SAVED_DATA.attributes = attributes;
end

function on_grounded(velocity)
  if ARGS.pid then
    events.emit(resource("grounded"), ARGS.pid, velocity);
  end
end

local function first_tick()
  gamemode.set_player_mode(ARGS.pid, gamemode.get_player_mode(ARGS.pid));
end

local first_player_tick = true;
events.on(resource("player_tick"), function(pid)
  if pid ~= ARGS.pid then return end;

  if first_player_tick then
    first_player_tick = false;
    first_tick();
  end

  -- Check if player variable out of bounds.
  for key, value in pairs(ARGS.data) do
    if ARGS.attributes[key] and value > ARGS.attributes[key] then
      ARGS.data[key] = ARGS.attributes[key];
    elseif value < 0 then
      ARGS.data[key] = 0;
    end
  end
end)
