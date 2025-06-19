local function tohex(n)
  return string.format("%x", n)
end

local packets = {
  request_player_data = tohex(1)
}

return packets
