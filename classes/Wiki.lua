local discordia = require('discordia')

local wiki = {}

wiki.__index = wiki

function wiki:new(message)
    local function remove_prefix(str)
        return str:sub(12)
    end

    local function remove_spaces(str)
        return string.gsub(str, ' ', '')
    end

    self = setmetatable({}, wiki)

    self.message = message
    self.msg = remove_spaces(remove_prefix(message.content))
    self.channel = message.channel

    return self
end

function wiki:process_message()
    print(self.msg)

    if(self.msg == 'int' or self.msg == 'ints' or self.msg == 'intgers' or self.msg == 'intger') then
        self.channel:send {
            embed = {
                title = 'Lua has no integer type',
                description = "every number in lua is a double or a float\n`source:https://www.lua.org/pil/2.3.html`\nwhy --> becuase it doesn't need it",
                color = discordia.Color.fromRGB(0, 0, 0).value,
            }
        }
    end

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
end

-- classes/images/first_mention.png

return wiki