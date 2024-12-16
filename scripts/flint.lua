require("utility/utils");
local not_crafting = "not_crafting";

function on_use_on_block(x, y, z, pid, normal)
  if block.get(x, y, z) == block.index("base:wood") then
    if not pack.is_installed(not_crafting) then
      local available = table.has(pack.get_available(), not_crafting)
      local text = '"not_crafting" is not installed! ';
      if available then text = text .. "You can add it to your world from contents." end
      print(text);
      return;
    end;
    block.set(x, y, z, block.index(not_crafting .. ":primitive_crafting_table"))
    inventory.consume_selected(pid);
    return true
  end
end
