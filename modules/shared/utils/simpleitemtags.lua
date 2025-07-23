---@type simpleitemtags.api | nil
local simpleitemtags;

if pack.is_installed("simpleitemtags") then
  simpleitemtags = require "simpleitemtags:init";
end

return simpleitemtags;
