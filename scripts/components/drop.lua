local tsf = entity.transform
local body = entity.rigidbody

local water = block.index("base:water");

function on_update(tps)
  local pos = tsf:get_pos();
  if not pos then return end;
  pos[1] = pos[1] - 1; -- Какого хера.

  if not block.is_replaceable_at(unpack(pos)) then
    tsf:set_pos(vec3.add(pos, { 0, 0.1, 0 }));
  end

  if block.get(unpack(pos)) == water then
    local vel = vec3.add(vec3.mul(body:get_vel(), { 0.85, 0.8, 0.85 }), { 0, 1.2, 0 });

    body:set_vel(vel);
  end
end
