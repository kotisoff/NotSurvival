local M               = require "shared/net/logic/BlockDestruction".client;
local destruction     = require "shared/lib/destruction"
local camera_position = require "shared/utils/camera_position"
local hand_animator   = require "client/systems/hand_animator"

---@class ns.net.PredictedEvent.BlockDestruction.client.Instance: neutron.client.predicted_events.Instance
---@field data { pos: vec3, block: int, pid: int, wrap: int, tick: int }

local function particles(pid, blockid, pos)
	local ray;

	if pid == hud.get_player() then
		local camera = cameras.get("core:first-person");
		ray = block.raycast(camera:get_pos(), camera:get_front(), player.get_interaction_distance(pid));
	else
		local camera_pos = camera_position.by_pid(pid);
		ray = block.raycast(camera_pos, player.get_dir(pid), player.get_interaction_distance(pid));
	end

	gfx.particles.emit(ray and ray.endpoint or pos, 4, {
		lifetime = 1.0,
		spawn_interval = 0.0001,
		explosion = { 3, 3, 3 },
		velocity = vec3.add(vec3.mul(player.get_dir(pid), -1.0), { 0, 0.5, 0 }),
		texture = "blocks:" .. block.get_textures(blockid)[1],
		random_sub_uv = 0.1,
		size = { 0.1, 0.1, 0.1 },
		size_spread = 0.2,
		spawn_shape = "box",
		collision = true
	})
end

---@param instance ns.net.PredictedEvent.BlockDestruction.client.Instance
function M.on_ack_start(instance)
	local pos = instance.data.pos;
	instance.data.wrap = gfx.blockwraps.wrap(pos, destruction.get_breaking_texture(instance.progress));
end

---@param instance ns.net.PredictedEvent.BlockDestruction.client.Instance
function M.on_reject(instance)
	logger:println("W", "Сервер отклонил событие начала разрушения.");
end

---@param instance ns.net.PredictedEvent.BlockDestruction.client.Instance
function M.on_progress(instance)
	instance.data.tick = (instance.data.tick or 0) + 1;
	hand_animator:reset_hit();
	gfx.blockwraps.set_texture(instance.data.wrap, destruction.get_breaking_texture(instance.progress));

	if instance.data.tick % 4 == 0 then
		local blockid = instance.data.block;
		local x, y, z = unpack(vec3.add(instance.data.pos, 0.5));

		local sound = block.get_sound(blockid, "stepsSound");
		audio.play_sound(sound, x, y, z, 1, 1, "regular");
		particles(instance.data.pid, blockid, { x, y, z });
	end
end

---@param instance ns.net.PredictedEvent.BlockDestruction.client.Instance
function M.on_finish(instance)
	if instance.data.wrap then
		gfx.blockwraps.unwrap(instance.data.wrap);
	end

	local x, y, z = unpack(instance.data.pos);
	local sound = block.get_sound(instance.data.block, "breakSound");
	audio.play_sound(sound, x, y, z, 1, 1, "regular");
end

---@param instance ns.net.PredictedEvent.BlockDestruction.client.Instance
function M.on_interrupt(instance)
	if instance.data.wrap then
		gfx.blockwraps.unwrap(instance.data.wrap);
	end;
end
