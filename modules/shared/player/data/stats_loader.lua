local not_utils = require "shared/lib/not_utils";
local test_tool = require "shared/lib/test_tool"
local constants = require "shared/core/constants"

local reader = not_utils.FileReader.new();

local module = {
	---@type table<string, table<string, { category: string, override?: string, net?: string, init: any, max?: int }>>
	tree = {}
};

function module.reload()
	logger:println("I", "Loading stats");

	module.tree = {};
	reader:clear();

	local installed = pack.get_installed();

	for _, pack_id in ipairs(installed) do
		local path = string.format("%s:resources/data", pack_id);
		reader:list(path);
	end

	reader
			:filter_paths(function(data, path, buffer)
				return file.isdir(path)
			end)
			:for_each_path(function(data, path, buffer)
				local sub_path = string.format("%s/stats", path);
				reader:list(sub_path);
			end)
			:filter_paths(function(data, path, buffer)
				return file.isfile(path) and file.ext(path) == "json";
			end);

	reader:read(json.parse);

	reader:for_each(function(data, path, buffer)
		local res_id = file.name(file.parent(file.parent(path)));
		local stat = file.name(file.remove_ext(path));

		module.tree[res_id] = module.tree[res_id] or {};
		local branch = module.tree[res_id];

		branch[stat] = data;
	end)

	reader:clear();
end

function module.build_scheme()
	local scheme = {
		attributes = {}
	};

	for res_id, stats in pairs(module.tree) do
		for stat, data in pairs(stats) do
			if data.net then
				local id = string.format("%s:%s", res_id, stat);
				if res_id == constants.pack_id then
					id = stat;
				end

				scheme[data.category] = scheme[data.category] or {};
				scheme[data.category][id] = data.net;

				if data.max then
					scheme.attributes[id] = data.net;
				end
			end
		end
	end

	return scheme;
end

test_tool.create_test("read_stats", function()
	module.reload();
end)

test_tool.create_test("build_stats_scheme", function()
	local scheme = module.build_scheme();

	assert(scheme and type(scheme) == "table", "corrupted scheme generated");

	debug.print(scheme);
end)

return module;
