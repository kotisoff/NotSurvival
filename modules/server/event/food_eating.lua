local not_utils     = require "shared/utils/not_utils"
local server_utils  = require "server/lib/util/server_utils"
local hunger        = require "shared/lib/hunger"
local server_hunger = require "server/lib/hunger"
local mp            = not_utils.multiplayer.api.server

local packets       = require "shared/utils/declarations/packets"
local pack_id       = "not_survival"

---@type table<str, { id: int, progress: number }>
local eating        = {}

-- =========================funcs===========================

local function start_eating(pid)
  local key = tohex(pid)
  local inv, slot = player.get_inventory(pid)
  local itemid = inventory.get(inv, slot)

  eating[key] = {
    id = itemid,
    progress = 0
  }
end

local function get_eating(pid)
  return eating[tohex(pid)]
end

local function is_eating(pid)
  return not not get_eating(pid)
end

local function stop_eating(pid)
  eating[tohex(pid)] = nil
end

-- ========================network==========================

mp.events.on(pack_id, packets.food_eating, function(client, bytes)
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

events.on(server_utils.get_player_event(), function(pid)
  if not is_eating(pid) then return end
  local target = get_eating(pid)

  local tps = server_utils.tps

  local food_data = hunger.get_food_data(target.id)
  if not food_data then return end

  local speed = food_data.eat_delay * tps

  target.progress = target.progress + (1 / speed)

  if target.progress >= 1 then
    server_hunger.add(pid, food_data.food, food_data.saturation)

    local invid, slot = player.get_inventory(pid)
    local itemid, count = inventory.get(invid, slot)
    inventory.set(invid, slot, itemid, math.clamp(count - 1, 0, count))

    if food_data.replace_item then
      inventory.add(invid, food_data.replace_item, 1)
    end

    stop_eating(pid)

    local client = mp.accounts.get_client(mp.accounts.get_account_by_name(player.get_name(pid)))
    mp.events.tell(pack_id, packets.food_eating, client, mp.bson.serialize({}))

    food_data.callback(pid)
  end
end)
