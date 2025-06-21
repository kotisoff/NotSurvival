local mp         = require "utils/not_utils".multiplayer.api.server
local block_dest = require "shared/lib/block_destruction"
local packets    = require "utils/packets"
local resource   = require "utils/resource_func"
local true_tps   = require "server/lib/true_tps"

local packid     = "not_survival"

---@type {pos: vec3, id: int, progress: number, tick: int, wrap: int}[]
local breaking   = {}

mp.events.on(packid, packets.block_breaking, function(client, bytes)
  local pid = client.player.pid
  local status, pos = pcall(mp.bson.deserialize, bytes)
  if status then
    local texture = block_dest.get_breaking_texture(0)
    local id = mp.blockwraps.wrap(pos, texture)

    breaking[pid] = {
      pos = pos,
      id = block.get(unpack(pos)),
      progress = 0,
      tick = 0,
      wrap = id
    }
  elseif breaking[pid] then
    local target = breaking[pid]

    local x, y, z = unpack(target.pos)
    block.destruct(x, y, z, pid)

    mp.blockwraps.unwrap(target.wrap)

    breaking[pid] = nil

    print(pid, "кончай ломать блоки сука")
  end
end)

local ticks = 0
local start = time.uptime()
events.on(resource("player_tick"), function(pid, _)
  local tps = true_tps.tps
  local target = breaking[pid]
  if not target then return end

  local speed = block_dest.get_breaking_speed(pid, target.id)

  target.progress = target.progress + (1 / tps) * speed
  target.tick = target.tick + 1
end)
