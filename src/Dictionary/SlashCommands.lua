local sql = require("./deps/deps/sqlite3")
local timer = require("timer")
local HowTo = require("./HowTo")

local SlashCommands = {}

do
    local THANK_HOURS_COOLDOWN = 9
    local thanks_cooldowns = {}

    SlashCommands.thank = function(inter, command, args)
        local member = args["user"]
        local member_id = member.id

        if thanks_cooldowns[inter.member.id] then
            inter:replyDeferred(true)
            inter:reply("انتظر " .. thanks_cooldowns[inter.member.id] .. " ساعة قبل أن تشكر عضواً مرة أُخرى 🫂" )
            return
        end

        if inter.member.id == member_id then
            inter:replyDeferred(true)
            inter:reply("ممنوع تشكر نفسك 🫂")
            return
        end

        if member.user.bot then
            inter:replyDeferred(true)
            inter:reply("ممنوع تشكر بوتاً 🤖🫂💀")
            return
        end

        local conn = sql.open("moamen.db")
        local stmt = conn:prepare "insert or ignore into thanks(owner_id, count) values(?, 0)"
        stmt:reset():bind(member_id):step()
        local incr = conn:prepare "update thanks set count = count + 1 where owner_id = ?"
        incr:reset():bind(member_id):step()
        conn:close()

        inter:reply("**🙏🏿 Successfully thanked " ..
            member.username .. "** - and thank you for improving Roblox Studio AR.")
        _G.Client:getChannel(Enums.Channels.Logs.Members_movements):send {
            embed = {
                description = "🙏🏿 The user " .. inter.member.mentionString .. " thanked " .. member.mentionString
            }
        }

        -- Start the cooldown
        thanks_cooldowns[inter.member.id] = THANK_HOURS_COOLDOWN
        for i = THANK_HOURS_COOLDOWN, 0, -1 do
            timer.sleep(1000 * 60 * 60) -- 1 hour
            thanks_cooldowns[inter.member.id] = i
        end
        thanks_cooldowns[inter.member.id] = nil
    end
end

SlashCommands.mythanks = function(inter, command, args)
    local conn = sql.open("moamen.db")
    local stmt = conn:prepare "select count from thanks where owner_id = ?"
    local t = stmt:reset():bind(inter.member.id):step()
    --conn "select * from thanks"
    conn:close()
    inter:reply("You have `" .. tostring(t and t[1] or 0):gsub("L", "") .. "` thanks.")
end

SlashCommands.docs = function(inter, command, args)
    local obj = args["object"]
    local firstCabital_obj = string.upper(obj:sub(1, 1)) .. obj:sub(2)

    if Docs[obj] then
        inter:reply(Docs[obj])
    elseif Docs[firstCabital_obj] then
        inter:reply(Docs[firstCabital_obj])
    else
        inter:reply {
            embed = {
                description = "That class/enum doesn't exist, or at least I can't find it...\nTo view the full docs, visit them [here](https://create.roblox.com/docs/reference/engine)!"
            }
        }
    end
end

SlashCommands.howto = function(inter, command, args)
    local query = args["query"]
    local firstCabital_query = string.upper(query:sub(1, 1)) .. query:sub(2)

    if HowTo[query] then
        inter:reply { embed = HowTo[query] }
    elseif HowTo[firstCabital_query] then
        inter:reply { embed = HowTo[firstCabital_query] }
    else
        inter:replyDeferred(true)
        inter:reply { content = "مالقيت المقال 💀\nتأكد من كتابة اسم المقال بطريقة صحيحة" }
    end
end

return SlashCommands
