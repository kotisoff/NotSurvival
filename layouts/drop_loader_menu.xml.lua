local drop_loader = require "drop/drop_loader";
local loot_tables = require "drop/loot_tables";

function on_open(params)
  refresh();
  open_pack("not_survival:resources/data/not_survival");
end

---@param res_path string
function open_pack(res_path)
  local packid = string.split(res_path, ":")[1];
  document.parent.text = pack.get_info(packid).title;

  local info = drop_loader.packs[res_path];

  text_arr = {};

  ---@param drop Drop
  for filename, drop in pairs(info) do
    table.insert(text_arr, string.format('"%s.json" %ss drop for "%s"', filename, drop.type, drop.name));
  end

  local text = table.concat(text_arr, "\n");
  if text == "" then text = "None" end;

  document.drops.text = text;
end

local function use_pack_template(res_path)
  local packid = string.split(res_path, ":")[1];

  local res_tab = string.split(res_path, "/");
  local res_name = res_tab[#res_tab];

  local element = string.format(
    "<container onclick='open_pack(\"%s\")' size='0,80' color='#00000040' hover-color='#00000080'><label color='#FFFFFF80' size='300,25' align='right' gravity='top-right'>%s</label><label pos='10,6'>%s</label><label pos='10,28' size='355,50' multiline='true' color='#FFFFFFB2'>%s</label></container>",
    res_path, packid, res_name,
    string.format(
      "Содержит в себе %d дроп(а)(ов).",
      table.count_pairs(drop_loader.packs[res_path])
    )
  )

  return element;
end

function refresh()
  local contents = document.contents;
  contents:clear();

  for res_path, _ in pairs(drop_loader.packs) do
    contents:add(use_pack_template(res_path));
  end
end

function reload_drop()
  drop_loader.logger:println("Reloading drop!");
  drop_loader.reload();
  drop_loader.register_base_drop();
  refresh();
  drop_loader.logger:println("Done.");
end
