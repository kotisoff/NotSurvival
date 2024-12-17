local PACK_ID = "not_survival"; function resource(name) return PACK_ID .. ":" .. name end

local variables = require "api".variables;

local exp = {}

-- Calculates max exp for next lvl
function exp.calc_max(lvl)
  -- Ну так, лайтовенько

  if lvl < 16 then
    return 2 * lvl + 7
  elseif lvl < 31 then
    return 5 * lvl - 38
  else
    return 9 * lvl - 158
  end
end

-- Calculates total exp for current lvl
function exp.calc_total(lvl)
  -- Вот эта жесть в ванильном майнкрафте.

  if lvl < 17 then
    return lvl ^ 2 + 6 * lvl
  elseif lvl < 32 then
    return 2.5 * lvl ^ 2 - 40.5 * lvl + 360;
  else
    return 4.5 * lvl ^ 2 - 162.5 * lvl + 2220;
  end
end

-- Calculates lvl from total exp
function exp.calc_lvl(total)
  -- 0_0 пиздец ваще лютый

  if total < 353 then
    return math.sqrt(total + 9) - 3;
  elseif total < 1508 then
    return 8.1 + math.sqrt(0.4 * (total - (7839 / 40)))
  else
    return (325 / 18) + math.sqrt((2 / 9) * (total - (54215 / 72)))
  end
end

function exp.get_xp(pid)
  return variables.get_player_data(pid).xp;
end

function exp.get_lvl(pid)
  return exp.calc_lvl(exp.get_xp(pid));
end

function exp.give(pid, amount)
  local xp = exp.get_xp(pid);
  variables.get_player_data(pid).xp = xp + amount;
end

function exp.summon(pos, amount)
  if not amount or amount <= 0 then return end;
  return entities.spawn(
    "not_survival:exp_orb",
    pos,
    {
      not_survival__exp_orb = {
        exp = amount
      }
    }
  )
end

---Забирает у игрока определённое кол-во опыта.
---@param pid number
---@param amount number
---@return boolean
function exp.drain(pid, amount)
  local xp = exp.get_xp(pid) - amount;
  if xp < 0 then return false end;
  variables.get_player_data(pid).xp = xp;
  return true;
end

---Забирает у игрока определённое кол-во уровней опыта.
---@param pid number
---@param amount number
---@return boolean
function exp.drain_lvl(pid, amount)
  local lvl = exp.calc_lvl(exp.get_xp(pid)) - amount;
  if lvl < 0 then return false end;
  variables.get_player_data(pid).xp = exp.calc_total(lvl);
  return true;
end

function exp.set_xp(pid, val)
  variables.get_player_data(pid).xp = val;
end

function exp.set_lvl(pid, val)
  local total = exp.calc_total(val);
  variables.get_player_data(pid).xp = total;
end

return exp;
