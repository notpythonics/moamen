local sql = require("./deps/deps/sqlite3")
local timer = require("timer")

local SlashCommands = {}

local thanks_cooldowns = {}
SlashCommands.thank = function(inter, command, args)
    local member = args["user"]
    local member_id = member.id

    if thanks_cooldowns[inter.member.id] then
        inter:replyDeferred(true)
        inter:reply("Cool Down ❌")
        return
    end
    if inter.member.id == member_id then
        inter:replyDeferred(true)
        inter:reply("error ❌")
        return
    end

    local conn = sql.open("moamen.db")
    local stmt = conn:prepare "insert or ignore into thanks(owner_id, count) values(?, 0)"
    stmt:reset():bind(member_id):step()
    local incr = conn:prepare "update thanks set count = count + 1 where owner_id = ?"
    incr:reset():bind(member_id):step()
    conn:close()

    thanks_cooldowns[inter.member.id] = true
    inter:reply("**🙏🏿 Successfully thanked " .. member.username .. "** - and thank you for improving ArabDevHub.")

    timer.sleep(36000000) -- 10 hours
    thanks_cooldowns[inter.member.id] = nil
end

SlashCommands.mythanks = function(inter, command, args)
    local conn = sql.open("moamen.db")
    local stmt = conn:prepare "select count from thanks where owner_id = ?"
    local t = stmt:reset():bind(inter.member.id):step()
    --conn "select * from thanks"
    conn:close()
    inter:reply("You have `" .. tostring(t and t[1] or 0):gsub("L", "") .. "` thanks.")
end

return SlashCommands
