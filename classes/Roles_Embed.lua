local discordia = require('discordia')
local timer = require('timer')
local Shared = require('../Shared')

local roles_embed = {}

roles_embed.__index = roles_embed

function roles_embed:new(message, client)
    self = setmetatable({}, roles_embed)

    self.client = client
    self.guild = message.guild
    self.channel = message.channel

    return self
end

function roles_embed:bind_interaction_event()
    local function is_member(intr)
        if not intr.member:hasPermission('administrator') then
            intr.channel:send('صاحب التقديم ممنوع يحذف التكت')
            return true
        end
        return false
    end

    self.client:on("interactionCreate", function(intr)
        intr:replyDeferred(true)

        if Shared.TABLE_FIND(Shared.BLOCKED_MEMBERS, intr.member.user.id) then
            intr:reply('انت محظور')
            return
        end

        if Shared.TABLE_FIND(Shared.DEBOUNCE_MEMBERS, intr.member.user.id) then
            Shared.REMOVE_DEBOUNCE_FROM_IN(intr.member.user.id, 2)
            intr:reply('cool down')
            return
        end
        table.insert(Shared.DEBOUNCE_MEMBERS, intr.member.user.id)



        local custom_id = intr.data.custom_id
        print(custom_id)


        --- what button?
        --------------------------------------------------------------
        if (custom_id == 'delete') then
            if is_member(intr) then return end

            local co = coroutine.create(function ()
                intr.channel:send('الروم ينحذف بعد 3 ثواني')
                timer.sleep(1000 * 3)
                intr.channel:delete()
            end)

            coroutine.resume(co)
            return
        end


        if (custom_id == 'close') then
            if is_member(intr) then return end
            if string.find(intr.channel.name, '🔒') then
                intr:reply('الروم مقفل اساسا')
                return end
            intr:reply('الروم تقفل')

            local user_who_made_channel = intr.channel:getFirstMessage().mentionedUsers.first
            local member_who_made_channel = self.guild:getMember(user_who_made_channel.id)
            if not user_who_made_channel then
                intr.channel:send('👩🏿‍🦱 صاحب التكت مو موجود')
                return
            end

            --print(user_who_made_channel.name, '\n', member_who_made_channel.name)
            intr.channel:getPermissionOverwriteFor(member_who_made_channel):denyPermissions('readMessages')
            intr.channel:send {
                embed = {
                    title = '🔒 ' .. intr.member.name .. ' closed this channel',
                    description = "you can't reopen this channel via any commands",
                    color = discordia.Color.fromRGB(0, 0, 0).value,
                }
            }

            local c_name = intr.channel.name
            local new_name = string.gsub(c_name , '🔓', '🔒')
            intr.channel:setName(new_name)
            return
        end
        --------------------------------------------------------------


        -- create a channel
        local created_channel = self.guild:createTextChannel(intr.data.values[1] .. ' 🔓')
        created_channel:setCategory('1248614752750403604')

        -- make it priavte to the maker
        created_channel:getPermissionOverwriteFor(self.guild:getRole('1028991149806981140')):denyPermissions(
            'readMessages')
        created_channel:getPermissionOverwriteFor(intr.member):allowPermissions('readMessages')

        -- send an emebd to the created_channel
        created_channel:send(intr.member.user.mentionString)
        local rooms_buttons = discordia.Components {
            discordia.Button("delete") -- id
                :label "حذف الروم"
                :style "danger",
            discordia.Button("close") -- id
                :label '(سكره)قفل الروم'
                :style 'secondary'
        }

        created_channel:sendComponents({
            embed = {
                title = 'روم التقديم',
                description = 'شغلك واعمالك ارسلهم هنا\n\nواكتب-->\nاسمك\nعمرك\n\n' .. intr.member.user.mentionString,
                color = discordia.Color.fromRGB(0, 0, 0).value,
            }
        }, rooms_buttons)

        intr:reply('إنشأ روم تحت')
    end)
end

function roles_embed:send()
    local roles_options = discordia.Components {
        discordia.SelectMenu("roles_embed") -- id
            :placeholder "اختر الرتبة التي تريد التقديم عليها"
            :option("مبرمج", "programmer", "هذه الرتبة لها 4 تصنيفات", false, self.guild:getEmoji('1248588585590980649'))
            :option("مودلر", "modeler", "هذه الرتبة لها 4 تصنيفات", false, self.guild:getEmoji('1248610501118922874'))
            :option("بلدر", "builder", "هذه الرتبة لها 3 تصنيفات", false, self.guild:getEmoji('1248610496622362624'))
            :option("مصمم جرافيك", "gfx", "هذه الرتبة لها 3 تصنيفات", false, self.guild:getEmoji('1248610490855325738'))
            :option("مؤثرات بصرية", "vfx", "هذه الرتبة لها 3 تصنيفات", false, self.guild:getEmoji('1248610479232909332'))
            :option("أنيميشن", "animation", "هذه الرتبة لها 3 تصنيفات", false, self.guild:getEmoji('1248610481606885486'))
            :option("واجهة مستخدم", "ui", "هذه الرتبة لها 3 تصنيفات", false, self.guild:getEmoji('1248610488275828848')),
    }
    self.channel:sendComponents({
        embed = {
            title = "طلب رتب المطورين",
            description =
            "يمكنك التقديم على رتبتك هنا\nجميع الرتب لها ثلاث او اربع تصنيفات(لفلات)\n\nScripter I\nScripter II\nScripter III\nScripter IIII",
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }, roles_options)
end

return roles_embed