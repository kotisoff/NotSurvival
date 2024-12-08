local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

target = -1
timer = 0.3

local expdata = SAVED_DATA.exp or ARGS.exp;

local DROP_SCALE = 0.3
local scale = { 1, 1, 1 }

function on_save()
    SAVED_DATA.exp = expdata;
end

do -- setup visuals
    local matrix = mat4.idt()
    rig:set_model(0, "not_survival:coal.model")
    local bodysize = math.min(scale[1], scale[2], scale[3]) * DROP_SCALE
    body:set_size({ scale[1] * DROP_SCALE, bodysize, scale[3] * DROP_SCALE })
    rig:set_matrix(0, matrix)
end

function on_sensor_enter(index, oid)
    local playerid = hud.get_player()
    local playerentity = player.get_entity(playerid)
    if oid == playerentity and index == 0 then
        entity:despawn()
        exp.give(playerid, expdata)
        audio.play_sound_2d("events/random/orb", 0.5, 0.8 + math.random() * 0.4, "regular")
    end
    if index == 1 and oid == playerentity then
        target = oid
    end
end

function on_sensor_exit(index, oid)
    if oid == target and index == 1 then
        target = -1
    end
end

function on_render()
    local pid = hud.get_player()
    local ppos = player.get_pos(pid) -- позиция игрока
    local epos = tsf:get_pos()       -- позиция энтити

    -- Создаем матрицу, которая смотрит из позиции энтити на позицию игрока
    local up = { 0, 1, 0 } -- вектор "вверх" (можно использовать {0, 1, 0} для Y вверх)
    local matrix = mat4.look_at(epos, ppos, up)

    -- Устанавливаем матрицу для вашей энтити
    rig:set_matrix(0, matrix)
end

function on_update(tps)
    timer = timer - 1.0 / tps
    if target ~= -1 then
        if timer > 0.0 then
            return
        end
        local dir = vec3.sub(entities.get(target).transform:get_pos(), tsf:get_pos())
        vec3.normalize(dir, dir)
        vec3.mul(dir, 10.0, dir)
        body:set_vel(dir)
    end
end
