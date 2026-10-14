---@class ns.net.PacketRegistry
local registry = {
	messages = {
		player_respawn = "1",
		deal_knockback = "2",
		start_eating = "3",
		start_sprinting = "4",
		resources_data = "5"
	},
	replicators = {
		player_data = "1"
	}
}

---@type ns.net.PacketRegistry
local generated = {};

for key, ids in pairs(registry) do
	generated[key] = {};
	local cat = generated[key];
	for id, value in pairs(ids) do
		cat[id] = string.sub(key, 1, 1) .. value;
	end
end

return generated;
