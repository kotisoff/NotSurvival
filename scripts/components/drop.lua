local tsf = entity.transform

function on_update(tps)
  local pos = tsf:get_pos();
  if block.get(unpack(pos)) ~= 0 then
    tsf:set_pos(vec3.add(pos, { 0, 0.1, 0 }));
  end
end
