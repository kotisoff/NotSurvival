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
		module.tree[res_id][stat] = data;

		logger:log("I", string.format('Added "%s:%s" as %s["%s"]', res_id, stat, data.category, module.stat_id(res_id, stat)));
	end)
	logger:print();

	reader:clear();
end

function module.stat_id(res_id, name)
	if res_id == constants.pack_id then
		return name;
	end;
	return string.format("%s:%s", res_id, name);
end

function module.require_tree()
	if table.count_pairs(module.tree) == 0 then
		module.reload();
	end

	return module.tree;
end

function module.build()
	local res = {
		attributes = {}
	};

	local tree = module.require_tree();
	for res_id, stats in pairs(tree) do
		for stat, data in pairs(stats) do
			local id = module.stat_id(res_id, stat);

			res[data.category] = res[data.category] or {};
			res[data.category][id] = data.init;

			if data.max then
				res.attributes[id] = data.max;
			end
		end
	end

	return res;
end

function module.build_scheme()
	local scheme = {
		attributes = {}
	};

	local tree = module.require_tree();
	for res_id, stats in pairs(tree) do
		for stat, data in pairs(stats) do
			if data.net then
				local id = module.stat_id(res_id, stat);

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

	debug.print(scheme);
end)

test_tool.create_test("build_stats_values", function()
	local values = module.build();

	debug.print(values);
end)

return module;
