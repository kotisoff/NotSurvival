local constants = require "shared/core/constants";
local pack_id = constants.pack_id;

---@return string
return function(name)
  return pack_id .. ":" .. name;
end
