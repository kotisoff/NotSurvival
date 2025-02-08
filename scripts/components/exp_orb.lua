---@diagnostic disable: undefined-field
local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

local api = require "api";
local exp = api.survival.experience;

local expdata = SAVED_DATA.exp or ARGS.exp or 0;

function on_save()
    SAVED_DATA.exp = expdata;
end

local target = -1;
local timer = 0.3;

function on_sensor_enter(index, oid)
    local playerid = hud.get_player()
    local playerentity = player.get_entity(playerid)
    if timer < 0.0 and oid == playerentity and index == 0 then
        entity:despawn();
        exp.give(playerid, expdata);
        audio.play_sound_2d("not_survival/random/orb", 0.4, 0.8 + math.random() * 0.4, "regular");
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
    local dst_pos = { player.get_pos(hud.get_player()) };
    local entity_pos = tsf:get_pos()
    local direction = vec3.div(vec3.sub(dst_pos, entity_pos), math.sqrt(vec3.length(vec3.sub(dst_pos, entity_pos))))
    local rotation_x = math.atan2(-direction[1], -direction[3]) * 180.0 / math.pi
    local rotation_y = math.atan(direction[2]) * 180.0 / math.pi

    local matrix = mat4.rotate({ 0, 1, 0 }, rotation_x);
    matrix = mat4.rotate(matrix, { 1, 0, 0 }, rotation_y);

    tsf:set_rot(matrix);
end

function on_update(tps)
    timer = timer - 1.0 / tps
    if target ~= -1 then
        if timer > 0.0 then
            return
        end
        local dir = vec3.sub(entities.get(target).transform:get_pos(), tsf:get_pos())
        local distance = math.clamp(vec3.length(dir) - 1, 0.8, 5);

        local speed = 10 / distance;

        vec3.normalize(dir, dir);
        vec3.mul(dir, speed, dir);

        if distance > 2 then dir[2] = dir[2] * -1.1 end;

        body:set_vel(dir)
    end
end
