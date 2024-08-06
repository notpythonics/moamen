local discordia = require('discordia')
local Roles_Embed = require('./Roles_Embed')
local Wiki = require('./Wiki')
local Block = require('./Block')

local Shared = require('../Shared')
local Enums = require('../Enums')

local message_handler = {}

message_handler.__index = message_handler

function message_handler.new(client)
    local self = setmetatable({}, message_handler)

    self.client = client

    return self
end

function message_handler:handle(message)

    self.author = message.author
    self.guild = message.guild -- a guild is your server
    self.content = message.content
    self.mentionedUsers = message.mentionedUsers
    self.channel = message.channel
    self.author_member = message.guild.members:get(self.author.id)
    self.message = message

    if (self.content:sub(1, 5) == 'what?' or
        self.content:sub(1, 4) == 'what' or
        self.content:sub(1, 3) == 'wat') then
        pcall(function()
            self.message:addReaction(Enums.emojis.what)
        end)
        return
    end

    if (self.content:sub(1, 11) == 'moamen mute')  then
        self:timeOut_command()

    elseif (self.content:sub(1, 13) == 'moamen unmute') then
        self:untimeOut_command()


        --banning
    elseif (self.content:sub(1, 10) == 'moamen ban') then
        self:ban_command()

    elseif (self.content:sub(1, 12) == 'moamen unban') then
        self:unban_command()


        --others
    elseif (self.content:sub(1, 20) == 'moamen assign_member') then
        self:assign_member_role_command()

    elseif (self.content:sub(1, 18) == 'moamen source_code') then
        self:source_code_command()

    elseif (self.content:sub(1, 11) == 'moamen wiki') then
        self:wiki_command(self.message)

    elseif (self.content:sub(1, 11) == 'moamen kick') then
        self:kick_command()


        --embeds
    elseif (self.content:sub(1, 18) == 'moamen roles_embed') then
        self:roles_embed_command()

    elseif (self.content:sub(1, 18) == 'moamen shop_embeds') then
        self:shop_embeds_command()

    elseif (self.content:sub(1, 15) == 'moamen fe_embed') then
        self:fe_embed()


        --blocking commands
    elseif (self.content:sub(1, 22) == 'moamen blocked_members') then
        self.message:reply(#Block:blocked_members_tbl() .. ' blocked member')

    elseif (self.content:sub(1, 12) == 'moamen block') then
        self:block_command()

    elseif (self.content:sub(1, 14) == 'moamen unblock') then
        self:unblock_command()


    elseif (self.channel.id == Enums.channels.your_doings or
            self.channel.id == Enums.channels.your_games) then
        pcall(function()
            self.message:addReaction('👍🏿')
            self.message:addReaction('👎🏿')
        end)
    end
end


function message_handler:shop_embeds_command()
    if not self.author_member:hasPermission('administrator') then
        return
    end
    do
        local rooms_buttons = discordia.Components {
            discordia.Button('fh_request') -- id
                :label 'إنشاء'
                :style 'success'
        }

        self.client:getChannel(Enums.channels.fh_embed_channel):sendComponents({
            embed = {
                title = 'عرض خدمة',
                description = 'اعرض خدمتك التطويرية للربح منها',
                color = discordia.Color.fromRGB(0, 0, 0).value,
            }
        }, rooms_buttons)
    end

    local rooms_buttons = discordia.Components {
        discordia.Button('lfd_request') -- id
            :label 'إنشاء'
            :style 'success'
    }

    self.client:getChannel(Enums.channels.lfd_embed_channel):sendComponents({
        embed = {
            title = 'طلب خدمة',
            description = 'ابحث عن مطورين لمساعدتك في تطوير لعبتك',
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }, rooms_buttons)
end


function message_handler:fe_embed()
    if not self.author_member:hasPermission('administrator') then
        return
    end

    local replied_to_msg = self.message.referencedMessage

    if not replied_to_msg then
        self.message:reply('please use this command as a reply to a message')
        return
    end

    local embed = {
        author = {
            name = replied_to_msg.author.username,
            icon_url = replied_to_msg.author.avatarURL
        },
        description = 'made by ' .. replied_to_msg.author.mentionString
    }

    --copied and pasted from satckoverflow
    local function find_links(message)
        local content = message.content
        local links = {}

        for link in content:gmatch('https?://[%w-_%.%?%.:/%+=&]+') do
            table.insert(links, link)
        end

        return links
    end

    -- check for image attachments
    local attachment = replied_to_msg.attachments[1] -- a table of attachments(an attachment is any file like an image)
    if attachment then
        embed.image = { url = attachment.url }
    end

    --check for links
    local link = find_links(replied_to_msg)[1]
    if link then
        embed.description = embed.description .. '\n' .. string.format('[[video]](%s)', link:gsub(' ', ''))
    end

    self.guild:getChannel(Enums.channels.fetured):send {
        embed = embed
    }
end


function message_handler:wiki_command(message)
    local wiki = Wiki.new(message)
    wiki:process_message()
end


function message_handler:source_code_command()
    self.channel:send {
        embed = {
            title = 'source code',
            description = "repo: [moamen](https://github.com/notpythonics/moamen)\n`git clone https://github.com/notpythonics/moamen`\n-->change enums and replace token\n->run batch file\nyou can't be a contributor go away",
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }
end


function message_handler:roles_embed_command()
    if not self.author_member:hasPermission('administrator') then
        return
    end

    local roles_embed = Roles_Embed.new(self.message, self.client)
    roles_embed:bind_interaction_event()

    roles_embed:send()
end


function message_handler:unban_command()
    local id_num = self.content:match('%d+') -- first number(IDs are numbers)

    if not id_num or not self.author_member:hasPermission('administrator') then
        return
    end

    if self.guild:unbanUser(id_num, 'moamen forgives him') then
        self.channel:send {
            embed = {
                title = self.client:getEmoji(Enums.emojis.no_whipping).mentionString .. 'someone was unbanned',
                description = self.author_member.username .. ' unbanned a member who has this id -->\n`' .. id_num .. '`',
                color = discordia.Color.fromRGB(0, 102, 0).value,
                footer = {
                    text = 'case number --> ' .. tostring(#self.guild:getBans())
                }
            }
        }
    else
        self.channel:send {
            embed = {
                description = self.author_member.username .. ' sorry I could not find a member by this id -->\n`' .. id_num .. '`',
                color = discordia.Color.fromRGB(0, 102, 0).value,
            }
        }
    end
end



-- who needs this function should be down there 
function message_handler:is_invalid_mention(f_member)
    if f_member.bot then return true end

    if not self.author_member:hasPermission('administrator') then
        return true
    end

    if f_member:hasPermission('administrator') then
        return true
    end

    return false
end

function message_handler:block_command()
    local f_mention = self.mentionedUsers.first
    if not f_mention then return end

    local f_member = self.guild:getMember(f_mention.id)

    if self:is_invalid_mention(f_member) then
        return
    end

    local block = Block.new(f_member, f_mention.id)
    block:append()
end


function message_handler:unblock_command()
    local f_mention = self.mentionedUsers.first
    if not f_mention then return end

    local f_member = self.guild:getMember(f_mention.id)

    if self:is_invalid_mention(f_member) then
        return
    end

    local block = Block.new(f_member, f_mention.id)
    block:remove()
end


function message_handler:kick_command()
    local f_mention = self.mentionedUsers.first
    if not f_mention then return end

    local f_member = self.guild:getMember(f_mention.id)

    if self:is_invalid_mention(f_member) then
        return
    end

    f_member:kick('moamen does not like him')

    self.channel:send {
        embed = {
            title = '👼🏿 ' .. f_member.username .. ' was kicked',
            description = self.author_member.username .. ' kicked a member',
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }
end


function message_handler:assign_member_role_command()
    local function send()
        self.channel:send {
            embed = {
                title = 'لم تعطا رتبة ❎',
                description = 'منشن ناقص او رتبة مشرف',
                color = discordia.Color.fromRGB(0, 0, 0).value,
            }
        }
    end

    local f_mention = self.mentionedUsers.first
    if not f_mention then send() return end

    if not self.author_member:hasPermission('administrator') then
        send()
        return
    end

    local f_member = self.guild:getMember(f_mention.id)
    f_member:addRole(Enums.roles.member)

    self.channel:send {
        embed = {
            title = '✍🏿 ' .. f_mention.name .. ' اعطيا رتبة',
            description = 'عند امتلاكك لرتبة هذي تقدر تغير اسمك',
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }
end


function message_handler:untimeOut_command()
    local f_mention = self.mentionedUsers.first
    if not f_mention then return end

    local f_member = self.guild:getMember(f_mention.id)

    if self:is_invalid_mention(f_member) then
        return
    end

    f_member:removeTimeout()

    self.channel:send {
        embed = {
            title = '✅ ' .. f_member.username .. ' was untimedOut',
            description = self.author_member.username .. ' removed a timeout from a member',
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }
end


function message_handler:ban_command()
    local f_mention = self.mentionedUsers.first
    if not f_mention then return end

    local f_member = self.guild:getMember(f_mention.id)

    if self:is_invalid_mention(f_member) then
        return
    end

    local duration = math.min(Shared.GET_DURATION(self.content), 7)
    print('ban duration in days --> ', duration)
    f_member:ban('moamen does not like him', duration)

    self.channel:send {
        embed = {
            title = self.client:getEmoji(Enums.emojis.whipp).mentionString .. ' ' .. f_member.username .. ' was banned',
            description = self.author_member.username .. ' banned a member\nduration: `' .. tostring(duration) .. ' days`',
            color = discordia.Color.fromRGB(0, 0, 0).value,
            footer = {
                text = 'case ' .. tostring(#self.guild:getBans())
            }
        }
    }
end


function message_handler:timeOut_command()
    local f_mention = self.mentionedUsers.first
    if not f_mention then return end

    local f_member = self.guild:getMember(f_mention.id)

    if self:is_invalid_mention(f_member) then
        return
    end

    local duration = Shared.GET_DURATION(self.content) * 60     -- 1 minute if GET_DURATION returns 1
    f_member:timeoutFor(duration)

    self.channel:send {
        embed = {
            title = '✅ ' .. f_member.username .. ' was timedOut',
            description = self.author_member.username .. ' timedOut a member\nduration: `' .. tostring(duration / 60) .. ' minutes`',
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }
end

return message_handler