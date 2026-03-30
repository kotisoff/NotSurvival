local mp = require "shared/utils/not_utils".multiplayer;
local data = require "shared/player/data/manager"
local sync_data = require "shared/net/sync_tools/sync_player_data"
local net_utils = require "shared/net/utils/net_utils"

---@type ns.player.data_categories, ns.player.data_field.status | ns.player.data_field.base
local cat, field = "data", "oxygen"

local module = {}

-- ========================shared===========================

---@return number
function module.get(pid)
  if not pid then pid = hud.get_player() end
  return data.get_data(pid).oxygen
end

---@return number
function module.get_max(pid)
  if not pid then pid = hud.get_player() end
  return data.get_attributes(pid).oxygen
end

-- ========================server===========================

mp.as_server(function(server, mode)
  ---Server side only
  ---@param pid int
  function module.set(pid, value)
    local max = module.get_max(pid)
    local new_val = math.clamp(value, 0, max)

    data.set(pid, cat, field, new_val)
    sync_data.update(cat, field, net_utils.server.get_client_by_pid(pid))
  end

  ---Server side only
  ---@param pid int
  function module.full(pid)
    module.set(pid, module.get_max(pid))
  end

  ---Server side only
  ---@param pid int
  function module.add(pid, amount)
    local value = module.get(pid)
    module.set(pid, value + (amount or 1))
  end
end)

return module
