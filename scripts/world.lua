require "pack_env";
require "init";

local first_tick = true;
function on_world_open()
  first_tick = true;
end

function on_world_tick(tps)
  if first_tick then
    ns_events.emit("first_tick")
    first_tick = false;
  end

  ns_events.emit("world_tick", tps)
end

function on_player_tick(pid, tps)
  ns_events.emit("player_tick", pid, tps)
end

function on_block_placed(blockid, x, y, z, pid)
  ns_events.emit("block_placed", blockid, x, y, z, pid);
end

function on_block_broken(blockid, x, y, z, pid)
  ns_events.emit("block_broken", blockid, x, y, z, pid);
end

function on_world_quit()
  ns_events.emit("world_quit");
  events.remove_by_prefix(PACK_ID);
end
