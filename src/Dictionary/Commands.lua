local discordia = require("discordia")
local discordia_components = require("discordia-components")
local tools = require("discordia-slash").util.tools()
local Components = discordia_components.Components

local Wiki = require("./Wiki")
local Block = require("../Utility/Block")
local Predicates = require("../Utility/Predicates")
local RoleAdjuster = require("../Classes/RoleAdjuster")
local sql = require("./deps/deps/sqlite3")
local timer = require("timer")

local Commands = {}

local function ConvertToMembers(MessageHandlerObj)
    local members = {}
    for _, user in pairs(MessageHandlerObj.mentionedUsers) do
        table.insert(members, MessageHandlerObj.guild:getMember(user.id))
    end
    return members
end

-- Create guild app cmds
Commands.creategpc = function(MessageHandlerObj)
    if not Predicates.isOwner_v(MessageHandlerObj.author_member) then return end
    do
        local slashCommand = tools.slashCommand("thank", "Thank a user for helping you!")
        local option = tools.user("user", "Who do you want to thank?")
        option:setRequired(true)
        slashCommand:addOption(option)

        Client:createGuildApplicationCommand(MessageHandlerObj.guild.id, slashCommand)
    end

    local slashCommand = tools.slashCommand("mythanks", "See how many thanks you have.")
    Client:createGuildApplicationCommand(MessageHandlerObj.guild.id, slashCommand)
end

-- Delete guild app cmds
Commands.deletegpc = function(MessageHandlerObj)
    if not Predicates.isOwner_v(MessageHandlerObj.author_member) then return end
    local commands = Client:getGuildApplicationCommands(MessageHandlerObj.guild.id)

    for commandId in pairs(commands) do
        Client:deleteGuildApplicationCommand(MessageHandlerObj.guild.id, commandId)
    end
end

-- TheirThanks
Commands.their_thanks = function(MessageHandlerObj)
    if not Predicates.isModerator_v(MessageHandlerObj.author_member) then return end
    local mentionedUser = MessageHandlerObj.mentionedUsers.first
    if not mentionedUser then return end
    local conn = sql.open("moamen.db")
    local stmt = conn:prepare "select count from thanks where owner_id = ?"
    local t = stmt:reset():bind(mentionedUser.id):step()
    conn:close()
    --conn "select * from thanks"
    MessageHandlerObj.channel:send {
        content = mentionedUser.username .. " has thanks: `" .. tostring(t and t[1] or 0):gsub("L", "") .. "`",
        reference = {
            message = MessageHandlerObj.message,
            mention = false,
        }
    }
end

-- Block
Commands.block = function(MessageHandlerObj)
    if Predicates.isModerator_v(MessageHandlerObj.author_member) then
        Block.Append(ConvertToMembers(MessageHandlerObj), MessageHandlerObj.channel)
    end
end

-- Fblock
Commands.fblock = function(MessageHandlerObj)
    if Predicates.isOwner_v(MessageHandlerObj.author_member) then
        Block.Append(ConvertToMembers(MessageHandlerObj), MessageHandlerObj.channel, true)
    end
end

-- Unblock
Commands.unblock = function(MessageHandlerObj)
    if Predicates.isModerator_v(MessageHandlerObj.author_member) then
        Block.Remove(ConvertToMembers(MessageHandlerObj))
    end
end

-- Blocked members
Commands.blocked_members = function(MessageHandlerObj)
    MessageHandlerObj.channel:send
    { content = "`" .. tostring(Block.NumberOfBlockedIds()) .. "` blocked member" }
end

-- Line
Commands.line = function(MessageHandlerObj)
    if Predicates.isModerator_v(MessageHandlerObj.author_member) then
        MessageHandlerObj.channel:send {
            embed = {
                image = { url = Enums.Images.Line },
                color = discordia.Color.fromRGB(1, 1, 1).value
            }
        }
    end
end

-- Header
Commands.header = function(MessageHandlerObj)
    if Predicates.isModerator_v(MessageHandlerObj.author_member) then
        MessageHandlerObj.channel:send {
            embed = {
                image = { url = Enums.Images.Header },
                color = discordia.Color.fromRGB(1, 1, 1).value
            }
        }
    end
end

-- Bots entry
Commands.bots_entry = function(MessageHandlerObj)
    MessageHandlerObj.channel:send
    { content = _G.IsBots_Entry_Allowed and "allowed `1`" or "disallowed `0`" }
end

-- Allow bots entry
Commands.allow_bots_entry = function(MessageHandlerObj)
    if Predicates.isOwner_v(MessageHandlerObj.author_member) then
        _G.IsBots_Entry_Allowed = true
    end
end

-- Disallow bots entry
Commands.disallow_bots_entry = function(MessageHandlerObj)
    if Predicates.isOwner_v(MessageHandlerObj.author_member) then
        _G.IsBots_Entry_Allowed = false
    end
end

-- Remove mods
Commands.remove_mods = function(MessageHandlerObj)
    if not Predicates.isOwner_v(MessageHandlerObj.author_member) then
        return
    end
    local conformed_removes = ""
    local members = ConvertToMembers(MessageHandlerObj)
    for _, member in pairs(members) do
        if Predicates.isModerator_v(member) then
            member:removeRole(Enums.Roles.Moderator)
            conformed_removes = conformed_removes .. member.mentionString .. "\n"
        end
    end
    if conformed_removes == "" then
        return
    end
    MessageHandlerObj.channel:send {
        embed = {
            title = "مشرفين سٌلبت حقوقهم للتو",
            description = conformed_removes,
            color = discordia.Color.fromRGB(88, 101, 241).value
        }
    }
end

-- Assign mods
Commands.assign_mods = function(MessageHandlerObj)
    if not Predicates.isOwner_v(MessageHandlerObj.author) then
        return
    end
    local members = ConvertToMembers(MessageHandlerObj)
    for _, member in pairs(members) do
        member:addRole(Enums.Roles.Moderator)
    end
end

-- Wiki
Commands.wiki = function(MessageHandlerObj)
    local key = MessageHandlerObj.content:gsub("wiki", ""):match("%a+") -- Remove wiki and find the first string

    if Wiki[key] then
        MessageHandlerObj.channel:send
        { embed = Wiki[key] }
    end
end

-- Lock
Commands.lock = function(MessageHandlerObj)
    if not Predicates.isModerator_v(MessageHandlerObj.author_member) then
        return
    end
    local channel = MessageHandlerObj.channel

    channel:getPermissionOverwriteFor(MessageHandlerObj.guild:getRole(Enums.Roles.Everyone)):denyPermissions(
        "sendMessages")
    channel:send {
        embed = {
            description = "القناة غُلقت مؤقتاً\n`mn unlock` لفتح القناة",
            color = discordia.Color.fromRGB(124, 78, 73).value
        }
    }
end

-- Unlock
Commands.unlock = function(MessageHandlerObj)
    if not Predicates.isModerator_v(MessageHandlerObj.author_member) then
        return
    end
    local channel = MessageHandlerObj.channel

    channel:getPermissionOverwriteFor(MessageHandlerObj.guild:getRole(Enums.Roles.Everyone)):allowPermissions(
        "sendMessages")
    channel:send {
        embed = {
            description = "القناة لم تعد مغلقة\n`mn lock` لغلق القناة",
            color = discordia.Color.fromRGB(124, 78, 73).value
        }
    }
end

-- Wiki help
Commands.wikihelp = function(MessageHandlerObj)
    local cmds = ""
    for key, _ in pairs(Wiki) do
        cmds = cmds .. "\n" .. key
    end
    MessageHandlerObj.channel:send {
        embed = {
            description = cmds
        }
    }
end

-- Roles embed
Commands.roles_embed = function(MessageHandlerObj)
    if not Predicates.isOwner_v(MessageHandlerObj.author_member) then
        return
    end
    local guild = MessageHandlerObj.guild
    local channel = MessageHandlerObj.channel
    local roles_options = discordia.Components {
        discordia.SelectMenu("roles_embed") -- id
            :placeholder "اختر الرتبة التي تريد التقديم عليها"
            :option("مبرمج", "programmer", "هذه الرتبة لها 4 تصنيفات", false, guild:getEmoji("1248588585590980649"))
            :option("مودلر", "modeler", "هذه الرتبة لها 4 تصنيفات", false, guild:getEmoji("1248610501118922874"))
            :option("بلدر", "builder", "هذه الرتبة لها 3 تصنيفات", false, guild:getEmoji("1248610496622362624"))
            :option("مصمم جرافيك", "gfx", "هذه الرتبة لها 3 تصنيفات", false, guild:getEmoji("1248610490855325738"))
            :option("مؤثرات بصرية", "vfx", "هذه الرتبة لها 3 تصنيفات", false, guild:getEmoji("1248610479232909332"))
            :option("أنيميشن", "animation", "هذه الرتبة لها 3 تصنيفات", false, guild:getEmoji("1248610481606885486"))
            :option("واجهة مستخدم", "ui", "هذه الرتبة لها 3 تصنيفات", false, guild:getEmoji("1248610488275828848"))
    }
    channel:sendComponents({
        embed = {
            title = "طلب رتب المطورين",
            description =
            "يمكنك هنا التقدم للحصول على احدى رتب المطورين\nتنقسم الرتب إلى ثلاث او اربعة مستويات، كل منها يعكس مستوى المهارة والخبرة\n\n🔻 Scripter I\n🔻 Scripter II\n🔻 Scripter III\n🔻 Scripter IIII\n\nسيتم تقييم طلبك بناءً على اعمالك المرسلة\nحظًا موفقًا في تقديمك!",
            image = { url = Enums.Images.Header },
            color = discordia.Color.fromRGB(1, 1, 1).value,
        }
    }, roles_options)
end

-- Rules embed
Commands.rules_embed = function(MessageHandlerObj)
    if not Predicates.isOwner_v(MessageHandlerObj.author_member) then
        return
    end
    local channel = MessageHandlerObj.channel

    channel:send {
        embed = {
            image = { url = Enums.Images.Header },
            color = discordia.Color.fromRGB(1, 1, 1).value
        }
    }

    channel:send {
        embed = {
            description = [[استخدم [الفطرة السليمة](https://dorar.net/aqeeda/259).
عامل زملائك بالاحترام. كن لطيفًا. لا توجد أسئلة غبية.
لا نتسامح مع الإهانات العنصرية، التمييز الجنسي، أو أي شكل من أشكال التعصب.
لا تمنشن الأعضاء أو ترسل لهم رسائل خاصة. فقط قم بنشر سؤالك في إحدى قنوات المساعدة.

لا تنشر إجابات تم إنشاؤها بواسطة الذكاء الاصطناعي، ولا تطلب المساعدة في الأكواد التي تم إنشاؤها بواسطة الذكاء الاصطناعي.

لا تسأل إذا كان يمكنك السؤال - فقط اسأل. من المحتمل أن يكون لدى شخص ما الإجابة وسيكون سعيدًا بمساعدتك.

لا تتردد في نشر رسالتك حتى لو كان هناك مستخدمون آخرون يتحدثون.
إذا لم تحصل على رد فوري، فهذا لا يعني أن سؤالك قد تم تجاهله.
إذا كان الأمر محبطًا للغاية، يمكنك إنشاء thread في [مساعدة أعمق](https://i.imgur.com/JYO824F.png)

يمنع نشر روابط سيرفرات، وتمنع المتاجرة خارج رومات التجارة.
يمنع نشر أو اعادة بيع ما بيعَ لك في رومات التجارة.]],
            image = { url = Enums.Images.Header },
            color = discordia.Color.fromRGB(1, 1, 1).value
        }
    }
end

-- Shop embed
Commands.shop_embeds = function(MessageHandlerObj)
    if not Predicates.isOwner_v(MessageHandlerObj.author_member) then
        return
    end

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
    }, CraeteButtonComponentWithId("fh_request"))

    _G.Client:getChannel(Enums.Channels.sell_embed_channel):sendComponents({
        embed = {
            title = "بيع عمل",
            description = "اعرض أعمالك الإبداعية للبيع وحقق ارباح مادية"
        }
    }, CraeteButtonComponentWithId("sell_request"))

    _G.Client:getChannel(Enums.Channels.lfd_embed_channel):sendComponents({
        embed = {
            title = "طلب خدمة",
            description = "ابحث عن مطورين لمساعدتك في تطوير لعبتك"
        }
    }, CraeteButtonComponentWithId("lfd_request"))
end

-- Source code
Commands.source_code = function(MessageHandlerObj)
    MessageHandlerObj.channel:send {
        embed = {
            title = "source code",
            description = "repo: [moamen](https://github.com/notpythonics/moamen)\n`git clone https://github.com/notpythonics/moamen`\n-->change enums and replace token\n->run batch file\nyou can't be a contributor go away"
        }
    }
end

-- Featured embed
Commands.fe_embed = function(MessageHandlerObj)
    if not Predicates.isModerator_v(MessageHandlerObj.author_member) then
        return
    end
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
        description = "made by " .. replied_to_msg.author.mentionString
    }

    -- Check for image attachments
    local attachments = replied_to_msg.attachments -- a table of attachments(an attachment is any file like an image)
    if #attachments > 0 then
        embed.image = { url = attachments[1].url }
    end

    -- Check for links
    local links = MessageHandlerObj.FindLinks(replied_to_msg.content)
    if #links > 0 then
        embed.description = embed.description .. "\n" .. string.format("[[video]](%s)", links[1]:gsub(" ", ""))
    end

    _G.Client:getChannel(Enums.Channels.fetured):send
    { embed = embed }
end


-- Disallow send permission
Commands.disallow_send_perm = function(MessageHandlerObj)
    if not Predicates.isModerator_v(MessageHandlerObj.author_member) then
        return
    end
    local conformed_disallows = ""
    local f_channel = MessageHandlerObj.mentionedChannels.first
    if not f_channel then
        f_channel = MessageHandlerObj.channel
    end
    local members = ConvertToMembers(MessageHandlerObj)
    for _, member in pairs(members) do
        f_channel:getPermissionOverwriteFor(member):denyPermissions("sendMessages")
        conformed_disallows = conformed_disallows .. member.mentionString .. "\n"
    end
    MessageHandlerObj.channel:send {
        embed = {
            title = "مُنعوا من الإرسال " .. f_channel.mentionString,
            description = conformed_disallows,
            color = discordia.Color.fromRGB(122, 78, 192).value,
            footer = {
                text = "❌"
            }
        }
    }
end

-- Allow send permission
Commands.allow_send_perm = function(MessageHandlerObj)
    if not Predicates.isModerator_v(MessageHandlerObj.author_member) then
        return
    end
    local conformed_allows = ""
    local f_channel = MessageHandlerObj.mentionedChannels.first
    if not f_channel then
        f_channel = MessageHandlerObj.channel
    end
    local members = ConvertToMembers(MessageHandlerObj)
    for _, member in pairs(members) do
        f_channel:getPermissionOverwriteFor(member):allowPermissions("sendMessages")
        conformed_allows = conformed_allows .. member.mentionString .. "\n"
    end
    MessageHandlerObj.channel:send {
        embed = {
            title = "سُمح لهم بالإرسال " .. f_channel.mentionString,
            description = conformed_allows,
            color = discordia.Color.fromRGB(122, 78, 192).value,
            footer = {
                text = "✔️"
            }
        }
    }
end

local function FindFirstRole(content)
    for roleName, id in pairs(Enums.Roles.Levels) do
        --print(roleName, content)
        if content:lower():match(roleName:lower()) then
            return roleName:upper()
        end
    end
end

-- Give role
Commands.give_role = function(MessageHandlerObj)
    if not Predicates.isModerator_v(MessageHandlerObj.author_member) then
        return
    end
    local first_mention = MessageHandlerObj.mentionedUsers.first
    local f_member = first_mention and MessageHandlerObj.guild:getMember(first_mention.id)
    if not f_member then
        MessageHandlerObj.channel:send
        { content = "please provide a member" }
        return
    end
    local f_roleName = FindFirstRole(MessageHandlerObj.content)
    if not f_roleName then
        MessageHandlerObj.channel:send
        { content = "please provide a role enum" }
        return
    end

    local roleAdjusterObj = RoleAdjuster.new(f_member, f_roleName)
    roleAdjusterObj:Adjust()

    MessageHandlerObj.channel:send {
        embed = {
            title = f_member.username .. "أٌعطا رتبة ",
            description = "الرتب المتوافقة حٌذفت" .. "\n" .. "الرتبة المعطاة هي " .. MessageHandlerObj.guild:getRole(Enums.Roles.Levels[f_roleName]).mentionString,
            color = discordia.Color.fromRGB(60, 119, 80).value
        }
    }
end

-- Allow read permission
Commands.allow_read_perm = function(MessageHandlerObj)
    if not Predicates.isModerator_v(MessageHandlerObj.author_member) then
        return
    end
    local conformed_allows = ""
    local f_channel = MessageHandlerObj.mentionedChannels.first
    if not f_channel then
        f_channel = MessageHandlerObj.channel
    end
    local members = ConvertToMembers(MessageHandlerObj)
    for _, member in pairs(members) do
        f_channel:getPermissionOverwriteFor(member):allowPermissions("readMessages")
        conformed_allows = conformed_allows .. member.mentionString .. "\n"
    end
    MessageHandlerObj.channel:send {
        embed = {
            title = "سُمح لهم بالرؤية " .. f_channel.mentionString,
            description = conformed_allows,
            color = discordia.Color.fromRGB(122, 78, 192).value,
            footer = {
                text = "✔️"
            }
        }
    }
end

-- Disallow read permission
Commands.disallow_read_perm = function(MessageHandlerObj)
    if not Predicates.isModerator_v(MessageHandlerObj.author_member) then
        return
    end
    local conformed_disallows = ""
    local f_channel = MessageHandlerObj.mentionedChannels.first
    if not f_channel then
        f_channel = MessageHandlerObj.channel
    end
    local members = ConvertToMembers(MessageHandlerObj)
    for _, member in pairs(members) do
        f_channel:getPermissionOverwriteFor(member):denyPermissions("readMessages")
        conformed_disallows = conformed_disallows .. member.mentionString .. "\n"
    end
    MessageHandlerObj.channel:send {
        embed = {
            title = "مُنعوا من الرؤية " .. f_channel.mentionString,
            description = conformed_disallows,
            color = discordia.Color.fromRGB(122, 78, 192).value,
            footer = {
                text = "❌"
            }
        }
    }
end


-- It ignores larg numbers(IDs?)
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

-- Mute
Commands.mute = function(MessageHandlerObj)
    if not Predicates.isModerator_v(MessageHandlerObj.author_member) then
        return
    end
    local suff, duration = FindDuration(MessageHandlerObj.content)
    duration = math.min(duration, 604800)
    local conformed_timeouts = ""

    local members = ConvertToMembers(MessageHandlerObj)
    for _, member in pairs(members) do
        if Predicates.isValidToPunch(member) then
            member:timeoutFor(duration)
            conformed_timeouts = conformed_timeouts .. member.mentionString .. "\n"
            local p_channel = member.user:getPrivateChannel()
            if p_channel then
                p_channel:send {
                    embed = {
                        title = "انكتمت للتو",
                        description = "إقرأ [القوانين](https://discord.com/channels/1028991149806981140/1028991151467933751) لتفادي الكتم. وتذكر أن الحظر قد يكون الخطوة التالية.",
                        color = discordia.Color.fromRGB(27, 57, 74).value,
                    }
                }
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
            color = discordia.Color.fromRGB(27, 57, 74).value,
            footer = { text = "👨🏿‍🌾" }
        }
    }
end

-- Unmute
Commands.unmute = function(MessageHandlerObj)
    if not Predicates.isModerator_v(MessageHandlerObj.author_member) then
        return
    end
    local members = ConvertToMembers(MessageHandlerObj)
    for _, member in pairs(members) do
        member:removeTimeout()
    end
end

return Commands
