function resource(name) return PACK_ID .. ":" .. name end

local not_survival_api = require "not_survival:api";
local hunger = not_survival_api.hunger;

function eat(pid)
  hunger.eat(pid, 3, 2);
end

function on_use(pid)
  eat(pid)
end

function on_use_on_block(x, y, z, pid, normal)
  eat(pid);
end
