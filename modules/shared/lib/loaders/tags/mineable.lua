local not_utils = require "shared/lib/not_utils"
local logger    = require "shared/core/logger"

local tags      = not_utils.tags;
local reader    = not_utils.FileReader.new();

local module    = {
  ---@type table<int, ns.breaking.tool_type[]>
  data = {}
};

function module.reload()
  logger:println("I", "Loading tags/block/mineable's...");
  module.data = {};

  local installed = pack.get_installed();

  for _, packid in ipairs(installed) do
    local path = string.format("%s:resources/data", packid);
    reader:list(path, { recursive = true });
  end

  reader
      :filter(function(_, path)
        return (file.stem(file.parent(path)) == "mineable") and (file.ext(path) == "json")
      end)
      :read(function(data, path)
        local status, parsed = pcall(json.parse, data);
        if not status then
          return logger:log("E",
            string.format("Unable to load mineable '%s' from pack '%s'", path, file.prefix(path)));
        end

        return parsed;
      end)
      :for_each(function(data, path, buffer)
        local tool = file.stem(path);

        for _, str in ipairs(data.values) do
          if str:starts_with("#") then
            local tag = str:sub(2);
            local blockids = tags.block.get_by_tags(false, tag);

            for _, blockid in ipairs(blockids) do
              module.data[blockid] = module.data[blockid] or {};
              local t = module.data[blockid];

              if not table.has(t, tool) then
                table.insert(module.data[blockid], tool);
              end
            end
          else
            local blockid = block.index(str);

            if blockid then
              module.data[blockid] = module.data[blockid] or {};
              local t = module.data[blockid];

              if not table.has(t, tool) then
                table.insert(module.data[blockid], tool);
              end
            end
          end
        end
      end)
      :clear();
end

function module:compress()
  local compressed = {};

  for blockid, tools in pairs(self.data) do
    for _, tool in ipairs(tools) do
      compressed[tool] = compressed[tool] or {};

      table.insert(compressed[tool], blockid);
    end
  end

  return compressed;
end

function module:decompress(compressed)
  local decompressed = {};

  for tool, blocks in pairs(compressed) do
    for _, blockid in ipairs(blocks) do
      decompressed[blockid] = decompressed[blockid] or {};

      table.insert(decompressed[blockid], tool);
    end
  end

  return decompressed;
end

---@param blockid int
---@return ns.breaking.tool_type[]
function block.get_tools(blockid)
  return module.data[blockid];
end

return module;
