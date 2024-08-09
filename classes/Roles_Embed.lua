local discordia = require('discordia')

local timer = require('timer')
local Block = require('./Block')
local Shop = require('./Shop')

local Shared = require('../Shared')
local Enums = require('../Enums')
local Elements = require('../Elements')

local roles_embed = {}

roles_embed.__index = roles_embed

function roles_embed.new(message, client)
    local self = setmetatable({}, roles_embed)

    self.client = client
    self.guild = message.guild
    self.channel = message.channel

    return self
end

local function is_member(intr)
    if not intr.member:hasPermission('administrator') then
        intr.channel:send('صاحب التقديم ممنوع يحذف التكت')
        return true
    end
    return false
end

local function handle_shop_embed_button(r_embed, is_accepted, intr, client)
    if not r_embed then
        return
    end

    local user = client:getUser(r_embed[1])

    if is_accepted then
        intr.message:delete()
        intr:replyDeferred(true)
        intr:reply('انقبلت')
        Shared.REQUESTED_EMBEDS[user.username] = nil
        Shop.send(intr.message, r_embed[2], r_embed[3])
        user:getPrivateChannel():send('الإمبد انقبل')
    else
        intr:modal(Elements.modals.decline_reason)
    end
end


function roles_embed:bind_interaction_event()
    if Shared.IS_INTERACTION_BOUND then return end
    Shared.IS_INTERACTION_BOUND = true


    self.client:on('interactionCreate', function(intr)
        if not intr.member then return end

        -- Custom ID
        local custom_id = intr.data.custom_id
        print(custom_id)

        -- Modal
        if custom_id == 'decline_reason_modal' then
            local textInputValue = intr.data.components[1].components[1].value

            local r_embed = Shared.REQUESTED_EMBEDS[intr.message.embed.author.name]
            local user = self.client:getUser(r_embed[1])

            Shared.REQUESTED_EMBEDS[user.username] = nil
            user:getPrivateChannel():send('الإمبد انرفض\n' .. '`السبب:' .. textInputValue .. '`')
            intr.message:delete()
            intr:updateDeferred()
            return
        end

        -- Check if the user is blocked
        if Shared.TABLE_FIND(Block:blocked_members_tbl(), intr.member.user.id) then
            intr:replyDeferred(true)
            intr:reply('انت محظور')
            return
        end

        -- Shop
        if (custom_id == 'lfd_request' or custom_id == 'fh_request') then
            intr:replyDeferred(true)
            if Shared.REQUESTED_EMBEDS[intr.member.username] then
                intr:reply('في طلب مرسل')
                return
            end
            intr:reply('خاص')
            Shop.append_working(intr.member.user, custom_id)
            return
        end


        -- Accept and decline buttons
        if (custom_id == 'request_decline') then
            local r_embed = Shared.REQUESTED_EMBEDS[intr.message.embed.author.name]
            handle_shop_embed_button(r_embed, false, intr, self.client)
            return
        end

        if (custom_id == 'request_accept') then
            local r_embed = Shared.REQUESTED_EMBEDS[intr.message.embed.author.name]
            handle_shop_embed_button(r_embed, true, intr, self.client)
            return
        end
        ----------------------------


        -- Ticket delete
        if (custom_id == 'delete') then
            if is_member(intr) then return end

            intr.channel:send('الروم ينحذف بعد 3 ثواني')
            timer.sleep(3000)
            intr.channel:delete()
            return
        end

        -- Ticket close
        if (custom_id == 'close') then
            if is_member(intr) then return end
            if string.find(intr.channel.name, '🔒') then
                intr:replyDeferred(true)
                intr:reply('الروم مقفل اساسا')
                return
            end

            intr:updateDeferred()

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
            local new_name = string.gsub(c_name, '🔓', '🔒')
            intr.channel:setName(new_name)
            return
        end


        if (custom_id == 'roles_embed') then
            intr:replyDeferred(true)

            --create a channel
            local created_channel = self.guild:createTextChannel(intr.data.values[1] .. ' 🔓')
            created_channel:setCategory(Enums.categories.ask_for_roles)

            --make it priavte to the maker
            created_channel:getPermissionOverwriteFor(self.guild:getRole(Enums.roles.everyone)):denyPermissions(
                'readMessages')
            created_channel:getPermissionOverwriteFor(intr.member):allowPermissions('readMessages')

            --mention the maker
            created_channel:send(intr.member.user.mentionString)

            --send an emebd to the created_channel
            created_channel:sendComponents({
                embed = Elements.embeds.roles_embed
            }, Elements.buttons.close_and_delete)

            intr:reply('إنشأ روم تحت')
        end
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
            :option("واجهة مستخدم", "ui", "هذه الرتبة لها 3 تصنيفات", false, self.guild:getEmoji('1248610488275828848'))
    }
    self.channel:sendComponents({
        embed = {
            title = 'طلب رتب المطورين',
            description =
            'يمكنك التقديم على رتبتك هنا\nجميع الرتب لها ثلاث او اربع تصنيفات(لفلات)\n\nScripter I\nScripter II\nScripter III\nScripter IIII',
            image = Elements.images.line,
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }, roles_options)

    self:bind_interaction_event()
end

return roles_embed
