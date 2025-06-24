local resource = require "shared/utils/resource_func"
local health = require "server/lib/health"
local server_utils = require "server/lib/server_utils"

local tick = {}
local function add_tick(pid, val)
  tick[pid] = (tick[pid] or 1) + val
end

events.on(server_utils.get_player_event(), function(pid, tps)
  local key = tohex(pid)

  local hp = health.get(pid)
  local max_hp = health.get_max(pid)

  local hunger_lvl = 20
  local max_hunger = 20

  if hp < max_hp and hunger_lvl > max_hunger - 2 then
    add_tick(key, 1)
    if tick[key] > server_utils.tps then
      tick[key] = 1

      health.add(pid, 1)
    end
  elseif tick[key] then
    tick[key] = nil
  end
end)
