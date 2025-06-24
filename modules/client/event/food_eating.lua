local mp         = require "shared/utils/not_utils".multiplayer.api.client
local packets    = require "shared/utils/declarations/packets"
local properties = require "shared/utils/declarations/properties"
local resource   = require "shared/utils/resource_func"
local sounds     = require "shared/lib/sounds_registry"
local hunger     = require "client/lib/hunger"

local packid     = "not_survival"

local food

local function start_eating()
  mp.events.send(packid, packets.food_eating)
end

local function stop_eating()
  food.eating = false
  mp.events.send(packid, packets.block_breaking, {})
end

events.on(resource("player_tick"), function(pid, tps)
  if pid ~= hud.get_player() then return end

  if not food then
    food = { eating = false }
  end

  if input.is_active("player.build") then
    local inv, slot = player.get_inventory(pid)
    local itemid = inventory.get(inv, slot)
    local props = item.properties[itemid]

    local flag = false

    for _, key in ipairs(properties.food.types) do
      if props[key] then
        flag = true
      end
    end

    if food.eating then
      if food.id ~= itemid or food.slot ~= slot then
        return stop_eating()
      end

      food.tick = food.tick + 1
    elseif flag then
      food.eating = true
      food.id = itemid
      food.slot = slot
      food.tick = 0

      start_eating()
    end
  elseif food.eating then
    stop_eating()
  end
end)

mp.events.on(packid, packets.food_eating, function()
  food.eating = false
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

events.on(resource("player_tick"), function(pid)
  if pid ~= hud.get_player() or not food.eating then return end
  local type = hunger.get_food_type(food.id)

  if math.floor(food.tick) % 5 == 0 and type then
    local sound = get_eating_sound(type)
    audio.play_sound_2d(sound, 0.7, 1)
  end
end)
