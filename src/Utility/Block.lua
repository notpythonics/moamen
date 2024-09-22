local discordia = require("discordia")
local Predicates = require("./Predicates")

local Block = {}

local blocked_IDs = {}

function Block.IsIdBlocked(target_id)
    for i, id in pairs(blocked_IDs) do
        if id == target_id then
            return i -- This is true
        end
    end
    return false
end

function Block.Punch(member)
    member:addRole(Enums.Roles.Blocked)
    for _, role in pairs(member.roles) do
        if role.id ~= Enums.Roles.Blocked then
            member:removeRole(role.id)
        end
    end
end

function Block.NumberOfBlockedIds()
    return #blocked_IDs
end

function Block.Append(members, channel)
    local conformed_blocks = ""
    for _, member in pairs(members) do
        if Predicates.isValidToPunch(member) then
            conformed_blocks = conformed_blocks .. member.mentionString .. "\n"
            -- Start removing roles in a different thread
            coroutine.wrap(function()
                Block.Punch(member)
            end)()

            if not Block.IsIdBlocked(member.id) then
                table.insert(blocked_IDs, member.id)
            end
        end
    end
    if conformed_blocks == "" then
        return
    end
    channel:send {
        embed = {
            title = "محظورين للتو",
            description = conformed_blocks,
            color = discordia.Color.fromRGB(102, 0, 51).value
        }
    }
end

function Block.Remove(members)
    for _, member in pairs(members) do
        local index = Block.IsIdBlocked(member.id)
        if index then
            table.remove(blocked_IDs, index)
            member:removeRole(Enums.Roles.Blocked)
            member:addRole(Enums.Roles.Member)
        end
    end
end

function Block.Blocked_IDs(channel)
    local str = "```"
    for _, id in ipairs(blocked_IDs) do
        str = str .. id .. " "
    end
    str = str .. "```"

    -- If no blocked IDs's found
    if str == "``````" then
        str = "لا محظورين"
    end

    channel:send { content = str }
end

return Block
