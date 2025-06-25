local data = require "shared/player/data"
local mp = require "shared/utils/not_utils".multiplayer.api.server
local packets = require "shared/utils/declarations/packets"
local pack_id = "not_survival"

local module = {}

function module.get_hunger(pid)
  return data.get_data(pid, "hunger")
end

function module.get_max_hunger(pid)
  return data.get_attributes(pid, "hunger")
end

function module.get_saturation(pid)
  return data.get_data(pid, "saturation")
end

function module.get_max_saturation(pid)
  return data.get_attributes(pid, "saturation")
end

---@param field "hunger"|"saturation"
function module.update(pid, field)
  local client = mp.accounts.get_client(mp.accounts.get_account_by_name(player.get_name(pid)))
  mp.events.tell(pack_id, packets.update_player_data, client,
    mp.bson.serialize({
      data.get_category_index("data"),
      data.get_field_index("data", field),
      module["get_" .. field](pid)
    })
  )
end

function module.set_hunger(pid, amount)
  local max = module.get_max_hunger(pid)
  data.set_field(pid, "data", "hunger", math.clamp(amount, 0, max))
  module.update(pid, "hunger")
end

function module.set_saturation(pid, amount)
  local max = module.get_max_saturation(pid)
  data.set_field(pid, "data", "saturation", math.clamp(amount, 0, max))
  module.update(pid, "saturation")
end

function module.full(pid)
  local max_h = module.get_max_hunger(pid)
  local max_s = module.get_max_saturation(pid)

  module.set_hunger(pid, max_h)
  module.set_saturation(pid, max_s)
end

function module.add(pid, hunger, saturation)
  if hunger and hunger ~= 0 then
    local h = module.get_hunger(pid) + (hunger or 0)
    module.set_hunger(pid, h)
  end
  if saturation and hunger ~= 0 then
    local s = module.get_saturation(pid) + (saturation or 0)
    module.set_saturation(pid, s)
  end
end

function module.consume(pid, amount)
  local s = module.get_saturation(pid)

  local new_s = s - amount
  if new_s < 0 then
    local abs_s = math.abs(new_s)
    local max_h = module.get_max_hunger(pid)

    module.set_saturation(pid, 0)

    local consumed = math.ceil(abs_s / max_h)
    if consumed < 1 then consumed = 1 end

    module.add(pid, -consumed)
  else
    module.set_saturation(pid, new_s)
  end
end

return module
