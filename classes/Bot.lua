local discordia = require('discordia')
local timer = require('timer')
local discordia_components = require("discordia-components")
local Components = discordia_components.Components

local Message_Handler = require('./Message_Handler')
local Block = require('./Block')

local bot = {}
bot.__index = bot

function bot:new(token_)
    self        = setmetatable({}, bot)

    self.client = discordia.Client():enableAllIntents() -- Client() gets retruned only once
    self.token  = token_

    return self
end

function bot:bind_events()

    self.client:on('reactionAddUncached', function(channel, message_id, _, user_id)
        local rec_adder = self.client:getUser(user_id)
        local message = channel:getMessage(message_id)

        local delete_this_reaction = message.reactions:find(function(r)
            return r.emojiName == "delete_this"
        end)

        if not delete_this_reaction then
            return end

        if(delete_this_reaction.count >= 4) then
            message:delete()
            local message_user = message.member.user
            message.channel:send{
                embed = {
                    --description = message_user.mentionString .. 'رسالة لك انحذفت لأن لها 4 ' .. self.client:getEmoji('1265414312483229706').mentionString,
                    description = message_user.mentionString .. 'a message of yours was deleted because it had 4' .. self.client:getEmoji('1265414312483229706').mentionString,
                    color = discordia.Color.fromRGB(0, 0, 0).value,
                }
            }
        end
    end)


    do
        local message_handler = Message_Handler:new(self.client)

        self.client:on('messageCreate', function(message)
            local block = Block:new(message.guild.members:get(message.author.id), message.author.id)
            if block:find() then
                block:append()
                message:delete()
                return
            end

            -- do not click on the link
            if message.content == '$50 from steam [steamcommunity.com/gift/32360572365825 ](https://zws.im/%F3%A0%81%A8%E2%80%8D%F3%A0%81%AF%F3%A0%81%A2%F3%A0%81%BA%F3%A0%81%AE%F3%A0%81%B5)' then
                block:append()
                message:delete()
                return
            end


            message_handler:handle(message)
        end)
    end


    self.client:on('memberJoin', function(member)
        timer.sleep(3000)
        member:addRole('1061699881531605072')
    end)
end

function bot:run()
    self.client:run('Bot ' .. self.token)
    self:bind_events()
end

return bot