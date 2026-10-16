local M               = require "shared/net/logic/BlockDestruction".server;
local destruction     = require "shared/lib/destruction"
local camera_position = require "shared/utils/camera_position"
local drop_utils      = require "shared/utils/drop_utils"
local base_utils      = require "shared/utils/base_utils"

local RAYCAST_VERIFY  = true;

---@class ns.net.PredictedEvent.BlockDestruction.server.Instance: neutron.server.predicted_events.Instance
---@field data { pos: vec3, block: int, pid: int, last_tick: number }

---@param client neutron.class.client
local function raycast(client)
	local pid = client.player.pid;
	local pos = camera_position.by_client(client)

	return block.raycast(pos, player.get_dir(pid), player.get_interaction_distance(pid));
end

---@param client neutron.class.client
---@param data { pos: vec3, block: int }
function M.on_start(client, data)
	if RAYCAST_VERIFY then
		local ray = raycast(client);
		if ray and ray.block == data.block then
			return true
		end

		return false;
	else
		return block.get(unpack(data.pos)) == data.block
	end
end

---@param client neutron.class.client
---@param instance ns.net.PredictedEvent.BlockDestruction.server.Instance
function M.on_interrupt(client, instance)
end

---@param client neutron.class.client
---@param instance ns.net.PredictedEvent.BlockDestruction.server.Instance
function M.on_tick(client, instance)
	local now = time.uptime();
	local dt = now - (instance.data.last_tick or instance.start_time);
	instance.data.last_tick = now;

	local speed = destruction.get_breaking_speed(client.player.pid, instance.data.block);
	return instance:get_progress() + speed * dt;
end

---@param client neutron.class.client
---@param instance ns.net.PredictedEvent.BlockDestruction.server.Instance
function M.on_finish(client, instance)
	local pid = client.player.pid;
	local blockid = instance.data.block;

	local x, y, z = unpack(instance.data.pos);

	if block.get(x, y, z) ~= instance.data.block then
		instance:interrupt();
	end

	block.destruct(x, y, z, pid);
	inventory.use(player.get_inventory(pid));

	local ns_loot = drop_utils.block_loot(blockid);
	local drop = base_utils.block_loot(blockid);
	local drop_pos = vec3.add(instance.data.pos, 0.5);

	for _, loot in ipairs(drop) do
		if loot.item then
			---@type voxelcore.class.entity | nil
			local entity = base_utils.drop(drop_pos, loot.item, loot.count);
			if entity then
				entity.rigidbody:set_vel(vec3.spherical_rand(3));
			end
		end
	end

	ns_loot.callback(blockid, x, y, z, pid);
end
