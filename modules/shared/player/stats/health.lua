local mp = require "shared/utils/not_utils".multiplayer
local data = require "shared/player/data/manager";
local playerdata_utils = require "shared/player/data/utils";
local net_events = require "shared/net/utils/net_events"
local damage = require "shared/player/utils/damage";

local cat, field = "data", "health";

local module = {}

-- ========================shared===========================

---@return number
function module.get(pid)
  if not pid then pid = hud.get_player() end
  return data.get_data(pid).health
end

---@return number
function module.get_max(pid)
  if not pid then pid = hud.get_player() end
  return data.get_attributes(pid).health
end

-- ========================server===========================

mp.as_server(function(server, mode)
  ---Server side only
  ---@param pid int
  function module.set(pid, value)
    local max = module.get_max(pid)
    local new_val = math.clamp(value, 0, max)

    data.set(pid, cat, field, new_val)
  end

  ---Server side only
  ---@param pid int
  function module.full(pid)
    module.set(pid, module.get_max(pid))
  end

  ---Server side only
  ---@param pid int
  function module.add(pid, amount)
    local value = module.get(pid)
    module.set(pid, value + (amount or 1))
  end

  ---@class ns.api.health.damage_options
  ---@field damage_type? damage_types
  ---@field source? vec3 Position of damage source.
  ---@field attacker? int Entity id of attacker.
  ---@field do_knockback? boolean Knockback player.
  ---@field play_sound? boolean Allows to play sound
  ---@field sound_settings? { volume?: number, pitch?: number, channel?: "regular"|str }

  ---Server side only
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

      server.audio.play_sound(damage.random_sound(options.damage_type), x, y, z, volume, pitch, channel)
    end

    local status, _player = pcall(server.sandbox.players.get_by_pid, pid);
    if not status or not _player then return end

    local client = server.accounts.by_identity.get_client(_player.identity);

    if options.do_knockback then
      local vel = damage.calculate_knockback(pid, source, 7)
      net_events.server.tell(net_events.packets.deal_knockback, client, server.bson.serialize(vel))
    end

    print(string.format("Игроку %s нанесено %d урона", client.player.username, amount))
  end
end)

return module
