local mp         = require "shared/utils/not_utils".multiplayer;
local net_events = require "shared/net/utils/net_events"
local damage     = require "shared/player/utils/damage";
local Stat       = require "shared/player/stats/Stat";

---@class ns.stat.health: ns.stat.base
local module     = Stat("health");

-- ========================server===========================

mp.as_server(function(server, mode)
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
    options = options or {};

    if options.do_knockback == nil then
      options.do_knockback = true;
    end;
    if options.play_sound == nil then
      options.play_sound = true;
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
