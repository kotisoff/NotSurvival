local id = 0;

local function next()
  id = id + 1;
  return tostring(id);
end

local messages = {
  player_respawn = next(),
  deal_knockback = next()
}

return messages;
