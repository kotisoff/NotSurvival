-- ========================header===========================
local mp = require "shared/lib/not_utils".multiplayer;
-- =========================================================

local module = {
  session = {}
};

-- Shared

function module.get_slots(pid)
  if mp.mode == "client" then
    return module.session;
  end
end
