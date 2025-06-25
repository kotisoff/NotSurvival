local _nu           = require "shared/utils/not_utils"
local cor           = _nu.coroutines
local utils         = _nu.utils
local mp            = _nu.multiplayer.api.client
local packets       = require "shared/utils/declarations/packets"
local resource      = require "shared/utils/resource_func"
local sounds        = require "shared/lib/sounds_registry"
local hunger        = require "shared/lib/hunger"
local client_hunger = require "client/lib/hunger"
local speed_limiter = require "client/system/speed_limiter"

local packid        = "not_survival"

local food

local function start_eating()
  speed_limiter.set_limit(2.5)
  mp.events.send(packid, packets.food_eating, mp.bson.serialize({ true }))
end

local function stop_eating()
  speed_limiter.set_limit()
  food.eating = false
  mp.events.send(packid, packets.food_eating, mp.bson.serialize({ false }))
end

events.on(resource("player_tick"), function(pid, tps)
  if pid ~= hud.get_player() then return end

  if not food then
    food = { eating = false }
  end

  if input.is_active("player.build") and not hud.is_inventory_open() and not hud.is_paused() then
    local inv, slot = player.get_inventory(pid)
    local itemid = inventory.get(inv, slot)
    local data = hunger.get_food_data(itemid)
    local is_not_max = client_hunger.get_hunger() ~= client_hunger.get_max_hunger()

    if food.eating then
      if food.id ~= itemid or food.slot ~= slot then
        return stop_eating()
      end

      food.tick = food.tick + 1
    elseif data and (is_not_max or data.eat_anyway) then
      food.eating = true
      food.id = itemid
      food.slot = slot
      food.tick = tps
      food.sound = true

      start_eating()
    end
  elseif food.eating then
    stop_eating()
  end
end)

mp.events.on(packid, packets.food_eating, function()
  utils.random_cb(0.5,
    function()
      audio.play_sound_2d(sounds.get("ns.hunger.burp"), 0.35, 1, "regular");
    end
  )

  food.sound = false
  cor.create(function()
    cor.sleep(0.2)
    speed_limiter.set_limit()
    food.eating = false
  end)
end)

---@param type food_type
---@return string
local function get_eating_sound(type)
  if type == "food" then
    return sounds.random("ns.hunger.eating")
  else
    return sounds.get("ns.hunger.drink")
  end
end

events.on(resource("player_tick"), function(pid, tps)
  if pid ~= hud.get_player() or not food.eating then return end
  local type = hunger.get_food_data(food.id).food_type

  if math.floor(food.tick) > tps / 4 and type and food.sound then
    food.tick = 0

    local sound = get_eating_sound(type)
    audio.play_sound_2d(sound, 0.7, 1)
  end
end)
