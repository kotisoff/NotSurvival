local module = {};

module.funcs = {};
module.keys = {};

function module.create_test(name, callback)
	table.insert_unique(module.keys, name);
	module.funcs[name] = callback;
end

function module.run()
	local keys = module.keys;

	for index, key in ipairs(keys) do
		logger:println("W", string.format("Test #%s: %s", index, key));

		local success, err = pcall(module.funcs[key]);

		if success then
			logger:println("I", "PASS");
		else
			logger:println("E", "FAIL", err);
		end
	end
end

return module;
