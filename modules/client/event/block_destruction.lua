local mp       = require "shared/utils/not_utils".multiplayer.api.client
local packets  = require "shared/utils/declarations/packets"
local resource = require "shared/utils/resource_func"

local packid   = "not_survival"

local target

local function start_destroy()
  mp.events.send(packid, packets.block_breaking, mp.bson.serialize(target.pos))
end

local function stop_breaking()
  target.breaking = false
  mp.events.send(packid, packets.block_breaking, {})
end

events.on(resource("player_tick"), function(pid, tps)
  if pid ~= hud.get_player() then return end

  if not target then
    target = { breaking = false, pos = {} }
  end

  if input.is_active("player.destroy") then
    local x, y, z = player.get_selected_block(pid)

    if target.breaking then
      local tx, ty, tz = unpack(target.pos)

      if block.get(x, y, z) ~= target.id or
          x ~= tx or y ~= ty or z ~= tz then
        return stop_breaking()
      end

      target.tick = target.tick + 1
    elseif x ~= nil then
      target.breaking = true
      target.pos = { x, y, z }
      target.id = block.get(x, y, z)
      target.tick = 0
      start_destroy()
    end
  elseif target.breaking then
    stop_breaking()
  end
end)

mp.events.on(packid, packets.block_breaking, function()
  target.breaking = false
end)

events.on(resource("player_tick"), function(pid)
  if pid ~= hud.get_player() or not target.breaking then return end
  local x, y, z = unpack(target.pos)

  if math.floor(target.tick) % 4 == 0 then
    local sound = block.materials[block.material(target.id)].stepsSound
    audio.play_sound(sound, x + 0.5, y + 0.5, z + 0.5, 1, 1)

    local camera = cameras.get("core:first-person")
    local ray = block.raycast(camera:get_pos(), camera:get_front(), 64.0)
    if not ray then return end

    gfx.particles.emit(ray.endpoint, 4, {
      lifetime = 1.0,
      spawn_interval = 0.0001,
      explosion = { 3, 3, 3 },
      velocity = vec3.add(vec3.mul(camera:get_front(), -1.0), { 0, 0.5, 0 }),
      texture = "blocks:" .. block.get_textures(target.id)[1],
      random_sub_uv = 0.1,
      size = { 0.1, 0.1, 0.1 },
      size_spread = 0.2,
      spawn_shape = "box",
      collision = true
    })
  end
end)
