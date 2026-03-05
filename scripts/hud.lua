local ns_events = require "shared/core/ns_events";
local prefix    = require "shared/utils/prefix"

function on_hud_open(playerid)
  print("Загрузили худ")
  print("Кидаем ивент худа")
  ns_events.emit("hud_open", playerid);
  print("И смотрим есть ли отклик. Судя по всему его нет и хуй знает почему.")

  hud.open_permanent(prefix("survival_hud"))
end
