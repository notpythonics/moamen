local discordia = require("discordia")

local shop = {}

local TIME_UNTIL_COMPONENT_STOPS_WAITING = 1000 * 60 * 10 -- 10 minutes
_G.Working_members = {}

local function invalid_input(message, author, stage)
    local content = message.content
    if content:sub(1, 12) == "moamen erase" then
        Working_members[author.id] = nil
        message:reply("الإمبد انحذف، سوي إنشاء مرة أُخرى لتعيد التعبئة")
        return true
    end
    if content == "" and stage ~= 3 then return true end
end

function shop.process_stage(message)
    local author = message.author
    local p_channel = author:getPrivateChannel()
    local working_member = Working_members[author.id]

    if not working_member then return end

    local is_sell_request = working_member.custom_id == "sell"

    if invalid_input(message, author, working_member.stage) then return end

    if working_member.stage == 1 then
        working_member.title = message.content
        working_member.stage = 2

        -- Description prompt
        p_channel:send {
            embed = {
                title = "الوصف",
                description = "اكتب وصف رسالتك"
            }
        }
        return
    end

    if working_member.stage == 2 then
        local l_embed = {
            title = "صورة",
            description = "ارسل صورة لرسالتك"
        }

        if is_sell_request then
            l_embed.description = l_embed.description .. "\n" .. "عند بيع عمل الصورة ضرورية"
        else
            l_embed.description = l_embed.description .. "\n" .. "اكتب `no_image` اذا مافي صورة"
        end

        working_member.description = message.content
        working_member.stage = 3
        p_channel:send { embed = l_embed }
        return
    end

    if working_member.stage == 3 then
        local function send_payment_type()
            local sent_message = p_channel:sendComponents({
                    embed = {
                        title = "طرق الدفع",
                        description = "ما طرق الدفع الي تتعامل فيها"
                    }
                },
                discordia.Components {
                    discordia.SelectMenu("payment_type") -- id
                        :placeholder "اختر طريقة الدفع"
                        :minValues(1)                    -- Allow selecting at least 1 option
                        :maxValues(3)                    -- Allow selecting up to 3 options
                        :option("روبوكس", "Robux", "الدفع بستخدام روبوكس", false)
                        :option("كردت", "Credit", "الدفع بستخدام كردت", false)
                        :option("دولار", "Dollar", "الدفع بستخدام دولار", false)
                })

            if not sent_message then return end

            local success, interaction = sent_message:waitComponent("selectMenu", nil, TIME_UNTIL_COMPONENT_STOPS_WAITING,
                function() return Working_members[author.id] ~= nil end)

            if success then
                local l_embed = {
                    title = "",
                    description = "اكتب المبلغ(رقم فقط) وبالنهاية ضيف `+` اذا المبلغ يزداد"
                }

                for _, option in ipairs(interaction.data.values) do
                    if option == "Robux" then
                        working_member.robux_option = option
                    elseif option == "Credit" then
                        working_member.credit_option = option
                    elseif option == "Dollar" then
                        working_member.dollar_option = option
                    end
                end

                print(working_member.robux_option, " ", working_member.credit_option, " ", working_member.dollar_option)

                if working_member.robux_option then
                    l_embed.title = "المبلغ روبوكس"
                elseif working_member.credit_option then
                    l_embed.title = "المبلغ كردت"
                elseif working_member.dollar_option then
                    l_embed.title = "المبلغ دولار"
                end

                working_member.stage = 4
                p_channel:send { embed = l_embed }
                interaction:updateDeferred()
            else
                return
            end
        end

        local attachment = message.attachment
        if message.content:sub(1, 8) == "no_image" and not is_sell_request then
            send_payment_type()
            return
        end

        if not attachment then return end

        working_member.attachment = attachment
        send_payment_type()
        return
    end

    do
        local num = message.content:match("%d+")

        local plus_sign = message.content:match("+")

        local k_letter = message.content:lower():match("k")
        local m_letter = message.content:lower():match("m")


        -- Credit and Robux
        if working_member.stage == 4 and working_member.robux_option and working_member.credit_option then
            if not num then return end

            working_member.robux_option = "Robux: " .. num .. (k_letter or m_letter or "") .. (plus_sign or "")

            p_channel:send {
                embed = {
                    title = "المبلغ كردت",
                    description = "اكتب المبلغ(رقم فقط) وبالنهاية ضيف `+` اذا المبلغ يزداد"
                }
            }
            working_member.stage = working_member.stage + 1
            return
        end

        -- Robux and Dollar
        if working_member.stage == 4 and working_member.robux_option and working_member.dollar_option then
            if not num then return end

            working_member.robux_option = "Robux: " .. num .. (k_letter or m_letter or "") .. (plus_sign or "")

            p_channel:send {
                embed = {
                    title = "المبلغ دولار",
                    description = "اكتب المبلغ(رقم فقط) وبالنهاية ضيف `+` اذا المبلغ يزداد"
                }
            }
            working_member.stage = 6
            return
        end

        -- Dollar and Credit and not Robux
        if working_member.stage == 4 and working_member.credit_option and working_member.dollar_option and not working_member.robux_option then
            if not num then return end

            working_member.credit_option = "Credit: " .. num .. (k_letter or m_letter or "") .. (plus_sign or "")

            p_channel:send {
                embed = {
                    title = "المبلغ دولار",
                    description = "اكتب المبلغ(رقم فقط) وبالنهاية ضيف `+` اذا المبلغ يزداد"
                }
            }
            working_member.stage = 6
            return
        end

        -- Credit and Robux and Dollar
        if working_member.stage == 5 and working_member.robux_option and working_member.credit_option and working_member.dollar_option then
            if not num then return end

            working_member.credit_option = "Credit: " .. num .. (k_letter or m_letter or "") .. (plus_sign or "")

            p_channel:send {
                embed = {
                    title = "المبلغ دولار",
                    description = "اكتب المبلغ(رقم فقط) وبالنهاية ضيف `+` اذا المبلغ يزداد"
                }
            }
            working_member.stage = 6
            return
        end

        -- Just Robux
        if working_member.stage == 4 and working_member.robux_option then
            if not num then return end

            working_member.robux_option = "Robux: " .. num .. (k_letter or m_letter or "") .. (plus_sign or "")
            working_member.stage = working_member.stage + 1
        end

        -- Just Credit
        if working_member.stage == 4 and working_member.credit_option then
            if not num then return end

            working_member.credit_option = "Credit: " .. num .. (k_letter or m_letter or "") .. (plus_sign or "")
            working_member.stage = working_member.stage + 1
        end

        -- Just Dollar
        if working_member.stage == 4 and working_member.dollar_option then
            if not num then return end

            working_member.dollar_option = "Dollar: " .. "$" .. num .. (k_letter or m_letter or "") .. (plus_sign or "")
            working_member.stage = working_member.stage + 1
        end

        -- Robux and Credit and not Dollar
        if working_member.stage == 5 and working_member.robux_option and working_member.credit_option and not working_member.dollar_option then
            if not num then return end

            working_member.credit_option = "Credit: " .. num .. (k_letter or m_letter or "") .. (plus_sign or "")
            working_member.stage = 7
        end

        if working_member.stage == 6 then
            if not num then return end

            working_member.dollar_option = "Dollar: " .. "$" .. num .. (k_letter or m_letter or "") .. (plus_sign or "")
            working_member.stage = working_member.stage + 1
        end
    end



    local created_embed = {
        title = working_member.title,
        description = working_member.description,

        author = {
            name = author.username,
            icon_url = author.avatarURL
        },

        fields = {
            {
                name = "طرق الدفع",
                value = (working_member.robux_option and (working_member.robux_option .. "\n") or "") ..
                    (working_member.credit_option and (working_member.credit_option .. "\n") or "") ..
                    (working_member.dollar_option and (working_member.dollar_option .. "\n") or ""),
                inline = false
            }
        },

        footer = { text = author.id }
    }

    -- Add the image to the embed
    if working_member.attachment then
        created_embed.image = { url = working_member.attachment.url }
    end



    local sent_message = p_channel:sendComponents({
            embed = created_embed
        },
        discordia.Components {
            discordia.Button("shop_request") -- id
                :label "ارسال للمسؤولين عن الإمبد"
                :style "secondary",
            discordia.Button("not_saty") -- id
                :label "مو راضي فيها"
                :style "danger"
        })

    if not sent_message then return end
    local success, interaction = sent_message:waitComponent("button", nil, TIME_UNTIL_COMPONENT_STOPS_WAITING,
        function() return Working_members[author.id] ~= nil end)


    if success then
        local custom_id = interaction.data.custom_id

        if custom_id == "shop_request" then
            interaction:reply("الإمبد انرسل، انتظر القبول والرفض بيجيك اشعار خاص")
            return created_embed, working_member.custom_id, working_member.work_type
        end

        working_member = nil
        interaction:reply("الإمبد انحذف، سوي إنشاء مرة أُخرى لتعيد التعبئة")
    else
        return
    end
end

function shop.append_working(author, custom_id) -- custom_id == interaction ID
    local p_channel = author:getPrivateChannel()
    if not p_channel then return end

    Working_members[author.id] = {
        stage = 0,
        title = "",
        description = "",
        work_type = "",
        attachment = nil,
        custom_id = custom_id,
        robux_option = nil,
        credit_option = nil,
        dollar_option = nil
    }

    if custom_id == "fh" or custom_id == "lfd" then
        local sent_message = p_channel:sendComponents({
                embed = {
                    title = "البحث او الخبرة",
                    description = "ما خبرتك او الخبرة الي تبحث عنها",
                }
            },
            discordia.Components {
                discordia.SelectMenu("work_type") -- id
                    :placeholder "اختر العمل"
                    :option("مبرمج", "programmer", "يكتب سكربتات برمجية", false)
                    :option("مودلر", "modeler", "يسوي مجسمات ثلاثية الأبعاد", false)
                    :option("بلدر", "builder", "يرتب المجسمات ويكون منها بيئة", false)
                    :option("مصمم جرافيك", "gfx", "يسوي صور سينمائية", false)
                    :option("مؤثرات بصرية", "vfx", "يسوي مؤثرات", false)
                    :option("أنيميشن", "animation", "يسوي انيميشنات", false)
                    :option("واجهة مستخدم", "ui", "يسوي واجهة مستخدم", false)
            })

        if not sent_message then return end

        local success, interaction = sent_message:waitComponent("selectMenu", nil, TIME_UNTIL_COMPONENT_STOPS_WAITING,
            function() return Working_members[author.id] ~= nil end)

        if success then
            print(interaction.data.values[1])
            interaction:updateDeferred()
            Working_members[author.id].work_type = interaction.data.values[1]
        else
            return
        end
    end

    if custom_id == "sell_request" then
        Working_members[author.id].work_type = custom_id
    end


    -- Title prompt
    p_channel:send {
        embed = {
            title = "العنوان",
            description = "اكتب عنوان رسالتك"
        }
    }

    Working_members[author.id].stage = 1
end

function shop.send(message, r_embed)
    assert(type(message) == "table")
    assert(type(r_embed) == "table")
    local custom_id = message.content:match("lfd") or message.content:match("fh")
    local work_type = message.content:gsub("lfd", "")
    work_type = work_type:gsub("fh", "")

    local channel_table = (custom_id == "lfd" and Enums.Channels.shop.lfd or custom_id == "fh" and Enums.Channels.shop.fh or Enums.Channels.shop)

    for channelName, channelId in pairs(channel_table) do
        if work_type == channelName then
            local sent_embed = message.guild:getChannel(channelId):sendComponents({
                    embed = r_embed
                },
                discordia.Components {
                    discordia.Button("communicate") -- id
                        :label "تواصل مع المطور 📜"
                        :style "secondary"
                })
            return sent_embed.link
        end
    end
end

return shop
