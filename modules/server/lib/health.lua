local _nu = require "shared/utils/not_utils"

local mp = _nu.multiplayer.api.server
local data = require "shared/player/data"
local packets = require "shared/utils/declarations/packets"
local damage = require "shared/lib/damage"

local pack_id = "not_survival"

local module = {}

---@return number
function module.get(pid)
  return data.get_data(pid, "health")
end

---@return number
function module.get_max(pid)
  return data.get_attributes(pid, "health")
end

function module.update(pid)
  local client = mp.accounts.get_client(mp.accounts.get_account_by_name(player.get_name(pid)))
  mp.events.tell(pack_id, packets.update_player_data, client,
    mp.bson.serialize({
      data.get_category_index("data"),
      data.get_field_index("data", "health"),
      module.get(pid)
    })
  )
end

function module.set(pid, value)
  local max = module.get_max(pid)
  local new_val = math.clamp(value, 0, max)

  data.set_field(pid, "data", "health", new_val)
  module.update(pid)
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

  local client = mp.accounts.get_client(mp.accounts.get_account_by_name(player.get_name(pid)))

  if options.do_knockback then
    local vel = damage.calculate_knockback(pid, source, 6)
    mp.events.tell(pack_id, packets.deal_knockback, client, mp.bson.serialize(vel))
  end

  mp.events.tell(pack_id, packets.update_player_data, client,
    mp.bson.serialize({
      data.get_category_index("data"),
      data.get_field_index("data", "health"),
      module.get(pid)
    })
  )
end

return module
