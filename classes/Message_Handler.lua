local discordia = require('discordia')
local Roles_Embed = require('./Roles_Embed')
local Wiki = require('./Wiki')

local message_handler = {}

message_handler.__index = message_handler

function GET_DURATION(str)
    local id_num = str:match('%d+')
    do
        local _, endp = string.find(str, id_num)
        str = str:sub(endp+1)
        --print('str -->', str)
        str = str:match('%d+')
        --print('str -->', str)
        if str then
            return tonumber(str)
        end
    end
    return 60
end

function message_handler:new(client)
    self = setmetatable({}, message_handler)

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
    self.message = message

    if (self.content:sub(1, 14) == 'moamen timeout' or
        self.content:sub(1, 11) == 'moamen mute')  then
        self:timeOut_command()
    elseif(self.content:sub(1, 16) == 'moamen untimeout' or
        self.content:sub(1, 13) == 'moamen unmute') then
        self:untimeOut_command()

    elseif (self.content:sub(1, 18) == 'moamen roles_embed') then
        self:roles_embed_command()

    elseif (self.content:sub(1, 20) == 'moamen assign_member') then
        self:assign_member_role_command()

    elseif (self.content:sub(1, 18) == 'moamen source_code') then
        self:source_code_command()

    elseif (self.content:sub(1, 11) == 'moamen wiki') then
        self:wiki_command(self.message)

    elseif (self.channel.id == '1028991151467933758' or
            self.channel.id == '1202308818139091026') then
        self.message:addReaction('👍🏿')
        self.message:addReaction('👎🏿')
    end
end


function message_handler:wiki_command(message)
    local wiki = Wiki:new(message)
    wiki:process_message()
end


function message_handler:source_code_command()
    self.channel:send {
        embed = {
            title = 'source code',
            description = "البوت مبرمج بlua\n`repo: https://github.com/notpythonics/moamen\ngit clone https://github.com/notpythonics/moamen\n-->run batch file`\nyou can't be a contributor go away",
            color = discordia.Color.fromRGB(0, 0, 0).value,
        }
    }
end


IS_ROLES_EMBED_SENT = false
function message_handler:roles_embed_command()
    if IS_ROLES_EMBED_SENT then
        self.message:reply('في امبيد موجودة')
        return
    end

    local author_member = self.guild:getMember(self.author.id)

    local roles_embed = Roles_Embed:new(self.message, self.client)
    roles_embed:bind_interaction_event()

    if author_member:hasPermission('administrator') then
        roles_embed:send()
        IS_ROLES_EMBED_SENT = true
    end
end


-- who needs this function should be down there 
local function is_invalid_mention(f_mention)
    if not f_mention then return true end
    if f_mention.bot then return true end
end

function message_handler:assign_member_role_command()
    local f_mention = self.mentionedUsers.first

    if (is_invalid_mention(f_mention)) then
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

    local author_member = self.guild:getMember(self.author.id)

    if author_member:hasPermission('administrator') then
        local f_member = self.guild:getMember(f_mention.id)

        self.channel:send {
            embed = {
                title = '✅ ' .. f_member.name .. ' was untimedOut',
                description = author_member.name .. ' removed a timeout from a member',
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

    local author_member = self.guild:getMember(self.author.id)

    if author_member:hasPermission('administrator') then
        local f_member = self.guild:getMember(f_mention.id)
        local duration = GET_DURATION(self.content) * 60 -- 1 minute if GET_DURATION returns 1
        f_member:timeoutFor(duration)

        self.channel:send {
            embed = {
                title = '✅ ' .. f_member.name .. ' was timedOut',
                description = author_member.name .. ' timedOut a member\nduration: `' .. tostring(duration/60) .. ' minutes`',
                color = discordia.Color.fromRGB(0, 0, 0).value,
            }
        }
    end
end

return message_handler