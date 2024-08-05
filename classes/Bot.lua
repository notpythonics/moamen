local discordia = require('discordia')
local timer = require('timer')
local discordia_components = require("discordia-components")
local Components = discordia_components.Components
local Message_Handler = require('./Message_Handler')
local Block = require('./Block')
local Shop = require('./Shop')
local External_Functions = require('./External_Functions')
local Roles_Embed = require('./Roles_Embed')

local Shared = require('../Shared')
local Enums = require('../Enums')

local bot = {}
bot.__index = bot

function bot:new(token)
    self = setmetatable({}, bot)

    self.client = discordia.Client():enableAllIntents() -- Client() gets retruned only once
    self.token = token

    return self
end

function bot:bind_events()

    self.client:on('reactionAddUncached', function(channel, message_id)
        External_Functions.delete_this_reaction(channel:getMessage(message_id))
    end)

    self.client:on('reactionAdd', function(reaction, user_id)
        External_Functions.delete_this_reaction(reaction.message)
    end)


    do
        local message_handler = Message_Handler:new(self.client)

        self.client:on('messageCreate', function(message)
            if message.author.bot then return end

            ---- shop stuff
            ---------------------------------------
            if message.channel.type == 1 then -- if dm

                local requested_embed, to_type, type_work = Shop:process_stage(message)

                local function send(id)
                    local channel =  self.client:getChannel(id)

                    local rooms_buttons = discordia.Components {
                        discordia.Button('request_accept') -- id
                            :label 'قبول'
                            :style 'secondary',
                            discordia.Button('request_decline') -- id
                            :label 'رفض'
                            :style 'danger'
                    }

                    local sent_message = channel:sendComponents({
                            content = type_work,
                            embed = requested_embed
                        }, rooms_buttons)
                end

                if requested_embed then
                    Shared.REQUESTED_EMBEDS[message.author.username] = {
                        message.author.id,
                        requested_embed,
                        to_type
                    }

                    if to_type == 'lfd_request' then
                        send(Enums.channels.lfd_server)
                    else
                        send(Enums.channels.fh_server)
                    end
                end
                return
            end
            ---------------------------------------

            --blocking members
            local block = Block:new(message.guild.members:get(message.author.id), message.author.id)
            if block:find() then
                block:append()
                message:delete()
                return
            end

            --a message from a hacked member?
            if message.content:sub(1, 14) == '$50 from steam' or message.content:sub(1, 18) == 'Bro steam gift 50$' then
                message.guild:getChannel(Enums.channels.bots_cmds):send {
                    embed = {
                        title = '👨🏿‍💻 a hacked account',
                        description = 'a hacked account was detected and punished\nbe careful of Steam scam links!',
                        color = discordia.Color.fromRGB(0, 0, 102).value,
                    }
                }
                --block
                block:append()
                message:delete()
                return
            end

            message_handler:handle(message)
        end)
    end

    self.client:on('memberJoin', External_Functions.member_join)
end

function bot:run()
    self.client:run('Bot ' .. self.token)
    self:bind_events()
end

return bot