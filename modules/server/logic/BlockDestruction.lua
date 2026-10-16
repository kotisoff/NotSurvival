local M               = require "shared/net/logic/BlockDestruction".server;
local destruction     = require "shared/lib/destruction"
local camera_position = require "shared/utils/camera_position"

local RAYCAST_VERIFY  = true;

---@class ns.net.PredictedEvent.BlockDestruction.server.Instance: neutron.server.predicted_events.Instance
---@field data { pos: vec3, block: int, pid: int }

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
		if ray and vec3.equals(ray.iendpoint, data.pos) and ray.block == data.block then
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
	if RAYCAST_VERIFY then
		local ray = raycast(client);

		if not ray or not vec3.equals(ray.iendpoint, instance.data.pos) then
			instance:interrupt();
			return instance:get_progress();
		end
	end

	local speed = destruction.get_breaking_speed(client.player.pid, instance.data.block);
	return math.min(1, instance:get_elapsed() * speed);
end

---@param client neutron.class.client
---@param instance ns.net.PredictedEvent.BlockDestruction.server.Instance
function M.on_finish(client, instance)
	local pid = client.player.pid;
	local blockid = instance.data.block;

	local x, y, z = unpack(instance.data.pos);

	if block.get(x, y, z) ~= instance.data.block then
		instance:interrupt();
		return;
	end

	destruction.break_block(x, y, z, blockid, pid);
end
