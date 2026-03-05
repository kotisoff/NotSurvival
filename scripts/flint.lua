local not_crafting = "not_crafting";
local event = "use_on_block";

function on_use_on_block(x, y, z, pid, normal)
  events.emit(string.format("%s:%s", not_crafting, event), item.index("not_survival:flint"), x, y, z, pid);
end
