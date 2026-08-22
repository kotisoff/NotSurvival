local module = {}

---Calculates exp for next lvl
function module.calc_next(lvl)
  if lvl < 16 then
    return 2 * lvl + 7
  elseif lvl < 31 then
    return 5 * lvl - 38
  else
    return 9 * lvl - 158
  end
end

---Calculates total exp for lvl
function module.calc_total(lvl)
  if lvl < 17 then
    return lvl ^ 2 + 6 * lvl
  elseif lvl < 32 then
    return 2.5 * lvl ^ 2 - 40.5 * lvl + 360;
  else
    return 4.5 * lvl ^ 2 - 162.5 * lvl + 2220;
  end
end

---Calculates lvl from xp
function module.calc_level(xp)
  if xp < 353 then
    return math.sqrt(xp + 9) - 3;
  elseif xp < 1508 then
    return 8.1 + math.sqrt(0.4 * (xp - (7839 / 40)))
  else
    return (325 / 18) + math.sqrt((2 / 9) * (xp - (54215 / 72)))
  end
end

return module
