events.on("not_survival:hud_open", function()
  -- Мгновенное разрушение
  rules.create("ns-instant-destruction", false);

  -- Сохранение инвентаря
  rules.create("ns-keep-inventory", false);

  -- Строгий контроль над скоростью передвижения.
  -- (Уменьшает горизонтальную скорость до 7.5 и отключает полёт)
  rules.create("ns-control-movement", true);
end)
