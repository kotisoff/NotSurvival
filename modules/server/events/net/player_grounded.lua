local mp            = require "shared/lib/not_utils".multiplayer.api.server
local tags          = require "shared/lib/not_utils".tags;
local health        = require "shared/player/stats/health"
local fall_distance = require "shared/utils/fall_distance"
local config        = require "shared/core/config";
local logger        = require "shared/core/logger"

local function process_ground_block(pos)
  local grounded_block = block.get(unpack(pos));

  return table.has(tags.block.get_tags(grounded_block), "core:liquid")
end

ns_events.on("player_grounded", function(pid, distance)
  local identity = mp.sandbox.players.get_by_pid(pid).identity;
  local client = mp.accounts.by_identity.get_client(identity);

  if config.debug.log_events then
    logger:println("I",
      string.format("Игрок %s(%d) упал с высоты %s.",
        client.player.username, client.player.pid, distance
      )
    )
  end

  local damage = fall_distance.calculate_damage(distance);
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
