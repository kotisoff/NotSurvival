function resource(name) return PACK_ID .. ":" .. name end

local variables = require("utility/variables");
require("utility/commands");
require("utility/rules");
require("main");

local first_tick = true;
function on_world_open()
  first_tick = true;
end

function on_world_quit()
  variables.save()
end

function on_world_tick(tps)
  if first_tick then
    player.set_name(hud.get_player(), "Player")
    variables.load();
    events.emit(resource("first_tick"))
    first_tick = false;
  end

  events.emit(resource("world_tick"))
end

function on_player_tick(pid, tps)
  events.emit(resource("player_tick"), pid, tps)
end

function on_block_placed(blockid, x, y, z, pid)
  events.emit(resource("block_placed"), blockid, x, y, z, pid);
end

function on_block_broken(blockid, x, y, z, pid)
  events.emit(resource("block_broken"), blockid, x, y, z, pid);
end
