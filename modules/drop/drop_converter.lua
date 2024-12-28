local drop_converter = {};

---@class Drop
---@field name string
---@field version number
---@field type "append"|"replace"
---@field pools DropPool[]

local drop_version = 0;
local packinfo = pack.get_info("not_survival");
local version_table = string.split(packinfo.version, ".");
for key, value in ipairs(version_table) do
  local reversed_key = #version_table - key;
  drop_version = drop_version + tonumber(value) * (10 ^ reversed_key);
end

local DropElement = {
  ---@param obj any
  ---@param version number
  ---@return DropPool
  new = function(obj, version)
    ---@type DropPool
    local this = {};

    if version == 0 then
      -- beta version conversion.
      for key, value in pairs(obj) do
        if key == "id" then
          this.items = { value };
        elseif key == "drop-chances" or key == "drop-chance" then
          if #value == 1 then
            this.count = unpack(value);
          else
            this["count-chances"] = value;
          end
        else
          this[key] = value;
        end
      end
    end

    return this;
  end
}

local Drop = {
  ---@param obj any
  ---@return Drop
  new = function(obj)
    ---@type Drop
    local this = {
      name = obj.name,
      pools = {},
      version = drop_version,
      type = obj.type or "append"
    };

    for _, value in pairs(obj.pools) do
      ---@type DropPool
      local drop = DropElement.new(value, obj.version or 0);
      table.insert(this.pools, drop);
    end

    return this;
  end
}

---@param res_path string PACK_ID:resources/data/resource_id
function drop_converter.convert(res_path)
  local path = res_path .. "/loot_table/blocks";
  if file.exists(path) then
    for _, name in pairs(file.list(path)) do
      -- Check for json.
      local split = string.split(name, ".");
      if split[#split] ~= "json" then goto continue; end;

      local data = json.parse(file.read(name));
      if data.version and data.version >= drop_version then goto continue; end;

      file.write(name, json.tostring(Drop.new(data)));
      print("[not_survival][drop_converter] Converted " .. name);

      ::continue::
    end
  end
end

return drop_converter;
