require("utils");

function compose_fragment_path(packid, genid)
  return packid .. ":generators/" .. genid .. ".files/fragments";
end

local treeFragments = {};
events.on(PACK_ID .. ":first_tick", function()
  local generator = {};
  for name in world.get_generator():gmatch("[^:]+") do
    table.insert(generator, name);
  end
  local packid, genid = unpack(generator);

  local fragmentsDir = compose_fragment_path(packid, genid);
  if not file.exists(fragmentsDir) then
    fragmentsDir = compose_fragment_path("base", "demo"); -- Fallback
  end

  local fragmentFiles = file.list(fragmentsDir);

  for _, fragment in pairs(fragmentFiles) do
    if fragment:find("^" .. fragmentsDir .. "/tree") ~= nil then
      table.insert(treeFragments, fragment);
    end
  end
end)

function load_random_tree()
  local index = math.random(#treeFragments);
  return generation.load_fragment(treeFragments[index]);
end

local function grow(x, y, z)
  not_utils.create_coroutine(function()
    block.set(x, y, z, block.index("core:air"));
    not_utils.sleep(0.01);

    local fragment = load_random_tree();

    local size = fragment.size;
    local offset = vec3.mul(size, { -0.5, 0, -0.5 });

    fragment:place(vec3.add({ x, y, z }, offset), math.random(7));
  end)
end

function on_random_update(x, y, z)
  grow(x, y, z);
end

function on_interact(x, y, z, pid)
  grow(x, y, z);
end
