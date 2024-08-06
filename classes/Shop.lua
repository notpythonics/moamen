local discordia = require('discordia')
local Enums = require('../Enums')

local shop = {}

local working_members = {}

local function invalid_input(message, author, stage)
    local content = message.content
    if content:sub(1, 12) == 'moamen erase' then
        working_members[author.id] = nil
        message:reply('الإمبد انحذف سوي إنشاء مرة اخرى لتعيد التعبئة')
        return true
    end
    if content == '' and stage ~= 3 then return true end
end

function shop.process_stage(message)
    local author = message.author
    local p_channel = author:getPrivateChannel()
    local working_member = working_members[author.id]

    if not working_member then
        return
    end

    if invalid_input(message, author, working_member.stage) then
        return
    end

    if working_member.stage == 1 then
        working_member.title = message.content
        working_member.stage = working_member.stage + 1
        p_channel:send{
            embed = {
                title = 'الوصف',
                description = 'اكتب وصف رسالتك'
            }
        }
        return
    end

    if working_member.stage == 2 then
        working_member.description = message.content
        working_member.stage = working_member.stage + 1
        p_channel:send{
            embed = {
                title = 'صورة',
                description = 'ارسل صورة لرسالتك\nاكتب `no_image` اذا مافي صورة'
            }
        }
        return
    end

    if working_member.stage == 3 then
        local l_embed = {title = 'المبلغ', description = 'ارسل المبلغ وبنهايته اكتب R او كردت'}

        local attachment = message.attachment
        if message.content:sub(1, 8) == 'no_image' then
            working_member.stage = working_member.stage + 1
            p_channel:send{embed = l_embed}
            return
        end
        if not attachment then
            return
        end
        working_member.attachment = attachment
        working_member.stage = working_member.stage + 1
        p_channel:send{embed = l_embed}
        return
    end

    local embed = {
        title = working_member.title,
        description = working_member.description,

        author = {
            name = author.username,
            icon_url = author.avatarURL
        },

        fields = {
            {name = 'المبلغ',
            value = '`' .. message.content:gsub(' ', '') .. '`',
            inline = false},

            {name = 'التواصل',
            value = author.mentionString,
            inline = false}
        }
    }

    if working_member.attachment then
        embed.image = {url = working_member.attachment.url}
    end


    local rooms_buttons = discordia.Components {
        discordia.Button('request_shop') -- id
            :label 'ارسال للتقديم'
            :style 'secondary',
            discordia.Button('not_saty') -- id
            :label 'مو راضي فيها'
            :style 'danger'
    }


    local sent_message = p_channel:sendComponents({
            embed = embed
        }, rooms_buttons)

    local success, interaction = sent_message:waitComponent(2)

    if interaction then
        local custom_id = interaction.data.custom_id

        if custom_id == 'request_shop' then
            interaction:reply('الإمبد انرسل انتظر القبول والرفض بيجيك اشعار خاص')
            return embed, working_member.to_type, working_member.type_work
        end

        working_member = nil
        interaction:reply('الإمبد انحذف سوي إنشاء مرة اخرى لتعيد التعبئة')
    end
end

function shop.append_working(author, to_type)
    local p_channel = author:getPrivateChannel()
    if not p_channel then
        return
    end

    working_members[author.id] = {
        stage = 0,
        title = '',
        description = '',
        type_work = '',
        attachment = nil,
        to_type = to_type}

        local roles_options = discordia.Components {
            discordia.SelectMenu('dm_work') -- id
                :placeholder "اختر العمل"
                :option('مبرمج', 'programmer', 'يكتب سكربتات', false)
                :option('مودلر', 'modeler', 'يسوي مجسمات', false)
                :option('بلدر', 'builder', 'يركب اشياء فوق بعض', false)
                :option('مصمم جرافيك', 'gfx', 'يسوي صور', false)
                :option('مؤثرات بصرية', 'vfx', 'يسوي مؤثرات', false)
                :option('أنيميشن', 'animation', 'يسوي انيميشنات', false)
                :option('واجهة مستخدم', 'ui', 'يسوي واجهة مستخدم', false)
        }

        local sent_message = p_channel:sendComponents({
            embed = {
                title = 'البحث او الخبرة',
                description = 'ما خبرتك او الخبرة الي تبحث عنها',
                color = discordia.Color.fromRGB(0, 0, 0).value,
            }
        }, roles_options)

        -- wait for the button interaction
        local success, interaction = sent_message:waitComponent('dm_work')

        if success then
            interaction:replyDeferred(true)
            print(interaction.data.values[1])
            interaction:reply('  اختيرت ' .. interaction.data.values[1])
            working_members[author.id].type_work = interaction.data.values[1]
        else
            working_members[author.id] = nil
            return
        end

        p_channel:send{
            embed = {
                title = 'العنوان',
                description = 'اكتب عنوان رسالتك'
            }
        }

        working_members[author.id].stage =  1
end

function shop.send(message, r_embed, to_type)
    local channel_id = nil
    local tbl = nil

    if to_type == 'lfd_request' then
        tbl = Enums.channels.shop.lfd
    else
        tbl = Enums.channels.shop.fh
    end

    for key, v in pairs(tbl) do
        if message.content == key then
            channel_id = v
            break
        end
    end

    message.guild:getChannel(channel_id):send{embed = r_embed}
end

return shop