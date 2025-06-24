local module = {
  ---@type table<string,string[]>
  families = {},
  ---@type table<string,string>
  registry = {}
}

function module.add(category, ...)
  module.families[category] = module.families[category] or {}
  for _, value in ipairs({ ... }) do
    table.insert(module.families[category], value)
  end
end

function module.set(name, path)
  module.registry[name] = path
end

function module.get(name, path)
  return module.registry[name]
end

function module.remove(category, ...)
  local reg = module.families[category]
  if not reg then return end

  for _, value in ipairs({ ... }) do
    if reg[value] then
      table.remove(reg, value)
    end
  end
end

function module.random(category)
  local reg = module.families[category]
  if reg then
    return reg[math.random(#reg)]
  end
end

-- ========================sounds===========================

module.add("ns.hunger.eating",
  "not_survival/random/eat1",
  "not_survival/random/eat2",
  "not_survival/random/eat3"
)

module.set("ns.hunger.burp", "not_survival/random/burp")
module.set("ns.hunger.drink", "not_survival/random/drink")


module.add("ns.damage.hit",
  "not_survival/damage/hit1",
  "not_survival/damage/hit2",
  "not_survival/damage/hit3"
)


module.add("ns.damage.fall",
  "not_survival/damage/fallsmall",
  "not_survival/damage/fallbig1",
  "not_survival/damage/fallbig2"
)


-- =========================================================

return module
