local discordia = require('discordia')
local Enums = require('../Enums')

local reactions = {}
reactions.__index = reactions

function reactions:new(client)
    self = setmetatable({}, reactions)

    self.client = client

    return self
end

function reactions:handle(message)
    local delete_this_reaction = message.reactions:find(function(r)
        return r.emojiId == Enums.emojis.delete_this
    end)

    if not delete_this_reaction then
        return end

    if(delete_this_reaction.count >= 4) then
        message:delete()
        local message_user = message.member.user
        message.channel:send{
            embed = {
                --description = message_user.mentionString .. 'رسالة لك انحذفت لأن لها 4 ' .. self.client:getEmoji('1265414312483229706').mentionString,
                description = message_user.mentionString .. 'a message of yours was deleted because it had 4' .. self.client:getEmoji(Enums.emojis.delete_this).mentionString,
                color = discordia.Color.fromRGB(0, 0, 0).value,
            }
        }
    end
end

return reactions