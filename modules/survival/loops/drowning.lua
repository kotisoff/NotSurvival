local api = require "api";
local oxygen = api.oxygen;
local health = api.health;

local drowning_sounds = {
  "not_survival/entity/player/hurt/drown1",
  "not_survival/entity/player/hurt/drown2",
  "not_survival/entity/player/hurt/drown3",
  "not_survival/entity/player/hurt/drown4"
}

local function is_under_block(pid)
  local x, y, z = player.get_pos(pid);
  local blockid = block.get(x, y + 1, z);
  return blockid ~= 0, blockid;
end

local underwater_ticks = {};
local function add_underw(pid, val)
  underwater_ticks[pid] = (underwater_ticks[pid] or 1) + (val or 0)
end

local regen_ticks = {};
local function add_regen(pid, val)
  regen_ticks[pid] = (regen_ticks[pid] or 1) + (val or 0)
end

local second = 60;
events.on(resource("player_tick"), function(pid, tps)
  local state_under_block, blockid = is_under_block(pid);
  local water = block.index("base:water");

  local is_under_water = state_under_block and blockid == water;

  if is_under_water then
    add_underw(pid, 1);
  else
    underwater_ticks[pid] = 1;
  end

  if underwater_ticks[pid] % second == 0 and is_under_water then
    oxygen.sub(pid, 1);
    if oxygen.get(pid) <= 0 then
      health.damage(0, 2, "from drowning",
        nil, nil,
        drowning_sounds[math.random(#drowning_sounds)]
      );
    end
  end

  if oxygen.get(pid) < oxygen.get_max(pid) and not is_under_water then
    add_regen(pid, 1);
    if regen_ticks[pid] % (second / 2) == 0 then
      oxygen.add(pid, 1);
    end
  else
    regen_ticks[pid] = 1;
  end
end)
