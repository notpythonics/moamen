local discordia = require('discordia')
local Roles_Embed = require('./Roles_Embed')
local Wiki = require('./Wiki')
local Block = require('./Block')
local Shared = require('../Shared')

local message_handler = {}

message_handler.__index = message_handler

function message_handler:new(client)
    self        = setmetatable({}, message_handler)

    self.client = client

    return self
end

function message_handler:handle(message)
    self.author = message.author
    if self.author.bot then return end

    self.guild = message.guild -- a guild is your server
    self.content = message.content
    self.mentionedUsers = message.mentionedUsers
    self.channel = message.channel
    self.author_member = message.guild.members:get(self.author.id)
    self.message = message

    if (self.content:sub(1, 14) == 'moamen timeout' or
        self.content:sub(1, 11) == 'moamen mute')  then
        self:timeOut_command()

    elseif (self.content:sub(1, 16) == 'moamen untimeout' or
        self.content:sub(1, 13) == 'moamen unmute') then
        self:untimeOut_command()

    elseif (self.content:sub(1, 10) == 'moamen ban') then
        self:ban_command()

    elseif (self.content:sub(1, 12) == 'moamen unban') then
        self:unban_command()

    elseif (self.content:sub(1, 18) == 'moamen roles_embed') then
        self:roles_embed_command()

    elseif (self.content:sub(1, 20) == 'moamen assign_member') then
        self:assign_member_role_command()

    elseif (self.content:sub(1, 18) == 'moamen source_code') then
        self:source_code_command()

    elseif (self.content:sub(1, 11) == 'moamen wiki') then
        self:wiki_command(self.message)

    elseif (self.content:sub(1, 11) == 'moamen kick') then
        self:kick_command()

    elseif (self.content:sub(1, 15) == 'moamen fe_embed') then
        self:fe_embed()

    elseif (self.content:sub(1, 12) == 'moamen block') then
        self:block_command()

    elseif (self.content:sub(1, 14) == 'moamen unblock') then
        self:unblock_command()

    elseif (self.channel.id == '1028991151467933758' or
            self.channel.id == '1202308818139091026') then
        self.message:addReaction('👍🏿')
        self.message:addReaction('👎🏿')
    end
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

    -- check for image attachments
    local attachments = replied_to_msg.attachments -- a table of attachments(an attachment is any file like an image)
    if attachments  then
        local f_attachment = attachments[1] -- git first attachment
        if f_attachment then
            embed.image = { url = f_attachment.url }
        end
    end

    self.guild:getChannel('1266047330294169672'):send {
        embed = embed
    }
end


function message_handler:wiki_command(message)
    local wiki = Wiki:new(message)
    wiki:process_message()
end


function message_handler:source_code_command()
    self.channel:send {
        embed = {
            title = 'source code',
            description = "البوت مبرمج بlua\n`repo:https://github.com/notpythonics/moamen\ngit clone https://github.com/notpythonics/moamen\n-->run batch file`\nyou can't be a contributor go away",
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }
end


function message_handler:roles_embed_command()
    if Shared.IS_ROLES_EMBED_SENT then
        self.message:reply('في امبيد موجودة')
        return
    end

    local roles_embed = Roles_Embed:new(self.message, self.client)
    roles_embed:bind_interaction_event()

    if self.author_member:hasPermission('administrator') then
        roles_embed:send()
        Shared.IS_ROLES_EMBED_SENT = true
    end
end



-- who needs this function should be down there 
local function is_invalid_mention(f_mention)
    if not f_mention then return true end
    if f_mention.bot then return true end
end

function message_handler:block_command()
    local f_mention = self.mentionedUsers.first
    if is_invalid_mention(f_mention) then
        return
    end

    if not self.author_member:hasPermission('administrator') then
        return
    end


    local f_member = self.guild:getMember(f_mention.id)

    if f_member:hasPermission('administrator') then
        return
    end


    local block = Block:new(f_member, f_mention.id)
    block:append()
end


function message_handler:unblock_command()
    local f_mention = self.mentionedUsers.first
    if is_invalid_mention(f_mention) then
        return
    end

    if not self.author_member:hasPermission('administrator') then
        return
    end


    local f_member = self.guild:getMember(f_mention.id)

    if f_member:hasPermission('administrator') then
        return
    end


    local block = Block:new(f_member, f_mention.id)
    block:remove()
end


function message_handler:kick_command()
    local f_mention = self.mentionedUsers.first
    if is_invalid_mention(f_mention) then
        return
    end

    if not self.author_member:hasPermission('administrator') then
        return
    end


    local f_member = self.guild:getMember(f_mention.id)

    if f_member:hasPermission('administrator') then
        return
    end


    f_member:kick('moamen does not like him')

    self.channel:send {
        embed = {
            title = '👼🏿 ' .. f_member.name .. ' was kicked',
            description = self.author_member.name .. ' kicked a member',
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }
end


function message_handler:assign_member_role_command()
    local f_mention = self.mentionedUsers.first

    if not self.author_member:hasPermission('administrator') then
        return
    end

    if is_invalid_mention(f_mention) then
        self.channel:send {
            embed = {
                title = 'لم تعطا رتبة ❎',
                description = 'منشن ناقص',
                color = discordia.Color.fromRGB(0, 0, 0).value,
            }
        }
        return
    end

    local f_member = self.guild:getMember(f_mention.id)
    f_member:addRole('1061699881531605072')

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
    if is_invalid_mention(f_mention) then
        return
    end

    if not self.author_member:hasPermission('administrator') then
        return
    end

    local f_member = self.guild:getMember(f_mention.id)
    f_member:removeTimeout()

    self.channel:send {
        embed = {
            title = '✅ ' .. f_member.name .. ' was untimedOut',
            description = self.author_member.name .. ' removed a timeout from a member',
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }
end


function message_handler:ban_command()
    local f_mention = self.mentionedUsers.first
    if is_invalid_mention(f_mention) then
        return
    end

    if not self.author_member:hasPermission('administrator') then
        return
    end

    local f_member = self.guild:getMember(f_mention.id)

    if f_member:hasPermission('administrator') then
        return
    end

    local duration = math.min(Shared.GET_DURATION(self.content), 7)
    print('ban duration in days --> ', duration)
    f_member:ban('moamen does not like him', duration)

    self.channel:send {
        embed = {
            title = self.client:getEmoji('1215330368694124544').mentionString .. ' ' .. f_member.name .. ' was banned',
            description = self.author_member.name .. ' banned a member\nduration: `' .. tostring(duration) .. ' days`',
            color = discordia.Color.fromRGB(0, 0, 0).value,
            footer = {
                text = 'case number --> ' .. tostring(#self.guild:getBans())
            }
        }
    }
end


function message_handler:unban_command()
    local id_num = self.content:match('%d+') -- first number(IDs are numbers)

    if not id_num then
        return
    end

    if not self.author_member:hasPermission('administrator') then
        return
    end

    if self.guild:unbanUser(id_num, 'moamen forgives him') then
        self.channel:send {
            embed = {
                title = self.client:getEmoji('1265702883806937331').mentionString .. 'someone was unbanned',
                description = self.author_member.name .. ' unbanned a member who has this id -->\n`' .. id_num .. '`',
                color = discordia.Color.fromRGB(0, 0, 0).value,
                footer = {
                    text = 'case number --> ' .. tostring(#self.guild:getBans())
                }
            }
        }
    else
        self.channel:send {
            embed = {
                description = self.author_member.name .. ' sorry I could not find a member by this id -->\n`' .. id_num .. '`',
                color = discordia.Color.fromRGB(0, 0, 0).value,
            }
        }
    end
end


function message_handler:timeOut_command()
    local f_mention = self.mentionedUsers.first
    if is_invalid_mention(f_mention) then
        return
    end

    if not self.author_member:hasPermission('administrator') then
        return
    end

    local f_member = self.guild:getMember(f_mention.id)

    if f_member:hasPermission('administrator') then
        return
    end

    local duration = Shared.GET_DURATION(self.content) * 60     -- 1 minute if GET_DURATION returns 1
    f_member:timeoutFor(duration)

    self.channel:send {
        embed = {
            title = '✅ ' .. f_member.name .. ' was timedOut',
            description = self.author_member.name .. ' timedOut a member\nduration: `' .. tostring(duration / 60) .. ' minutes`',
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }
end

return message_handler