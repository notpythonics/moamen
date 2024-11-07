local discordia = require("discordia")
local discordia_components = require("discordia-components")
local tools = require("discordia-slash").util.tools()
local Components = discordia_components.Components
local Block = require("../Utility/Block")
local Predicates = require("../Utility/Predicates")
local RoleAdjuster = require("../Utility/RoleAdjuster")
local sql = require("./deps/deps/sqlite3")
local timer = require("timer")
local http = require('coro-http')
local C_Command = require("../Classes/Command")

local Commands = {}

local function convert_to_members_or_ids(MessageHandlerObj)
    local members_and_ids = {}
    for _, user in pairs(MessageHandlerObj.mentionedUsers) do
        local member = MessageHandlerObj.guild:getMember(user.id)
        if member then
            table.insert(members_and_ids, member)
        else
            table.insert(members_and_ids, user.id)
        end
    end
    return members_and_ids
end

-- Create Guild APP Commands
Commands.creategpc = C_Command.new(Predicates.isOwner_v, function(MessageHandlerObj)
    Commands.deletegpc:Execute(MessageHandlerObj)
    do
        local slashCommand = tools.slashCommand("thank", "اشكر عضواً لمساعدته لك")
        local option = tools.user("user", "من العضو الذي تود توجيه الشكر له؟")
        option:setRequired(true)
        slashCommand:addOption(option)

        Client:createGuildApplicationCommand(MessageHandlerObj.guild.id, slashCommand)
    end

    do
        local slashCommand = tools.slashCommand("mythanks", "اعرض عدد الشكر الذي حصلت عليه")
        Client:createGuildApplicationCommand(MessageHandlerObj.guild.id, slashCommand)
    end

    do
        local slashCommand = tools.slashCommand("docs", "Check the documentation!")
        local option = tools.string("object", "Pick a class/enum to read the docs on!")
        option:setAutocomplete(true)
        option:setRequired(true)
        slashCommand:addOption(option)

        Client:createGuildApplicationCommand(MessageHandlerObj.guild.id, slashCommand)
    end

    do
        local slashCommand = tools.slashCommand("howto", "استرجع مقالاً من طاولة كيفَ")
        local option = tools.string("query", "اسم المقال")
        option:setAutocomplete(true)
        option:setRequired(true)
        slashCommand:addOption(option)

        Client:createGuildApplicationCommand(MessageHandlerObj.guild.id, slashCommand)
    end

    MessageHandlerObj.channel:send { content = "الأوامر جاهزة يا مؤمن" }
end)

-- Delete Guild APP Commands
Commands.deletegpc = C_Command.new(Predicates.isOwner_v, function(MessageHandlerObj)
    local commands = Client:getGuildApplicationCommands(MessageHandlerObj.guild.id)

    for commandId in pairs(commands) do
        Client:deleteGuildApplicationCommand(MessageHandlerObj.guild.id, commandId)
    end
end)

Commands.their_thanks = C_Command.new(Predicates.isModerator_v, function(MessageHandlerObj)
    local mentionedUser = MessageHandlerObj.mentionedUsers.first
    if not mentionedUser then return end

    local conn = sql.open("moamen.db")
    local stmt = conn:prepare "select count from thanks where owner_id = ?"
    local t = stmt:reset():bind(mentionedUser.id):step()
    conn:close()
    --conn "select * from thanks"
    MessageHandlerObj.channel:send {
        content = mentionedUser.username .. " has `" .. tostring(t and t[1] or 0):gsub("L", "") .. "` thanks.",
        reference = {
            message = MessageHandlerObj.message,
            mention = false,
        }
    }
end)

Commands.block = C_Command.new(Predicates.isOwner_v, function(MessageHandlerObj)
    Block.Append(convert_to_members_or_ids(MessageHandlerObj), MessageHandlerObj.channel, false)
end)

Commands.fblock = C_Command.new(Predicates.isOwner_v, function(MessageHandlerObj)
    Block.Append(convert_to_members_or_ids(MessageHandlerObj), MessageHandlerObj.channel, true)
end)

Commands.unblock = C_Command.new(Predicates.isOwner_v, function(MessageHandlerObj)
    Block.Remove(convert_to_members_or_ids(MessageHandlerObj))
end)

Commands.is_id_blocked = C_Command.new(Predicates.isMember_v, function(MessageHandlerObj)
    MessageHandlerObj.channel:send {
        content =
            Block.IsIdBlocked(MessageHandlerObj.content:match("%d+")) and "True `1`" or "False `0`",
    }
end)

Commands.blocked_members = C_Command.new(Predicates.isMember_v, function(MessageHandlerObj)
    MessageHandlerObj.channel:send
    { content = "`" .. Block.NumberOfBlockedIds() .. "` blocked member" }
end)

Commands.send_blocked_message = C_Command.new(Predicates.isOwner_v,
    function(MessageHandlerObj) Block.SendBlockedMessage() end)
Commands.update_blocked_message = C_Command.new(Predicates.isOwner_v,
    function(MessageHandlerObj) Block.UpdateBlockedMessage() end)

Commands.header = C_Command.new(Predicates.isModerator_v, function(MessageHandlerObj)
    MessageHandlerObj.channel:send {
        embed = {
            image = { url = Enums.Images.Header },
            color = Enums.Colors.Default
        }
    }
end)

Commands.bigheader = C_Command.new(Predicates.isModerator_v, function(MessageHandlerObj)
    MessageHandlerObj.channel:send {
        embed = {
            image = { url = Enums.Images.BigHeader },
            color = Enums.Colors.Default
        }
    }
end)

Commands.bots_entry = C_Command.new(Predicates.isMember_v, function(MessageHandlerObj)
    MessageHandlerObj.channel:send
    { content = _G.IsBots_Entry_Allowed and "allowed `1`" or "disallowed `0`" }
end)

Commands.allow_bots_entry = C_Command.new(Predicates.isOwner_v,
    function(MessageHandlerObj) _G.IsBots_Entry_Allowed = true end)

Commands.disallow_bots_entry = C_Command.new(Predicates.isOwner_v,
    function(MessageHandlerObj) _G.IsBots_Entry_Allowed = false end)

Commands.lock = C_Command.new(Predicates.isModerator_v, function(MessageHandlerObj)
    local channel = MessageHandlerObj.channel

    channel:getPermissionOverwriteFor(MessageHandlerObj.guild:getRole(Enums.Roles.Everyone))
        :denyPermissions("sendMessages")
    channel:send {
        embed = {
            description = "القناة غُلقت مؤقتاً\n`mn unlock` لفتح القناة",
            color = Enums.Colors.Permission
        }
    }
end)

Commands.unlock = C_Command.new(Predicates.isModerator_v, function(MessageHandlerObj)
    local channel = MessageHandlerObj.channel

    channel:getPermissionOverwriteFor(MessageHandlerObj.guild:getRole(Enums.Roles.Everyone))
        :allowPermissions("sendMessages")
    channel:send {
        embed = {
            description = "القناة لم تعد مغلقة\n`mn lock` لغلق القناة",
            color = Enums.Colors.Permission
        }
    }
end)

Commands.roles_embed = C_Command.new(Predicates.isOwner_v, function(MessageHandlerObj)
    local guild = MessageHandlerObj.guild
    local channel = MessageHandlerObj.channel

    local roles_options = discordia.Components {
        discordia.SelectMenu("roles_embed") -- id
            :placeholder "اختر الرتبة التي تريد التقديم عليها"
            :option("مبرمج", "programmer", "هذه الرتبة لها 4 تصنيفات", false, guild:getEmoji(Enums.Emojis.PROGRAMMER4))
            :option("بلدر", "builder", "هذه الرتبة لها 4 تصنيفات", false, guild:getEmoji(Enums.Emojis.BUILDER4))
            :option("مودلر", "modeler", "هذه الرتبة لها 3 تصنيفات", false, guild:getEmoji(Enums.Emojis.MODELER1))
            :option("مصمم جرافيك", "gfx", "هذه الرتبة لها 3 تصنيفات", false, guild:getEmoji(Enums.Emojis.GFX1))
            :option("مؤثرات بصرية", "vfx", "هذه الرتبة لها 3 تصنيفات", false, guild:getEmoji(Enums.Emojis.VFX1))
            :option("أنيميشن", "animation", "هذه الرتبة لها 3 تصنيفات", false, guild:getEmoji(Enums.Emojis.ANIMATION1))
            :option("واجهة مستخدم", "ui", "هذه الرتبة لها 3 تصنيفات", false, guild:getEmoji(Enums.Emojis.UI1))
    }

    channel:sendComponents({
        embed = {
            title = "طلب رتب المطورين",
            description =
            "يمكنك هنا التقدم للحصول على احدى رتب المطورين\nتنقسم الرتب إلى ثلاث او اربعة مستويات، كل منها يعكس مستوى المهارة والخبرة\n\n🔻 Scripter I\n🔻 Scripter II\n🔻 Scripter III\n🔻 Scripter IIII\n\nسيتم تقييم طلبك بناءً على اعمالك المرسلة\nحظًا موفقًا في تقديمك!",
            image = { url = Enums.Images.Header },
            color = Enums.Colors.Default
        }
    }, roles_options)
end)

Commands.rules_embed = C_Command.new(Predicates.isOwner_v, function(MessageHandlerObj)
    local channel = MessageHandlerObj.channel

    channel:send {
        embed = {
            image = { url = Enums.Images.Header },
            color = Enums.Colors.Default
        }
    }

    channel:send {
        embed = {
            description =
            [[استخدم [الفطرة السليمة](https://dorar.net/aqeeda/259).
            عامل زملائك بالاحترام. كن لطيفًا. لا توجد أسئلة غبية.
            نتسامح مع الإهانات العنصرية، التمييز الجنسي، أو أي شكل من أشكال التعصب.
            لا تمنشن الأعضاء أو ترسل لهم رسائل خاصة. فقط قم بنشر سؤالك في إحدى قنوات المساعدة.

            لا تنشر إجابات تم إنشاؤها بواسطة الذكاء الاصطناعي، ولا تطلب المساعدة في الأكواد التي تم إنشاؤها بواسطة الذكاء الاصطناعي.

            لا تسأل إذا كان يمكنك السؤال - فقط اسأل. من المحتمل أن يكون لدى شخص ما الإجابة وسيكون سعيدًا بمساعدتك.

            لا تتردد في نشر رسالتك حتى لو كان هناك مستخدمون آخرون يتحدثون.
            إذا لم تحصل على رد فوري، فهذا لا يعني أن سؤالك قد تم تجاهله.
            إذا كان الأمر محبطًا للغاية، يمكنك إنشاء thread في [مساعدة أعمق](https://discord.com/channels/1028991149806981140/1193100820162543636)

            يمنع نشر روابط سيرفرات، وتمنع المتاجرة خارج رومات التجارة.
            يمنع نشر أو اعادة بيع ما بيعَ لك في رومات التجارة.]],
            image = { url = Enums.Images.Header },
            color = Enums.Colors.Default
        }
    }
end)

Commands.shop_embeds = C_Command.new(Predicates.isOwner_v, function(MessageHandlerObj)
    local function CraeteButtonComponentWithId(id)
        return discordia.Components {
            discordia.Button(id) -- id
                :label "إنشاء"
                :style "success"
        }
    end

    _G.Client:getChannel(Enums.Channels.fh_embed_channel):sendComponents({
        embed = {
            title = "عرض خدمة",
            description = "اعرض خدمتك التطويرية للربح منها"
        }
    }, CraeteButtonComponentWithId("fh"))

    _G.Client:getChannel(Enums.Channels.sell_embed_channel):sendComponents({
        embed = {
            title = "بيع عمل",
            description = "اعرض أعمالك الإبداعية للبيع وحقق ارباح مادية"
        }
    }, CraeteButtonComponentWithId("sell"))

    _G.Client:getChannel(Enums.Channels.lfd_embed_channel):sendComponents({
        embed = {
            title = "طلب خدمة",
            description = "ابحث عن مطورين لمساعدتك في تطوير مشروعك أو لعبتك"
        }
    }, CraeteButtonComponentWithId("lfd"))
end)

Commands.fe_embed = C_Command.new(Predicates.isOwner_v, function(MessageHandlerObj)
    if not MessageHandlerObj.message then return end
    local replied_to_msg = MessageHandlerObj.message.referencedMessage

    if not replied_to_msg then
        MessageHandlerObj.message:reply("please use this command as a reply to a message")
        return
    end

    local embed = {
        author = {
            name = replied_to_msg.author.username,
            icon_url = replied_to_msg.author.avatarURL
        },
        description = "made by " .. replied_to_msg.author.mentionString,
        image = { url = Enums.Images.Header }
    }

    -- Check for links
    local links = MessageHandlerObj.FindLinks(replied_to_msg.content)
    if #links > 0 then
        embed.description = embed.description .. "\n" .. string.format("[[video]](%s)", links[1]:gsub(" ", ""))
    end
    local f_channel = _G.Client:getChannel(Enums.Channels.fetured)

    -- Check for image attachments
    local attachments = replied_to_msg.attachments -- A table of attachments(an attachment is any file like an image)
    if attachments then
        if attachments[1].content_type:match("image") then
            embed.image = { url = attachments[1].url }
        end
        if attachments[1].content_type:match("video") then
            -- http request the file's body
            local res, body = http.request("GET", attachments[1].url)
            f_channel:send {
                file = {
                    "vid.mp4",
                    body
                },
                embed = embed
            }
            return
        end
    end

    f_channel:send { embed = embed }
end)

Commands.give_role = C_Command.new(Predicates.isRolesApprover_v, function(MessageHandlerObj)
    local function FindFirstEnumRole(content)
        for roleName, id in pairs(Enums.Roles.Levels) do
            --print(roleName, content)
            if content:lower():match(roleName:lower()) then
                return roleName:upper()
            end
        end
    end

    local first_mention = MessageHandlerObj.mentionedUsers.first
    local f_member = first_mention and MessageHandlerObj.guild:getMember(first_mention.id)
    if not f_member then
        MessageHandlerObj.channel:send
        { content = "please provide a member" }
        return
    end

    local f_roleName = FindFirstEnumRole(MessageHandlerObj.content)
    if not f_roleName then
        MessageHandlerObj.channel:send
        { content = "please provide a role enum" }
        return
    end

    RoleAdjuster.RemoveTierRoles(f_member, f_roleName)
    RoleAdjuster.SetTierRole(f_member, f_roleName)

    MessageHandlerObj.channel:send {
        embed = {
            title = f_member.username .. "أٌعطا رتبة ",
            description = "الرتب المتوافقة حٌذفت" .. "\n" .. "الرتبة المعطاة هي " .. MessageHandlerObj.guild:getRole(Enums.Roles.Levels[f_roleName]).mentionString,
            color = Enums.Colors.Giving_Roles,
        }
    }
end)

Commands.mute = C_Command.new(Predicates.isModerator_v, function(MessageHandlerObj)
    -- It ignores large numbers(IDs?)
    local function FindDuration(content)
        local temp_content = content
        local suffix = content:match("h") or content:match("d") or "m"
        while true do
            local num = temp_content:match("%d+")
            if not num then
                return "دقيقة", 3 * 60
            end
            temp_content = temp_content:gsub(num, "")
            num = tonumber(num)

            if num <= 10080 then
                if suffix == "h" then
                    return "ساعة", num * 60 * 60
                elseif suffix == "d" then
                    return "يوم", num * 60 * 60 * 24
                else
                    return "دقيقة", num * 60
                end
            end
        end
    end

    local suff, duration = FindDuration(MessageHandlerObj.content)
    duration = math.min(duration, 604800)

    local conformed_timeouts = ""
    local members_and_ids = convert_to_members_or_ids(MessageHandlerObj)

    for _, obj in pairs(members_and_ids) do
        if type(obj) == "table" then
            if Predicates.isValidToPunch_v(obj) then
                obj:timeoutFor(duration)
                conformed_timeouts = conformed_timeouts .. obj.mentionString .. "\n"
                local p_channel = obj.user:getPrivateChannel()
                if p_channel then
                    p_channel:send {
                        embed = {
                            title = "انكتمت للتو",
                            description = "إقرأ [القوانين](https://discord.com/channels/1028991149806981140/1028991151467933751) لتفادي الكتم. وتذكر أن الحظر قد يكون الخطوة التالية.",
                            color = Enums.Colors.ModeratorAction,
                        }
                    }
                end
            end
        end
    end

    if suff == "ساعة" then
        duration = duration / 60 / 60
    elseif suff == "يوم" then
        duration = duration / 60 / 60 / 24
    else
        duration = duration / 60
    end

    MessageHandlerObj.channel:send {
        embed = {
            title = "مجموعة انكتمت ل" .. duration .. " " .. suff,
            description = conformed_timeouts,
            color = Enums.Colors.ModeratorAction,
            footer = { text = "👨🏿‍🌾" }
        }
    }
end)

Commands.unmute = C_Command.new(Predicates.isModerator_v, function(MessageHandlerObj)
    local members_and_ids = convert_to_members_or_ids(MessageHandlerObj)
    for _, obj in pairs(members_and_ids) do
        if type(obj) == "table" then
            obj:removeTimeout()
        end
    end
end)

return Commands
