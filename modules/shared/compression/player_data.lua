local mp         = require "shared/utils/not_utils".multiplayer;
local playerdata = require "shared/player/data_types";
local Buffer     = require "shared/compression/Buffer"

---@type neutron.shared.bson

local bson       = mp.as_any(function(side) return side.bson end)

local module     = Buffer.create_compressor();

---@param category ns.categories
---@param field ns.statusfield | ns.attributefield | nil
---@param data any
function module.to_bytes(category, field, data)
  local buffer = Buffer.new();

  buffer:append(playerdata.get_category_index(category));

  if field then
    buffer:append(playerdata.get_field_index(category, field));
    buffer:append(data)
  else
    buffer:append(0);
    for _, key in ipairs(playerdata.CategoryFields[category]) do
      buffer:append(data[key]);
    end
  end

  return bson.serialize(buffer.value);
end

function module.from_bytes(bytes)
  local buffer_data = bson.deserialize(bytes);
  local buffer = Buffer.new(buffer_data);

  local cat_id = buffer:read_next();
  local f_id = buffer:read_next();

  local category = playerdata.Categories[cat_id];

  if f_id > 0 then
    local field = playerdata.CategoryFields[category][f_id];
    local data = buffer:read_next();

    return category, field, data;
  else
    local data = {};
    for _, key in ipairs(playerdata.CategoryFields[category]) do
      data[key] = buffer:read_next();
    end

    return category, nil, data;
  end
end

return module;
