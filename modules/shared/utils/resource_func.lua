local constants = require "constants";
local pack_id = constants.pack_id;

---@return string
return function(name)
  return pack_id .. ":" .. name;
end
