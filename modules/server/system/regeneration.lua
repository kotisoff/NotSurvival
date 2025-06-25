local data = require "shared/player/data"
local health = require "server/lib/health"
local hunger = require "server/lib/hunger"
local server_utils = require "server/lib/server_utils"

local tick = {}
local function add_tick(pid, val)
  tick[pid] = (tick[pid] or 1) + val
end

events.on(server_utils.get_player_event(), function(pid, tps)
  local key = tohex(pid)

  local dead = data.get_status(pid, "dead")

  local hp = health.get(pid)
  local max_hp = health.get_max(pid)

  local hunger_lvl = hunger.get_hunger(pid)
  local max_hunger = hunger.get_max_hunger(pid)

  if hp < max_hp and hunger_lvl > max_hunger - 2 and not dead then
    add_tick(key, 1)
    if tick[key] > server_utils.tps then
      tick[key] = 1

      health.add(pid, 1)
      hunger.consume(pid, 1)
    end
  elseif tick[key] then
    tick[key] = nil
  end
end)
