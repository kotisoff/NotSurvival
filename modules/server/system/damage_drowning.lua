local health       = require "server/lib/health"
local server_utils = require "server/lib/server_utils"
local oxygen       = require "server/lib/oxygen"

local function is_under_block(pid)
  local x, y, z = player.get_pos(pid);
  local blockid = block.get(x, y + 1, z);
  return blockid ~= 0, blockid;
end

local tick = {}
local function get_tick(pid, field)
  return (tick[pid] or {})[field] or 1
end
local function set_tick(pid, field, val)
  tick[pid] = tick[pid] or {}
  tick[pid][field] = val
end
local function add_tick(pid, field, val)
  tick[pid] = tick[pid] or {}
  tick[pid][field] = get_tick(pid, field) + val
end


local water = block.index("base:water")

events.on(server_utils.get_player_event(), function(pid)
  local tps = server_utils.tps
  local under_block, blockid = is_under_block(pid)
  local under_water = under_block and blockid == water

  if under_water then
    add_tick(pid, "drown", 1)
  else
    set_tick(pid, "drown", 1)
  end

  if get_tick(pid, "drown") > (tps * 2) and under_water then
    set_tick(pid, "drown", 1)

    oxygen.add(pid, -1)
    if oxygen.get(pid) <= 0 then
      health.damage(pid, 2, { damage_type = "ns.damage.drown", do_knockback = false })
    end
  end

  if oxygen.get(pid) < oxygen.get_max(pid) and not under_water then
    add_tick(pid, "regen", 1)
    if get_tick(pid, "regen") > (tps / 2) then
      set_tick(pid, "regen", 1)
      oxygen.add(pid, 1)
    end
  end
end)
