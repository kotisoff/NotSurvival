local ns_events = require "shared/utils/ns_events";
local resource = require "shared/utils/resource_func"

function on_hud_open(playerid)
  print("Загрузили худ")
  print("Кидаем ивент худа")
  ns_events.emit("hud_open", playerid);
  print("И смотрим есть ли отклик. Судя по всему его нет и хуй знает почему.")

  hud.open_permanent("not_survival:survival_hud")
end
