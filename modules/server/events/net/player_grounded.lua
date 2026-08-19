local mp            = require "shared/lib/not_utils".multiplayer.api.server
local tags          = require "shared/lib/not_utils".tags;
local ns_events     = require "shared/core/ns_events";
local health        = require "shared/player/stats/health"
local fall_distance = require "shared/utils/fall_distance"
local config        = require "shared/core/config";

local function process_ground_block(pos)
  local grounded_block = block.get(unpack(pos));

  return table.has(tags.block.get_tags(grounded_block), "core:liquid")
end

ns_events.on("player_grounded", function(pid, velocity, gravity_scale)
  local identity = mp.sandbox.players.get_by_pid(pid).identity;
  local client = mp.accounts.by_identity.get_client(identity);

  if config.debug.log_events then
    print(string.format("Игрок %s(%d) упал", client.player.username, client.player.pid))
  end

  local damage = fall_distance.calculate_damage(velocity, gravity_scale)
  if damage <= 0 then return end

  local x, y, z = player.get_pos(client.player.pid)
  local cancelled = process_ground_block({ x, y, z });
  if cancelled then return end;

  health.damage(
    client.player.pid, damage,
    {
      source = { x, y - 0.5, z },
      damage_type = "ns.damage.fall",
      do_knockback = false,
      sound_settings = { volume = 0.8, pitch = math.rand(0.8, 1.2) }
    }
  );
end)
