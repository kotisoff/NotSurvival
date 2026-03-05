local ns_events = require "shared/core/ns_events"
local world = {
  ---@type fun(tps)[]
  world_tick = {},
  ---@type fun(pid, tps)[]
  player_tick = {},
};

---@param func fun(tps: int)
function world:on_world_tick(func)
  table.insert(self.world_tick, func)
end

---@param func fun(pid: int, tps: int)
function world:on_player_tick(func)
  table.insert(self.player_tick, func)
end

function world:__player_tick(pid, tps)
  for _, event in ipairs(self.player_tick) do
    event(pid, tps)
  end
end

function world:__world_tick(tps)
  for _, event in ipairs(self.world_tick) do
    event(tps)
  end
end

ns_events.on("world_tick", function(tps)
  world:__world_tick(tps);
end)

ns_events.on("player_tick", function(pid, tps)
  world:__player_tick(tps);
end)

return world;
