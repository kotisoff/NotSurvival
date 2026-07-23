local system = require "shared/lib/system_instance";
local item_props = require "shared/api/v1/item_props"

---@class ns.ecs.system.server.combat:ns.ecs.system
local CombatSystem = system.new("ns.system.combat");

function CombatSystem:init()
  ---@type number[]
  self.cooldown = {};
  ---@type number[]
  self.slots = {};
end

function CombatSystem:on_player_register(id)
  self.cooldown[id] = 1.0;
  self.slots[id] = -1;
end

function CombatSystem:on_player_remove(id)
  self.cooldown[id] = nil;
  self.slots[id] = 0;
end

function CombatSystem:update(id, tps)
  local cooldown = self.cooldown[id];
  local invid, slot = player.get_inventory(id);

  if self.slots[id] ~= slot then
    self.slots[id] = slot;
    self:consume_cooldown(id);
  end

  if cooldown < 1.0 then
    local item_id = inventory.get(invid, slot);
    local weapon = item_props.get_weapon(item_id);

    cooldown = math.clamp(cooldown + weapon.speed * (1 / tps), 0.0, 1.0);
  end
end

function CombatSystem:consume_cooldown(id)
  local cooldown = self.cooldown[id];
  self.cooldown[id] = 0;
  return cooldown;
end

return CombatSystem;
