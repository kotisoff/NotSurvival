local mp = require "shared/utils/not_utils".multiplayer;
local manager = require "shared/player/data/manager";

local function req_pid(pid)
  return pid ~= nil and pid or hud.get_player();
end

---@param name str
return function(name)
  ---@class ns.stat.base
  local module = {};

  -- ========================shared===========================

  ---@param pid? int Default: hud.get_player()
  ---@return number
  function module.get(pid)
    pid = req_pid(pid);
    return manager.get_data(pid)[name]
  end

  ---@param pid? int Default: hud.get_player()
  ---@return number
  function module.get_max(pid)
    pid = req_pid(pid);
    return manager.get_attributes(pid)[name]
  end

  -- ========================server===========================

  mp.as_server(function()
    ---Server side only
    ---@param pid int
    ---@param value number
    function module.set(pid, value)
      assert(type(value) == "number", string.format("Tried to set %s type value to stat %s", type(value), name));

      local max = module.get_max(pid);
      local new_val = math.clamp(value, 0, max)

      manager.set(pid, "data", name, new_val);
    end

    ---Server side only
    ---@param pid int
    function module.full(pid)
      module.set(pid, module.get_max(pid))
    end

    ---Server side only
    ---@param pid int
    ---@param amount? number default: 1
    function module.add(pid, amount)
      local value = module.get(pid);
      module.set(pid, value + (amount or 1));
    end
  end)

  return module;
end
