local PlayerDataUpdate = require "shared/net/messages/PlayerDataUpdate"
---@cast PlayerDataUpdate neutron.client.messages.Message

PlayerDataUpdate:on(function(data)
	for cat, values in pairs(data) do
		if cat ~= "_rep_id" then
			for field, value in pairs(values) do
				ns_events.emit("__set_player_data", hud.get_player(), cat, field, value);
			end
		end
	end
end)
