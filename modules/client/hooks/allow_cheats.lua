---@param state bool
return function(state)
  -- rules.set("cheat-commands", false);
  rules.set("allow-flight", state);
  rules.set("allow-noclip", state);
  rules.set("allow-cheat-movement", state);
end
