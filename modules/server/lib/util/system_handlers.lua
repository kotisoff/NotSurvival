local server_utils = require "server/lib/util/server_utils"
local module = {}

local ticking = {}

---@class ns.system.Ticker
---@field pid int
---@field field str
local Ticker = {}
Ticker.__index = Ticker

---@param default? number
function Ticker:get(default)
  return ticking[self.field][self.pid] or default
end

function Ticker:add(value)
  ticking[self.field][self.pid] = self:get(0) + value
end

function Ticker:set(value)
  ticking[self.field][self.pid] = value
end

local tickers_cache = {}
function Ticker.new(pid, field)
  ticking[field] = ticking[field] or {}
  local ticker = setmetatable({ pid = pid, field = field }, Ticker)

  if not tickers_cache[field] then
    tickers_cache[field] = {}
  end

  tickers_cache[field][pid] = ticker

  return ticker
end

function Ticker.get_or_create(pid, field)
  return (tickers_cache[field] or {})[pid] or Ticker.new(pid, field)
end

local ticking_events = {}

---@param name str
---@param func fun(pid: int, tps: number, event_ticker: ns.system.Ticker, get_ticker: fun(pid: int, field: str): ns.system.Ticker)
function module.set_ticking_event(name, func)
  local event = {
    handler = function(pid, tps)
      func(pid, tps, Ticker.get_or_create(pid, name), Ticker.get_or_create)
    end
  }

  ticking_events[name] = event
end

events.on(server_utils.get_player_event(), function(pid)
  local tps = server_utils.tps

  for _, value in pairs(ticking_events) do
    value.handler(pid, tps)
  end
end)

return module
