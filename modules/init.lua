local mp_api = require("mp_api/init")();
local resource = require "utils/resource_func";

if mp_api.server then
  require "server/init";
end
if mp_api.client then
  require "client/init";
end

events.on(resource("first_tick"), function()
  print("Not survival is running in " .. mp_api.mode .. " mode.");
end)
