local mp        = require "shared/utils/not_utils".multiplayer;
local data      = require "shared/player/data/manager"
local sync_data = require "shared/network/sync_tools/player_data"
local net_utils = require "shared/network/utils/net_utils"

local module    = {} -- эту хуету через генератор оптимизировать также вообще не вариант.

-- ========================shared===========================

function module.get_hunger(pid)
  if not pid then pid = hud.get_player() end
  return data.get_data(pid).hunger
end

function module.get_max_hunger(pid)
  if not pid then pid = hud.get_player() end
  return data.get_attributes(pid).hunger
end

function module.get_saturation(pid)
  if not pid then pid = hud.get_player() end
  return data.get_data(pid).saturation
end

function module.get_max_saturation(pid)
  if not pid then pid = hud.get_player() end
  return data.get_attributes(pid).saturation
end

-- ========================server===========================

mp.as_server(function(server, mode)
  ---Server side only
  ---@param pid int
  function module.set_hunger(pid, amount)
    local max = module.get_max_hunger(pid)
    local value = math.clamp(amount, 0, max)

    data.get_data(pid).hunger = value;
    sync_data.update("data", "hunger", net_utils.server.get_client_by_pid(pid))
  end

  ---Server side only
  ---@param pid int
  function module.set_saturation(pid, amount)
    local max = module.get_max_saturation(pid)
    local value = math.clamp(amount, 0, max)

    data.get_data(pid).saturation = value
    sync_data.update("data", "saturation", net_utils.server.get_client_by_pid(pid))
  end

  ---Server side only
  ---@param pid int
  function module.full(pid)
    local max_h = module.get_max_hunger(pid)
    local max_s = module.get_max_saturation(pid)

    module.set_hunger(pid, max_h)
    module.set_saturation(pid, max_s)
  end

  ---Server side only
  ---@param pid int
  function module.add(pid, hunger, saturation)
    if hunger and hunger ~= 0 then
      local h = module.get_hunger(pid) + (hunger or 0)
      module.set_hunger(pid, h)
    end
    if saturation and hunger ~= 0 then
      local s = module.get_saturation(pid) + (saturation or 0)
      module.set_saturation(pid, s)
    end
  end

  ---Server side only
  ---@param pid int
  function module.consume(pid, amount)
    local s = module.get_saturation(pid)

    local new_s = s - amount
    if new_s < 0 then
      local abs_s = math.abs(new_s)
      local max_h = module.get_max_hunger(pid)

      module.set_saturation(pid, 0)

      local consumed = math.ceil(abs_s / max_h)
      if consumed < 1 then consumed = 1 end

      module.add(pid, -consumed)
    else
      module.set_saturation(pid, new_s)
    end
  end
end)

return module
