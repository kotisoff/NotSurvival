local mp = require "shared/utils/not_utils".multiplayer;

local server = {};

function server.get_client_by_pid(pid)
  return mp.as_server(function(mp_s, mode)
    local identity = mp_s.sandbox.players.get_by_pid(pid).identity;
    return mp_s.accounts.by_identity.get_client(identity);
  end)
end

local client = {};


return { server = server, client = client }
