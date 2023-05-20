local M = {}


M.update_max_dt = 0
M.need_update = false
M.ecs_update_dt = 0
M.ecs_update_dt_max_second= 0

M.game_entities = 0

function M.game_reset()
    M.game_entities = 0
end


function M.update(dt)
    if(M.need_update)then
        M.need_update = false
    end
    M.update_max_dt = M.update_max_dt -dt
    if(M.update_max_dt <0)then
        M.update_max_dt = 1
        M.need_update = true
    end
end

function M.update_ecs_dt(dt)
    if(M.need_update)then
        M.ecs_update_dt_max_second = dt
    end
    M.ecs_update_dt = dt
    if(dt > M.ecs_update_dt_max_second)then
        M.ecs_update_dt_max_second = dt
    end
end

return M