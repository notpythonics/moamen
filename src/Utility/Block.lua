local discordia = require("discordia")
local Predicates = require("./Predicates")
local sql = require("./deps/deps/sqlite3")

local Block = {}

local blocked_messaged_id = nil
function Block.SendBlockedMessage()
    local channel = _G.Client:getChannel(Enums.Channels.Staff.Blocked)

    local msg = channel:send {
        embed = {
            description =
                "تم حظرك بشكل دائم، ولا يوجد وقت محدد لانتهاء الحظر. ستبقى رتبة " .. channel.guild:getRole(Enums.Roles.Blocked).mentionString .. " معك حتى إذا خرجت وعدت للسيرفر. كما أنك لن تتمكن من فتح أي تذكرة.\n\n`mn unblock`\n\n**std::int64_t of blocked members:** `" .. Block.NumberOfBlockedIds() .. "`",
            color = discordia.Color.fromRGB(1, 1, 1).value
        }
    }
    channel:send {
        content = "`message ID: " .. msg.id .. "`"
    }

    blocked_messaged_id = msg.id
end

function Block.UpdateBlockedMessage()
    if not blocked_messaged_id then return end
    local channel = _G.Client:getChannel(Enums.Channels.Staff.Blocked)

    local msg = channel:getMessage(blocked_messaged_id)
    if not msg then return end

    msg:update {
        embed = {
            description =
                "تم حظرك بشكل دائم، ولا يوجد وقت محدد لانتهاء الحظر. ستبقى رتبة " .. channel.guild:getRole(Enums.Roles.Blocked).mentionString .. " معك حتى إذا خرجت وعدت للسيرفر. كما أنك لن تتمكن من فتح أي تذكرة.\n\n`mn unblock`\n\n**std::int64_t of blocked members:** `" .. Block.NumberOfBlockedIds() .. "`",
            color = discordia.Color.fromRGB(1, 1, 1).value,
        }
    }
end

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
    return tostring(t[1][1]):gsub("L", "")
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
    Block.UpdateBlockedMessage()
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
