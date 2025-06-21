local mp       = require "utils/not_utils".multiplayer.api.client
local packets  = require "utils/packets"
local resource = require "utils/resource_func"

local packid   = "not_survival"

local target

local function start_destroy()
  mp.events.send(packid, packets.block_breaking, mp.bson.serialize(target.pos))
end

local function stop_breaking()
  target = { breaking = false, pos = {} }
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
      if block.get(x, y, z) ~= target.id or
          x ~= target.pos[1] or y ~= target.pos[2] or z ~= target.pos[3] then
        return stop_breaking()
      end
    elseif x ~= nil then
      target.breaking = true
      target.pos = { x, y, z }
      target.id = block.get(x, y, z)
      start_destroy()
    end
  elseif target.breaking then
    stop_breaking()
  end
end)

mp.events.on(packid, packets.block_breaking, function()
  target.breaking = false
end)
