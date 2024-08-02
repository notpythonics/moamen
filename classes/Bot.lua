local discordia = require('discordia')
local timer = require('timer')
local discordia_components = require("discordia-components")
local Components = discordia_components.Components
local Message_Handler = require('./Message_Handler')
local Block = require('./Block')
local Reactions = require('./Reactions')
local Enums = require('../Enums')

local bot = {}
bot.__index = bot

function bot:new(token_)
    self = setmetatable({}, bot)

    self.client = discordia.Client():enableAllIntents() -- Client() gets retruned only once
    self.token = token_

    return self
end

function bot:bind_events()

    do
        local reactions = Reactions:new(self.client)

        self.client:on('reactionAddUncached', function(channel, message_id)
            reactions:handle(channel:getMessage(message_id))
        end)

        self.client:on('reactionAdd', function(reaction, user_id)
            reactions:handle(reaction.message)
        end)
    end


    do
        local message_handler = Message_Handler:new(self.client)

        self.client:on('messageCreate', function(message)
            local block = Block:new(message.guild.members:get(message.author.id), message.author.id)
            if block:find() then
                block:append()
                message:delete()
                return
            end

            --a message from a hacked member?
            if message.content:sub(1, 14) == '$50 from steam' then
                message.guild:getChannel(Enums.channels.bots_cmds):send {
                    embed = {
                        title = '👨🏿‍💻 a hacked account',
                        description = 'a hacked account was detected and punshed\nbecarful of steam scam links boy!',
                        color = discordia.Color.fromRGB(0, 0, 0).value,
                    }
                }
                block:append()
                message:delete()
                return
            end

            message_handler:handle(message)
        end)
    end


    self.client:on('memberJoin', function(member)
        timer.sleep(3000)
        member:addRole(Enums.roles.member)
    end)

end

function bot:run()
    self.client:run('Bot ' .. self.token)
    self:bind_events()
end

return bot