local discordia = require('discordia')
local timer = require('timer')

local Shared = require('../Shared')
local Enums = require('../Enums')

local external_functions = {}

function external_functions.delete_this_reaction(message)
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
                description = message_user.mentionString .. 'a message of yours was deleted because it had 4' .. message.guild:getEmoji(Enums.emojis.delete_this).mentionString,
                color = discordia.Color.fromRGB(0, 0, 0).value,
            }
        }
    end
end

function external_functions.member_join(member)
    if member.user.bot and not Shared.IS_BOTS_ENTRY_ALLOWED then
        member:kick('Bots entry is disallowed')
        return
    end
    timer.sleep(3000)
    pcall(function ()
        member:addRole(Enums.roles.member)
    end)
end

return external_functions