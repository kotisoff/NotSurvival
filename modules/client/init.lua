local logger            = require "shared/core/logger";
local prefix            = require "shared/utils/prefix"
local system_controller = require "client/lib/system_controller"
local manager           = require "shared/player/data/manager"
local constants         = require "shared/core/constants"

local require_folder    = require "shared/utils/require_folder"

require_folder "client/events/local"
require_folder "client/events/net"

local systems = require_folder "client/systems"

-- hud_open вызывается в момент инициализации худа на клиенте один раз.
ns_events.on("hud_open", function(...)
  for _, system in pairs(systems) do
    system_controller:register(system);
  end
end)

ns_events.on("first_tick", function()
  hud.open_permanent(prefix "survival_hud")

  local ver = pack.get_info(constants.pack_id).version;
  console.log(string.format("[#00ff00]NotSurvival - %s[#ffffff]", ver));

  system_controller:register_player();
  print("reg player");

  print('gonna update data');
  manager.sync("data");
  manager.sync("status");
  manager.sync("attributes");
end)

ns_events.on("hud_render", function()
  system_controller:update(math.floor(1 / time.delta()))
end)

ns_events.on("world_quit", function()
  system_controller:remove_player();
end)

logger:println("I", "Клиент-сайд тута.")
