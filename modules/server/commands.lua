local _mp = require "shared/utils/not_utils".multiplayer
local server_utils = require "server/lib/util/server_utils"
local name = _mp.name
local mp = _mp.api.server

if name == "neutron" then
  mp.console.set_command("tps: -> Выводит текущий тпс, вычисленный вручную", {}, function(args, client)
    mp.console.tell(string.format("Текущий tps: %d", math.round_to(server_utils.tps, 2)), client)
  end)
end
