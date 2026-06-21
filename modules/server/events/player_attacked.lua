local mp = require "shared/utils/not_utils".multiplayer.api.server
local net_events = require "shared/net/utils/net_events"
local health = require "shared/player/stats/health"
local ns_events = require "shared/core/ns_events"

local function dist_fun(veca, vecb)
  if vec3.distance then
    return vec3.distance(veca, vecb);
  else
    local t = vec3.pow(vec3.sub(vecb, veca), 2);
    local n = 0;
    for _, value in ipairs(t) do
      n = n + value;
    end

    return math.sqrt(n);
  end
end

ns_events.on("player_attacked", function(victim_pid, attacker_pid)
  local client_pos = { player.get_pos(attacker_pid) };
  local attacked_pos = { player.get_pos(victim_pid) };
  local distance = dist_fun(client_pos, attacked_pos);

  if distance > 4 then
    return;
  end

  health.damage(victim_pid, 1,
    { damage_type = "ns.damage.hit", source = vec3.sub(client_pos, { 0, 1, 0 }) })
end)
