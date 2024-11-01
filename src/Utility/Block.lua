local discordia = require("discordia")
local Predicates = require("./Predicates")
local sql = require("./deps/deps/sqlite3")

local Block = {}

local BLOCKED_MESSAGE_ID = nil
function Block.SendBlockedMessage()
    local channel = _G.Client:getChannel(Enums.Channels.Staff.Blocked)

    local msg = channel:send {
        embed = {
            description =
                "تم حظرك بشكل دائم، ولا يوجد وقت محدد لانتهاء الحظر. ستبقى رتبة " .. channel.guild:getRole(Enums.Roles.Blocked).mentionString .. " معك حتى إذا خرجت وعدت للسيرفر. كما أنك لن تتمكن من فتح أي تذكرة.\n\n`mn unblock`\n\n**std::int64_t of blocked members:** `" .. Block.NumberOfBlockedIds() .. "`",
            color = Enums.Colors.Default
        }
    }
    channel:send {
        content = "`message ID: " .. msg.id .. "`"
    }

    BLOCKED_MESSAGE_ID = msg.id
end

function Block.UpdateBlockedMessage()
    if not BLOCKED_MESSAGE_ID then return end
    local channel = _G.Client:getChannel(Enums.Channels.Staff.Blocked)

    local msg = channel:getMessage(BLOCKED_MESSAGE_ID)
    if not msg then return end

    msg:update {
        embed = {
            description =
                "تم حظرك بشكل دائم، ولا يوجد وقت محدد لانتهاء الحظر. ستبقى رتبة " .. channel.guild:getRole(Enums.Roles.Blocked).mentionString .. " معك حتى إذا خرجت وعدت للسيرفر. كما أنك لن تتمكن من فتح أي تذكرة.\n\n`mn unblock`\n\n**std::int64_t of blocked members:** `" .. Block.NumberOfBlockedIds() .. "`",
            color = Enums.Colors.Default,
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

function Block.Append(members_and_ids, channel, forced)
    local conformed_blocks = ""
    local conn = sql.open("moamen.db")
    local stmt = conn:prepare "insert or ignore into blocked_ids(id) values(?)"

    for _, obj in pairs(members_and_ids) do
        if type(obj) == "table" then
            if Predicates.isValidToPunch_v(obj) or forced then
                conformed_blocks = conformed_blocks .. obj.mentionString .. "\n"

                -- Start removing roles in a different thread
                coroutine.wrap(function()
                    Block.Punch(obj)
                end)()

                stmt:reset():bind(obj.id):step()
            end
        elseif type(obj) == "number" then
            stmt:reset():bind(obj):step()
            conformed_blocks = conformed_blocks .. obj .. "\n"
        end
    end
    conn:close()

    channel:send {
        embed = {
            title = "محظورين للتو",
            description = conformed_blocks,
            color = Enums.Colors.Block
        }
    }
    Block.UpdateBlockedMessage()
end

function Block.Remove(members_and_ids)
    local conn = sql.open("moamen.db")
    local stmt = conn:prepare "delete from blocked_ids where id = ?"

    for _, obj in pairs(members_and_ids) do
        if type(obj) == "table" then
            if Block.IsIdBlocked(obj.id) then
                stmt:reset():bind(obj.id):step()

                obj:removeRole(Enums.Roles.Blocked)
                obj:addRole(Enums.Roles.Member)
            end
        elseif type(obj) == "number" then
            if Block.IsIdBlocked(obj) then
                stmt:reset():bind(obj):step()
            end
        end
    end
    conn:close()
end

return Block
