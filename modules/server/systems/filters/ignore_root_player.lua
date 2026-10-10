--[[
  Если: игрок это root:
    не обновлять
  Иначе:
    обновлять
]]

local mp = require "shared/lib/multiplayer".api.server;

return function(id)
  local player_instance = mp.sandbox.players.get_by_pid(id);

  local identity = player_instance and player_instance.identity or "root";

  local is_root = identity == "root" and id == 0

  return not is_root;
end
