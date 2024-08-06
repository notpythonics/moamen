local discordia = require('discordia')

local wiki = {}

wiki.__index = wiki

function wiki.new(message)
    local function remove_prefix(str)
        return str:sub(12)
    end

    local function remove_spaces(str)
        return string.gsub(str, ' ', '')
    end

    local self = setmetatable({}, wiki)

    self.message = message
    self.msg = remove_spaces(remove_prefix(message.content))
    self.channel = message.channel

    return self
end

function wiki:process_message()
    --print('wiki message -->', self.msg)

    if (self.msg == 'ticket_close_algorithm') then
        self.channel:send {
            embed = {
                image = {
                    url = 'https://i.imgur.com/NWLksPt.png'
                },
                fields = {
                    {
                        name = "مالك الروم",
                        value = "```lua\nlocal user_who_made_channel = intr.channel:getFirstMessage().mentionedUsers.first\nlocal member_who_made_channel = self.guild:getMember(user_who_made_channel.id)\n```",
                    },
                },
            }
        }
        return
    end

    if (self.msg == 'cmds') then
        self.channel:send {
            embed = {
                --title = 'commands',
                fields = {
                    {name = 'muting',
                    value = '`mute`\n`unmute`',
                    inline = true},

                    --block commands
                    {name = 'blocking',
                    value = '`blocked_members` number of blocked members\n`block` blocks a member (removes roles)\n`unblock` unblocks a member',
                    inline = false},

                    {name = 'banning',
                    value = '`ban` the maximum is 7 days\n`unban`',
                    inline = false},

                    {name = 'embeds',
                    value = '`roles_embed` sends an embed for applying to roles (it binds inter event)\n`fe_embed` sends an embed of an attachment or link found in a referenced message\n`erase` stops the process of filling an embed shop',
                    inline = false},

                    {name = 'others',
                    value = '`assign_member` gives a member role\n`source_code`\n`kick`\n`wiki`',
                    inline = false},
                }
            }
        }
    end
end

-- classes/images/first_mention.png

return wiki