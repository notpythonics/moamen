local discordia = require("discordia")
local Predicates = require("./Predicates")
local sql = require("./deps/deps/sqlite3")

local Block = {}

function Block.IsIdBlocked(target_id)
    local conn = sql.open("moamen.db")
    local stmt = conn:prepare "select * from blocked_ids where id = ?"
    local t = stmt:reset():bind(target_id):step()
    conn:close()
    return t and true or false
end

function Block.Punch(member)
    if not member then return end
    member:addRole(Enums.Roles.Blocked)
    for _, role in pairs(member.roles) do
        if role.id ~= Enums.Roles.Blocked then
            if not member then return end
            member:removeRole(role.id)
        end
    end
end

function Block.NumberOfBlockedIds()
    local conn = sql.open("moamen.db")
    local t = conn:exec "select count(*) from blocked_ids"
    --conn "select * from blocked_ids"
    conn:close()
    return t[1][1]
end

function Block.Append(members, channel, forced)
    local conformed_blocks = ""
    local conn = sql.open("moamen.db")
    local stmt = conn:prepare "insert or ignore into blocked_ids(id) values(?)"

    for _, member in pairs(members) do
        if Predicates.isValidToPunch(member) or forced then
            conformed_blocks = conformed_blocks .. member.mentionString .. "\n"

            -- Start removing roles in a different thread
            coroutine.wrap(function()
                Block.Punch(member)
            end)()

            stmt:reset():bind(member.id):step()
        end
    end
    conn:close()
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
    local conn = sql.open("moamen.db")
    local stmt = conn:prepare "delete from blocked_ids where id = ?"

    for _, member in pairs(members) do
        local index = Block.IsIdBlocked(member.id)
        if index then
            stmt:reset():bind(member.id):step()

            member:removeRole(Enums.Roles.Blocked)
            member:addRole(Enums.Roles.Member)
        end
    end
    conn:close()
end

return Block
