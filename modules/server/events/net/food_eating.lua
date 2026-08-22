local hunger     = require "shared/player/utils/hunger"
local hunger_mgr = require "shared/player/stats/hunger"
local prefix     = require "shared/utils/prefix"

local net_events = require "shared/net/utils/net_events"
local mp         = require "shared/lib/not_utils".multiplayer.api.server;

---@type table<str, { id: int, progress: number }>
local eating     = {}

-- =========================funcs===========================

local function start_eating(pid)
  local inv, slot = player.get_inventory(pid)
  local itemid = inventory.get(inv, slot)

  eating[pid] = {
    id = itemid,
    progress = 0
  }
end

local function get_eating(pid)
  return eating[pid]
end

local function is_eating(pid)
  return get_eating(pid) ~= nil;
end

local function stop_eating(pid)
  eating[pid] = nil;
end

-- ========================network==========================

net_events.server.on(net_events.packets.food_eating, function(client, bytes)
  local pid = client.player.pid
  ---@type bool
  local status = unpack(mp.bson.deserialize(bytes))

  if status then
    start_eating(pid)
  elseif is_eating(pid) then
    stop_eating(pid)
  end
end)

-- =================server=eating=handler===================

events.on(prefix("player_tick"), function(pid)
  if not is_eating(pid) then return end
  local target = get_eating(pid)

  local tps = mp.constants.tps.tps;

  local food_data = hunger.get_food_data(target.id)
  if not food_data then return end

  local speed = food_data.eat_delay * tps

  target.progress = target.progress + (1 / speed)

  if target.progress >= 1 then
    hunger_mgr.add(pid, food_data.food, food_data.saturation)

    local invid, slot = player.get_inventory(pid)

    if food_data.consume_item then
      inventory.decrement(invid, slot, 1)
      if food_data.replace_item then
        inventory.add(invid, food_data.replace_item, 1)
      end
    end

    stop_eating(pid)

    local identity = mp.sandbox.players.get_by_pid(pid).identity;
    local client = mp.accounts.by_identity.get_client(identity);
    net_events.server.tell(net_events.packets.food_eating, client, mp.bson.serialize({}))

    pcall(food_data.callback, pid)
  end
end)
