local timer = require('timer')

local shared = {}

--a variable to track if interaction is bound
shared.IS_INTERACTION_BOUND = false

--a function to get a number from a message(it skips the id(aka first number))
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

--a table to store shop requested embeds
shared.REQUESTED_EMBEDS = {}

--a function to find a target in an array
function shared.TABLE_FIND(tbl, target)
    for i, v in ipairs(tbl) do
        --print(i, ' ', v)
        if v == target then
            return i
        end
    end
    return nil
end

return shared