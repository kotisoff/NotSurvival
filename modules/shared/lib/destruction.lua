local tags             = require "shared/utils/not_utils".tags;
local tools            = require "shared/lib/tools"
local death            = require "shared/player/stats/death"

local module           = {}

---@enum ns.breaking.states
module.breaking_states = {
  start = 0,
  broken = 1,
  interrupted = 2
}

---@param pid int
---@param blockid int
function module.get_speed_multiplier(pid, blockid)
  local itemid = inventory.get(player.get_inventory(pid));

  local speed = tools.get_tool_speed(itemid);

  if not tools.is_tool_effective(itemid, blockid) then
    speed = 1;
  elseif false then -- has efficiency modifier
    local efficiency_level = 0

    speed = speed + (efficiency_level ^ 2 + 1)
  end

  local player_blockid = block.get(player.get_pos(pid));
  local blocktags = tags.block.get_tags(player_blockid);

  if table.has(blocktags, "core:liquid") then
    speed = speed / 5;
  end

  if not player.is_on_ground(pid) then
    speed = speed / 5;
  end

  return speed
end

---@return number
function module.get_durability(id)
  local durability = block.properties[id]["base:durability"]
  if durability ~= nil then
    return durability
  end
  if block.get_model(id) == "X" then
    return 0.0
  end
  return 5.0
end

---@param pid int|nil
---@param blockid int
function module.get_breaking_speed(pid, blockid)
  local multiplier = 1
  if pid then
    multiplier = module.get_speed_multiplier(pid, blockid)
  end

  return 1 / math.max(module.get_durability(blockid), 0.00001) * multiplier
end

---@param progress number [0,1]
function module.get_breaking_texture(progress)
  return string.format(
    "cracks/cracks_%s", math.floor(progress * 11)
  )
end

---@return number, number, number
function module.get_block_center(pos)
  ---@diagnostic disable-next-line: redundant-return-value
  return unpack(vec3.add(pos, 0.5))
end

---Устанавливает игроку set_instant_destruction и set_infinite_items в зависимости от его режима игры.
function module.update_player_rules(pid)
  local state = death.is_invulnerable(pid);

  player.set_instant_destruction(pid, state)
  player.set_infinite_items(pid, state)
end

return module
