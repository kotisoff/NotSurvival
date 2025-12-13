local server_utils = require "server/lib/util/server_utils"
local mp = require "shared/utils/not_utils".multiplayer.api.server;
local Counter = require "shared/utils/Counter"
local module = {}

local ticking_events = {}

---@param name str
---@param func fun(pid: int, tps: number, event_ticker: ns.utils.Counter, get_ticker: fun(pid: int, field: str): ns.utils.Counter)
function module.add_ticking_event(name, func)
  local function handler(pid, tps)
    func(pid, tps, Counter.get_or_create(pid, name), Counter.get_or_create)
  end

  ticking_events[name] = ticking_events[name] or {}
  table.insert(ticking_events[name], handler)
  return #ticking_events[name]
end

function module.remove_ticking_event(name, id)
  if (ticking_events[name] or {})[id] then
    table.remove(ticking_events[name], id)
  end
end

function module.clear_ticking_event(name)
  ticking_events[name] = nil
end

events.on(server_utils.get_player_event(), function(pid)
  local tps = (mp.constants.tps or { tps = 20 }).tps;

  for _, event in pairs(ticking_events) do
    for _, handler in ipairs(event) do
      handler(pid, tps)
    end
  end
end)

return module
