local _nu = require "shared/utils/not_utils"

local mp = _nu.multiplayer.api.server
local data = require "shared/player/data"
local packets = require "shared/utils/declarations/packets"
local damage = require "shared/lib/damage"
local module_utils = require "server/lib/util/module_utils"

local constants = require "constants";
local pack_id = constants.pack_id;
local cat, field = "data", "health";

local module = {}


-- ====funcs=====

---@return number
function module.get(pid)
  return data.get_data(pid, field)
end

---@return number
function module.get_max(pid)
  return data.get_attributes(pid, field)
end

function module.set(pid, value)
  local max = module.get_max(pid)
  local new_val = math.clamp(value, 0, max)

  data.set_field(pid, cat, field, new_val)
  module_utils.update(pid, cat, field, new_val)
end

function module.full(pid)
  module.set(pid, module.get_max(pid))
end

function module.add(pid, amount)
  local value = module.get(pid)
  module.set(pid, value + (amount or 1))
end

---@class ns.api.health.damage_options
---@field damage_type? damage_types
---@field source? vec3 Position of damage source.
---@field do_knockback? boolean Knockback player.
---@field play_sound? boolean Allows to play sound
---@field sound_settings? { volume?: number, pitch?: number, channel?: "regular"|str }

---@param pid int
---@param amount number
---@param options? ns.api.health.damage_options
function module.damage(pid, amount, options)
  module.add(pid, -amount)
  options = options or {}

  if type(options.do_knockback) == "nil" then
    options.do_knockback = true
  end
  if type(options.play_sound) == "nil" then
    options.play_sound = true
  end
  local source = options.source or { player.get_pos(pid) }

  if options.play_sound then
    local x, y, z = unpack(source)

    local sound = options.sound_settings or {}
    local volume, pitch = sound.volume or 1, sound.pitch or 1
    local channel = sound.channel or "regular"

    mp.audio.play_sound(damage.random_sound(options.damage_type), x, y, z, volume, pitch, channel)
  end

  local status, client = pcall(mp.accounts.get_client_by_name, player.get_name(pid))
  if not status or not client then return end

  if options.do_knockback then
    local vel = damage.calculate_knockback(pid, source, 7)
    mp.events.tell(pack_id, packets.deal_knockback, client, mp.bson.serialize(vel))
  end

  mp.events.tell(pack_id, packets.update_player_data, client,
    mp.bson.serialize({
      data.get_category_index(cat),
      data.get_field_index(cat, field),
      module.get(pid)
    })
  )

  print(string.format("Игроку %s нанесено %d урона", client.player.username, amount))
end

return module
