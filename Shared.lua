local timer = require('timer')
local Enums = require('./Enums')

local shared = {}

-- a variable to track if roles_embed is sent
shared.IS_ROLES_EMBED_SENT = false

-- a function to get a number from a message(it skips the id(aka first number))
function shared.GET_DURATION(str)
    local id_num = str:match('%d+')
    if id_num then
        local _, endp = string.find(str, id_num)
        str = str:sub(endp+1)
        str = str:match('%d+')
        if str then
            return tonumber(str)
        end
    end
    return 60
end

-- a function to find a target in a table
function shared.TABLE_FIND(tbl, target)
    for i, v in ipairs(tbl) do
        --print(i, ' ', v)
        if v == target then
            return i
        end
    end
    return nil
end

-- a table to store debounced member IDs
shared.DEBOUNCE_MEMBERS = {}

-- a function to remove a debounced member
function shared.REMOVE_DEBOUNCE_FROM_IN(id, seconds)
    local co = coroutine.create(function ()
        timer.sleep(seconds*1000)
        table.remove(shared.DEBOUNCE_MEMBERS, shared.TABLE_FIND(shared.DEBOUNCE_MEMBERS, id))
    end)

    coroutine.resume(co)
end


return shared