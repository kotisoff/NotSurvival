local logger = {
  ---@class Logger
  __index = {
    silentlogs = {},
    logs = {},
    prefix = function(self) return '[' .. self.packid .. '][' .. self.name .. '] ' end,

    filepath = function(self)
      return pack.shared_file(self.packid, self.name .. "-latest.log")
    end,

    silent = function(self, ...)
      table.insert(self.silentlogs, self:prefix() .. table.concat({ ... }, " "));
    end,

    info = function(self, ...)
      table.insert(self.logs, self:prefix() .. table.concat({ ... }, " "));
      self:silent(...);
    end,

    save = function(self)
      file.write(self:filepath(), table.concat(self.silentlogs, "\n"))
      self.logs = {};
    end,

    print = function(self)
      print(table.concat(self.logs, "\n"));
      self.logs = {};
    end,

    println = function(self, ...)
      print(self:prefix() .. table.concat({ ... }, " "))
    end
  }
}

local Logger = {
  new = function(packid, name)
    return setmetatable({ packid = packid, name = name }, logger);
  end
}

return Logger
