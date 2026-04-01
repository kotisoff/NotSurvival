local _mp = require "shared/utils/not_utils".multiplayer
local mode = _mp.mode
local mp = _mp.api.server

local module = {
  ---@type table<string,string[]>
  families = {},
  ---@type table<string,string>
  registry = {}
}

local function set_duration(sound, duration)
  if mode == "server" then
    mp.audio.register_duration(sound, duration)
  end
end

---@param category str
---@param max_duration number | nil
---@param ... str
function module.add(category, max_duration, ...)
  module.families[category] = module.families[category] or {}
  for _, sound in ipairs({ ... }) do
    set_duration(sound, max_duration)
    table.insert(module.families[category], sound)
  end
end

---@param name str
---@param duration number | nil
---@param path str
function module.set(name, duration, path)
  set_duration(path, duration)
  module.registry[name] = path
end

function module.get(name)
  return module.registry[name]
end

function module.remove(category, ...)
  local reg = module.families[category]
  if not reg then return end

  for _, value in ipairs({ ... }) do
    local index = table.index(reg, value)
    if index > -1 then
      set_duration(value, nil)
      table.remove(reg, index)
    end
  end
end

---@param category str
---@param duration? number
function module.random(category, duration)
  local reg = module.families[category]
  if reg then
    return reg[math.random(#reg)]
  end
end

-- ========================sounds===========================

local duration = 3

module.add("ns.hunger.eating", duration,
  "not_survival/random/eat1",
  "not_survival/random/eat2",
  "not_survival/random/eat3"
)

module.set("ns.hunger.burp", duration, "not_survival/random/burp")
module.set("ns.hunger.drink", duration, "not_survival/random/drink")


module.add("ns.damage.hit", duration,
  "not_survival/damage/hit1",
  "not_survival/damage/hit2",
  "not_survival/damage/hit3"
)


module.add("ns.damage.fall", nil,
  "not_survival/damage/fallsmall",
  "not_survival/damage/fallbig1",
  "not_survival/damage/fallbig2"
)

module.add("ns.damage.drown", nil,
  "not_survival/entity/player/hurt/drown1",
  "not_survival/entity/player/hurt/drown2",
  "not_survival/entity/player/hurt/drown3",
  "not_survival/entity/player/hurt/drown4"
)

-- =========================================================

return module
