local discordia = require('discordia')
local Enums = require('../Enums')
local Elements = require('../Elements')

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
        p_channel:send {
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
        p_channel:send {
            embed = {
                title = 'صورة',
                description = 'ارسل صورة لرسالتك\nاكتب `no_image` اذا مافي صورة'
            }
        }
        return
    end

    if working_member.stage == 3 then
        local function send_payment_type()
            local sent_message = p_channel:sendComponents({ embed = Elements.embeds.payment_type },
                Elements.menus.payment_type)

            -- wait for the button interaction
            local success, interaction = sent_message:waitComponent(3, 'payment_type')

            if success then
                local data = interaction.data.values[1]

                if data == 'Robux' then
                    working_member.robux = 0
                else
                    working_member.credit = 0
                end
                working_member.stage = working_member.stage + 1
                p_channel:send {
                    embed = {
                        title = 'المبلغ',
                        description = 'اكتب المبلغ(رقم فقط) وبالنهاية ضيف `+` اذا المبلغ يزداد'
                    }
                }
                interaction:updateDeferred()
            end
        end

        local attachment = message.attachment
        if message.content:sub(1, 8) == 'no_image' then
            send_payment_type()
            return
        end

        if not attachment then return end

        working_member.attachment = attachment
        send_payment_type()
        return
    end


    local quantity_input = nil
    if working_member.stage == 4 then
        local num = message.content:match('%d+')

        if not num then return end

        local plus_sign = message.content:match('+')

        if working_member.robux then
            quantity_input = 'Robux: ' .. num .. (plus_sign or '')
        elseif working_member.credit then
            quantity_input = 'Credit: ' .. num .. (plus_sign or '')
        end
        working_member.stage = working_member.stage + 1
    end

    local embed = {
        title = working_member.title,
        description = working_member.description,

        author = {
            name = author.username,
            icon_url = author.avatarURL
        },

        fields = {
            {
                name = 'المبلغ',
                value = quantity_input,
                inline = false
            },

            {
                name = 'التواصل',
                value = author.mentionString,
                inline = false
            }
        }
    }

    if working_member.attachment then
        embed.image = { url = working_member.attachment.url }
    end


    local sent_message = p_channel:sendComponents({
        embed = embed
    }, Elements.buttons.sendShopRequest_and_notSaty)

    local success, interaction = sent_message:waitComponent(2)

    if success then
        local custom_id = interaction.data.custom_id

        if custom_id == 'shop_request' then
            interaction:reply('الإمبد انرسل انتظر القبول والرفض بيجيك اشعار خاص')
            return embed, working_member.to_type, working_member.type_work
        end

        working_member = nil
        interaction:reply('الإمبد انحذف سوي إنشاء مرة اخرى لتعيد التعبئة')
    end
end

function shop.append_working(author, to_type)
    local p_channel = author:getPrivateChannel()

    if not p_channel then return end

    working_members[author.id] = {
        stage = 0,
        title = '',
        description = '',
        type_work = '',
        attachment = nil,
        to_type = to_type,
        robux = nil,
        credit = nil
    }

    local sent_message = p_channel:sendComponents({
        embed = Elements.embeds.work_type
    }, Elements.menus.work_type)

    local success, interaction = sent_message:waitComponent()

    if success then
        print(interaction.data.values[1])
        interaction:updateDeferred()
        working_members[author.id].type_work = interaction.data.values[1]
    end

    p_channel:send {
        embed = {
            title = 'العنوان',
            description = 'اكتب عنوان رسالتك'
        }
    }

    working_members[author.id].stage = 1
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

    message.guild:getChannel(channel_id):send { embed = r_embed }
end

return shop
