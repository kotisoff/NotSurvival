local mp         = require "utils/not_utils".multiplayer.api.server
local block_dest = require "shared/lib/block_destruction"
local packets    = require "utils/packets"
local resource   = require "utils/resource_func"
local true_tps   = require "server/lib/true_tps"

local packid     = "not_survival"

---@type {pos: vec3, id: int, progress: number, tick: int, wrap: int, stage: int}[]
local breaking   = {}

mp.events.on(packid, packets.block_breaking, function(client, bytes)
  local pid = client.player.pid
  local status, pos = pcall(mp.bson.deserialize, bytes)

  if status and #pos == 3 then
    local texture = block_dest.get_breaking_texture(0)
    local id = mp.blockwraps.wrap(pos, texture)

    breaking[pid] = {
      pos = pos,
      id = block.get(unpack(pos)),
      progress = 0,
      tick = 0,
      wrap = id,
      texture = block_dest.get_breaking_texture(0)
    }
  elseif breaking[pid] then
    mp.blockwraps.unwrap(breaking[pid].wrap)
    breaking[pid] = nil
  end
end)

local event = resource("player_tick")
if events.handlers["server:main_tick"] then event = "server:main_tick" end

events.on(event, function(pid, default_tps)
  local target = breaking[pid]
  if not target then return end

  local tps = true_tps.tps
  local speed = block_dest.get_breaking_speed(pid, target.id)

  target.progress = target.progress + (1 / tps) * speed
  target.tick = target.tick + (default_tps / tps)
  local x, y, z = unpack(target.pos)

  if target.progress >= 1 then
    block.destruct(x, y, z, pid)
    breaking[pid] = nil
    return
  end

  local texture = block_dest.get_breaking_texture(target.progress)
  if target.stage ~= texture then
    mp.blockwraps.set_texture(target.wrap, texture)
  end
end)
