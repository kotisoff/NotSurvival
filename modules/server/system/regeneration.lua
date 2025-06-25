local data = require "shared/player/data"
local health = require "server/lib/health"
local hunger = require "server/lib/hunger"
local server_utils = require "server/lib/server_utils"

local tick = {}
local function add_tick(pid, val)
  tick[pid] = (tick[pid] or 1) + val
end

events.on(server_utils.get_player_event(), function(pid, tps)
  local dead = data.get_status(pid, "dead")

  local hp = health.get(pid)
  local max_hp = health.get_max(pid)

  local hunger_lvl = hunger.get_hunger(pid)
  local max_hunger = hunger.get_max_hunger(pid)

  if hp < max_hp and hunger_lvl > max_hunger - 2 and not dead then
    add_tick(pid, 1)
    if tick[pid] > server_utils.tps then
      tick[pid] = 1

      health.add(pid, 1)
      hunger.consume(pid, 1)
    end
  elseif tick[pid] then
    tick[pid] = nil
  end
end)
