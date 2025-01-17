local PACK_ID = PACK_ID or nil;

local logger = {
  __index = {
    silentlogs = {},
    logs = {},
    prefix = function(self) return '[' .. PACK_ID .. '][' .. self.name .. '] ' end,

    filepath = function(self)
      return pack.shared_file(PACK_ID, self.name .. "-latest.log")
    end,

    silent = function(self, ...)
      table.insert(self.silentlogs, self:prefix() .. table.concat({ ... }, " "));
    end,

    info = function(self, ...)
      table.insert(self.logs, self:prefix() .. table.concat({ ... }, " "));
      self:silent(...);
    end,

    save = function(self)
      file.write(self:filepath(), table.concat(self.silentlogs, "\n"))
      self.logs = {};
    end,

    print = function(self)
      print(table.concat(self.logs, "\n"));
      self.logs = {};
    end,

    println = function(self, ...)
      print(self:prefix() .. table.concat({ ... }, " "))
    end
  }
}

local Logger = {
  new = function(name)
    return setmetatable({ name = name }, logger);
  end
}

---@param res_file string
---@return string
local function filename(res_file)
  local path_table = string.split(res_file, "/");
  local name = path_table[#path_table];
  local name_table = string.split(name, ".");
  table.remove(name_table, #name_table);
  return table.concat(name_table, ".");
end

local function scan_packs(self, folder, priority)
  self.packs = {};
  priority = priority or {};

  local installed = pack.get_installed();

  local packs = {};

  for _, pack in pairs(priority) do
    if table.has(installed, pack) then
      table.insert(packs, pack);
    end
  end
  for _, pack in pairs(installed) do
    if not table.has(packs, pack) then
      table.insert(packs, pack);
    end
  end


  for _, packid in pairs(installed) do
    local path = packid .. ":resources/" .. folder;
    if file.exists(path) then
      for _, pack in pairs(file.list(path)) do
        self.packs[pack] = {};
      end
    end
  end
end

local function load_folders(self, path, filterfunc)
  filterfunc = filterfunc or function(resource_path, filepath, data)
    return true;
  end

  for pack, _ in pairs(self.packs) do
    self.packs[pack] = {};
    local fullpath = pack .. "/" .. path;
    if file.exists(fullpath) then
      local res_files = file.list(pack .. "/" .. path);
      for _, res_file in pairs(res_files) do
        if file.isfile(res_file) then
          local filedata = file.read(res_file);
          local status, data = pcall(json.parse, filedata);

          local res_name = filename(res_file);

          if status and filterfunc(pack, res_file, data) then
            self.packs[pack][res_name] = data;
          else
            self.logger:silent("Failed to load " .. res_name .. ". Error: " .. data);
          end
        end
      end
    end
  end
  self.logger:info(table.count_pairs(self.packs) .. " packs loaded.")

  local count = 0;
  for _, resources in pairs(self.packs) do
    count = count + table.count_pairs(resources)
  end
  self.logger:info(count .. " files loaded.")
  self.logger:print();
end

local resource_loader = {
  __index = {
    packs = {},
    scan_packs = scan_packs,
    load_folders = load_folders
  }
}

local ResourceLoader = {
  set_pack_id = function(pack_id)
    PACK_ID = pack_id;
  end,
  new = function(name)
    return setmetatable({ name = name, logger = Logger.new(name) }, resource_loader);
  end,

  utils = {
    Logger = Logger
  }
}

return ResourceLoader;
