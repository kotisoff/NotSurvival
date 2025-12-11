local module = {
  systems = {},
}

-- todo: подумать о ecs. вероятно эту систему можно расширить до других мобов помимо игрока и влиять системами на них

function module:register_system(system_name, required_comps, update_fn)
  self.systems[system_name] = {
    required = required_comps,
    update = update_fn
  }
end

function module:update(tps)
  for _, system in pairs(self.systems) do
    for _, player_id in ipairs(player.get_all()) do
      system.update(player_id, tps)
    end
  end
end

return module
