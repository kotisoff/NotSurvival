local function on_ice_broken(blockid, x, y, z, pid)
  block.set(x, y, z, block.index("base:water"));
end

return {
  on_ice_broken = on_ice_broken
}
