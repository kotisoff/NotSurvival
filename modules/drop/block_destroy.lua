local function is_survival(pid)
  return gamemode.get_player_mode(pid) == 0;
end

local function is_in_air(pid)
  local _, vel_y, _ = player.get_vel(pid);

  return vel_y > 0.1 or vel_y < -0.1;
end

local function get_tool_speed(pid)
  local invid, slot = player.get_inventory(pid);
  local itemid = inventory.get(invid, slot);

  local itemprops = item.properties[itemid]
  if not itemprops then return 1 end;
  return itemprops["not_survival:tool_speed"] or 1;
end

local function get_speed_multiplier(pid)
  local speed = get_tool_speed(pid);
  if is_in_air(pid) then
    speed = speed / 5;
  end
  return speed;
end

---@author MihailRis
---@copyright MIT
---Modified.

-- from base_survival:scripts/world.lua

local breaking_blocks = {};

local function get_durability(id)
  local durability = block.properties[id]["base:durability"]
  if durability ~= nil then
    return durability
  end
  if block.get_model(id) == "X" then
    return 0.0
  end
  return 5.0
end

local function stop_breaking(pid, target)
  stop_destroy(pid, target)
  target.breaking = false
end

events.on("not_survival:player_tick", function(pid, tps)
  if not is_survival(pid) then return end

  local target = breaking_blocks[pid]
  if not target then
    target = { breaking = false }
    breaking_blocks[pid] = target
  end

  if input.is_active("player.destroy") then
    local x, y, z = player.get_selected_block(pid)
    if rules.get("ns-instant-destruction") then block.destruct(x, y, z, pid) end;

    if target.breaking then
      if block.get(x, y, z) ~= target.id or
          x ~= target.x or y ~= target.y or z ~= target.z then
        return stop_breaking(pid, target)
      end

      local speed = 1.0
          / math.max(get_durability(target.id), 0.00001)
          * get_speed_multiplier(pid)

      target.progress = target.progress + (1.0 / tps) * speed
      target.tick = target.tick + 1
      if target.progress >= 1.0 then
        block.destruct(x, y, z, pid)
        return stop_breaking(pid, target)
      end
      progress_destroy(pid, target)
    elseif x ~= nil then
      target.breaking = true
      target.id = block.get(x, y, z)
      target.x = x
      target.y = y
      target.z = z
      target.tick = 0
      target.progress = 0.0
      start_destroy(pid, target)
    end
  elseif target.wrapper then
    stop_breaking(pid, target)
  end
end)

-- from base_survival:scripts/hud.lua

function start_destroy(playerid, target)
  target.wrapper = gfx.blockwraps.wrap(
    { target.x, target.y, target.z }, "cracks/cracks_0"
  )
end

function progress_destroy(playerid, target)
  local x = target.x
  local y = target.y
  local z = target.z
  gfx.blockwraps.set_texture(target.wrapper, string.format(
    "cracks/cracks_%s", math.floor(target.progress * 11)
  ))
  if target.tick % 12 == 0 then
    audio.play_sound(block.materials[block.material(target.id)].stepsSound,
      x + 0.5, y + 0.5, z + 0.5, 1.0, 1.0, "regular"
    )
    local camera = cameras.get("core:first-person")
    local ray = block.raycast(camera:get_pos(), camera:get_front(), 64.0)
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
end

function stop_destroy(playerid, target)
  gfx.blockwraps.unwrap(target.wrapper)
end
