require "shared/utils/not_utils";
local not_crafting = "not_crafting";

function on_use_on_block(x, y, z, pid, normal)
  if block.get(x, y, z) == block.index("base:wood") then
    if not pack.is_installed(not_crafting) then
      local available = table.has(pack.get_available(), not_crafting)
      local text = string.format('[#00FF00][NS] [#FFFF00]"%s" is not installed![#FFFFFF]', not_crafting);
      if available then text = string.format("%s [#709900]But you can add it from contents.[#FFFFFF]", text) end
      console.chat(text);
      return;
    end;
    block.place(x, y, z, block.index(not_crafting .. ":primitive_crafting_table"), pid)
    local inv, slot = player.get_inventory(pid)
    inventory.decrement(inv, slot, 1)
    return true
  end
end
