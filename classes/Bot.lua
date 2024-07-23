local dicordia = require('discordia')
local timer = require('timer')
local discordia_components = require("discordia-components")
local Components = discordia_components.Components

local Message_Handler = require('./Message_Handler')

local bot = {}
bot.__index = bot

function bot:new(token_)
    self        = setmetatable({}, bot)

    self.client = dicordia.Client() -- Client() gets retruned only once
    self.token  = token_

    return self
end

function bot:bind_events()
    local message_handler = Message_Handler:new(self.client)

    self.client:on('messageCreate', function(message)
        message_handler:handle(message)
    end)

    self.client:on('memberJoin', function(member)
        timer.sleep(1000 * 3)
        member.addRole('1061699881531605072')
    end)
end

function bot:run()
    self.client:run('Bot ' .. self.token)
    self:bind_events()
end

return bot