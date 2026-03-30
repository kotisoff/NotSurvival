local ns_events = require "shared/core/ns_events"
local _nu = require "shared/utils/not_utils"
local bson = require "shared/utils/bson"
local cor = _nu.coroutines
local utils = _nu.utils
local net_events = require "shared/net/utils/net_events"
local packets = net_events.packets;
local sounds = require "shared/utils/sounds_registry"
local hunger = require "shared/player/utils/hunger"
local hunger_mgr = require "shared/player/stats/hunger"
local movement_controller = require "client/systems/movement_controller"

local food = {
  eating = false
}

local function start_eating()
  movement_controller.set_limit("speed_in_air", 2.5);
  movement_controller.set_limit("speed_on_ground", 2.5);
  net_events.client.send(packets.food_eating, bson.serialize({ true }))
end

local function stop_eating()
  movement_controller.set_limit("speed_in_air");
  movement_controller.set_limit("speed_on_ground");
  food.eating = false
  net_events.client.send(packets.food_eating, bson.serialize({ false }))
end

ns_events.on(("player_tick"), function(pid, tps)
  if pid ~= hud.get_player() then return end

  if input.is_active("player.build") and not hud.is_inventory_open() and not hud.is_paused() then
    local inv, slot = player.get_inventory(pid)
    local itemid = inventory.get(inv, slot)
    local data = hunger.get_food_data(itemid)
    local is_not_max = hunger_mgr.get_hunger() ~= hunger_mgr.get_max_hunger()

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

net_events.client.on(packets.food_eating, function()
  utils.random_cb(0.6,
    function()
      audio.play_sound_2d(sounds.get("ns.hunger.burp"), 0.35, 1, "regular");
    end
  )

  food.sound = false
  cor.create(function()
    cor.sleep(0.2)
    movement_controller.set_limit("speed_in_air")
    movement_controller.set_limit("speed_on_ground")
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

ns_events.on(("player_tick"), function(pid, tps)
  if pid ~= hud.get_player() or not food.eating then return end
  local type = hunger.get_food_data(food.id).food_type

  if math.floor(food.tick) > tps / 4 and type and food.sound then
    food.tick = 0

    local sound = get_eating_sound(type)
    audio.play_sound_2d(sound, 0.7, 1)
  end
end)
