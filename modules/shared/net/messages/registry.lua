local id = 0;

local function next()
  id = id + 1;
  return tostring(id);
end

local messages = {
  player_respawn = next()
}

for key, value in pairs(messages) do
  print(key, value);
end

return messages;
