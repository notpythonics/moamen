local discordia = require("discordia")
local Interactions = require("./Interactions")
local MessageHandler = require("../MessageHandler")
local Shop = require("../Shop")
local Block = require("../Block")
local timer = require("timer")

local EventsToBind = {}

-- messageCreate
function EventsToBind.messageCreate(message)
    if message.author.bot then return end

    if message.channel.type == 1 then -- If DM
        local created_embed, custom_id, type_work = Shop.process_stage(message)

        local function send(id)
            local channel = _G.Client:getChannel(id)

            channel:sendComponents({
                    content = type_work,
                    embed = created_embed
                },
                discordia.Components {
                    discordia.Button("request_accept") -- id
                        :label "قبول"
                        :style "secondary",
                    discordia.Button("request_decline") -- id
                        :label "رفض"
                        :style "danger"
                })
        end

        if created_embed then
            if _G.Shop_Requests[message.author.id] then
                return
            else
                _G.Shop_Requests[message.author.id] = {
                    created_embed,
                    custom_id,
                    message.author
                }
            end

            local shop_prefix = custom_id:match("lfd") or custom_id:match("fh") or custom_id:match("sell")
            send(Enums.Channels[shop_prefix .. "_server"])
        end
        return
    end

    -- Are they blocked?
    if Block.IsIdBlocked(message.author.id) then
        message:delete()
        Block.Punch(message.member)
        return
    end

    -- Handle message
    local MessageHandlerObj = MessageHandler.new(message)
    MessageHandlerObj:Process()
end

-- memberJoin
function EventsToBind.memberJoin(member)
    -- Are they a bot? is bots entry allowed?
    if member.user.bot and not _G.IsBots_Entry_Allowed then
        member:kick("Bots entry is disallowed")
        return
    end

    timer.sleep(3000)
    pcall(function()
        member:addRole(Enums.Roles.Member)
    end)
end

-- interactionCreate
function EventsToBind.interactionCreate(inter)
    local custom_id = inter.data.custom_id
    print("Interaction ID: ", custom_id)

    if Interactions[custom_id] then
        Interactions[custom_id](inter, custom_id)
    end
end

return EventsToBind
