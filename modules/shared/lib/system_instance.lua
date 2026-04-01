return {
  ---@param name str
  ---@return ns.ecs.system
  new = function(name)
    ---@class ns.ecs.system
    ---@field name str
    local instance = {
      name = name
    }

    function instance:init() end;

    ---@return bool
    function instance:should_update(id) return true end;

    function instance:update(id, tps) end;

    function instance:on_player_register(id) end;

    function instance:on_player_remove(id) end;

    return instance;
  end
}
