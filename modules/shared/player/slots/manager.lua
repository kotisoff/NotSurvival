-- ========================header===========================
local mp     = require "shared/lib/multiplayer"
-- =========================================================

local module = {
  session = {}
};

-- Shared

function module.get_slots(pid)
  if mp.side == "client" then
    return module.session;
  end
end
