local not_utils = require "utility/utils";
local Logger = require "utility/logger";
local variables = require "player/variables";
local resource = require "utility/resource_func";

---@class Effect
---@field apply fun(self, pid:number, level:number, duration:number) Do not override this, override on_applied
---@field remove fun(self, pid:number) Do not override this, override on_removed
---@field update_status fun(self, pid:number, level:number, duration:number,time_passed:number) Do not override.
---@field on_applied fun(self, pid:number, level:number, duration:number)
---@field on_removed fun(self, pid:number)
---@field tick fun(self, pid:number, level:number, duration:number,time_passed:number)
---@field identifier string
---@field logger Logger


---@param self Effect
---@param pid number
---@param level number
---@param duration number In seconds
local function apply(self, pid, level, duration)
  not_utils.create_coroutine(function()
    local _break = false;

    events.on(resource("remove_effect"), function(identifier, target_pid)
      if self.identifier == identifier and target_pid == pid then
        _break = true;
      end
    end)

    not_utils.sleep_with_break(duration,
      function(tempdata)
        return _break
      end,
      function(tempdata, time_passed)
        self:tick(pid, level, duration, time_passed);
        self:update_status(pid, level, duration, time_passed);
      end
    )

    self:remove(pid);
  end)
  self:on_applied(pid, level, duration);
end

---@param self Effect
---@param pid number
local function remove(self, pid)
  events.emit(resource("remove_effect"), self.identifier, pid);
  self:update_status(pid, 0, 0, 0);
  self:on_removed(pid);
end

---@param self Effect
---@param pid number
---@param level number
---@param duration number In seconds
---@param time_passed number In seconds
local function tick(self, pid, level, duration, time_passed)
end

---@param self Effect
---@param pid number
---@param level number
---@param duration number In seconds
---@param time_passed number In seconds
local function update_status(self, pid, level, duration, time_passed)
  local status = variables.get_player_status(pid);

  local index;
  for key, value in ipairs(status.effects) do
    if value.identifier == self.identifier then
      index = key;
      break;
    end
  end
  index = index or #status.effects + 1;

  if duration > 0 then
    local effect = {
      identifier = self.identifier,
      level = level,
      time_left = not_utils.round_to(duration - time_passed, 100)
    }

    status.effects[index] = effect;
  elseif index then
    table.remove(status.effects, index);
  end
end

local Effect = {
  ---@return Effect
  new = function(identifier)
    return setmetatable(
      {
        identifier = identifier,
        logger = Logger.new("not_survival", "effect@" .. identifier)
      },
      {
        __index = {
          apply = apply,
          remove = remove,
          update_status = update_status,
          tick = tick,
          on_applied = function(...) end,
          on_removed = function(...) end,
        }
      }
    );
  end
}

return Effect;
