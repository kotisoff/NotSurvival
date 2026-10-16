--[[
	Server-side camera position util script.
	taken from EsPaKira/New-Generation breaking_events.lua:23
	licensed under MIT
	state: 0afe304723a956f781480696fc12a3669425139d
]]

local module = {};

local function get_offset_coef(is_crouching)
	return (is_crouching and 0.5 or 0.8) / 1.8;
end

---@param pid int
---@param is_crouching? bool
function module.by_pid(pid, is_crouching)
	local ent = entities.get(player.get_entity(pid));
	local height = ent.rigidbody:get_size()[2];
	is_crouching = is_crouching or ent.rigidbody:is_crouching();

	local offset_coef = get_offset_coef(is_crouching);
	local offset = height * offset_coef;

	local pos = vec3.add({ player.get_pos(pid) }, { 0, offset, 0 });

	return pos;
end

---@param client neutron.class.client
function module.by_client(client)
	return module.by_pid(client.player.pid, client.player.is_crouching);
end

return module;
