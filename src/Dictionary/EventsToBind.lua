local discordia = require("discordia")
local Interactions = require("./Interactions")
local SlashCommands = require("./SlashCommands")
local MessageHandler = require("../Classes/MessageHandler")
local Shop = require("../Utility/Shop")
local Block = require("../Utility/Block")
local timer = require("timer")
local http = require('coro-http')

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
    local channel = _G.Client:getChannel(Enums.Channels.Logs.Members_movements)

    channel:send {
        embed = {
            author = {
                name = member.username,
                icon_url = member.user.avatarURL
            },
            description = "✅ " .. member.mentionString .. " Joined the server",
            color = discordia.Color.fromRGB(1, 1, 1).value
        }
    }

    -- Are they a bot?
    if member.user.bot then
        -- Is bots entry allowed?
        if not _G.IsBots_Entry_Allowed then
            member:kick("Bots entry is disallowed")
            return
        end
        timer.sleep(3000)
        member:addRole(Enums.Roles.Bot)
        return
    end

    timer.sleep(3000)
    -- Are they blocked?
    if Block.IsIdBlocked(member.id) then
        Block.Punch(member)
        return
    end
    member:addRole(Enums.Roles.Member)
end

-- interactionCreate
function EventsToBind.interactionCreate(inter)
    local custom_id = inter.data.custom_id

    if Interactions[custom_id] then
        Interactions[custom_id](inter, custom_id)
    end
end

-- slashCommand
function EventsToBind.slashCommand(inter, command, args)
    local command_name = command.name

    if SlashCommands[command_name] then
        SlashCommands[command_name](inter, command, args)
    end
end

function EventsToBind.memberLeave(member)
    local channel = _G.Client:getChannel(Enums.Channels.Logs.Members_movements)

    channel:send {
        embed = {
            author = {
                name = member.username,
                icon_url = member.user.avatarURL
            },
            description = member.mentionString .. " Left the server",
            color = discordia.Color.fromRGB(1, 1, 1).value
        }
    }
end

-- Adding Reactions
local deleteThisConstant = 4

local function deleteThisTarget(message)
    if message.author.bot then return end
    local count = 0
    for _, reac in pairs(message.reactions:toArray()) do
        if reac.emojiHash == Enums.Emojis.Delete_this then
            count = count + 1
        end
    end

    if count >= deleteThisConstant then
        message.channel:send {
            content = message.author.mentionString .. " a message of yours was deleted because it had " .. deleteThisConstant .. message.guild:getEmoji(Enums.Emojis.Delete_this:match("%d+")).mentionString
        }
        message:delete()
    end
end

-- reactionAdd
function EventsToBind.reactionAdd(reaction, userid)
    local message = reaction.message
    -- Are they blocked?
    if Block.IsIdBlocked(userid) then
        local reactionAdderMember = message.guild:getMember(userid)
        reaction:delete()
        Block.Punch(reactionAdderMember)
        return
    end

    deleteThisTarget(message)
end

-- reactionAddUncached
function EventsToBind.reactionAddUncached(channel, messageId, hash, userid)
    -- Are they blocked?
    if Block.IsIdBlocked(userid) then
        local member = channel.guild:getMember(userid)
        Block.Punch(member)
        return
    end

    local message = channel:getMessage(messageId)
    deleteThisTarget(message)
end

-- messageDelete
function EventsToBind.messageDelete(message)
    local channel = _G.Client:getChannel(Enums.Channels.Logs.Message_holder)

    local embed = {
        author = {
            name = message.author.username,
            icon_url = message.author.avatarURL
        },
        description = "A message sent by " ..
            message.author.mentionString ..
            " was deleted in " .. message.channel.mentionString .. "\n**content:** " .. message.content,
        color = discordia.Color.fromRGB(1, 1, 1).value
    }

    local files = {}
    if message.attachment then
        for _, attachment in ipairs(message.attachments) do
            print(attachment.content_type)
            -- http request the file's body
            local res, body = http.request("GET", message.attachment.url)

            table.insert(files, { attachment.content_type, body })
        end
    end
    if #files > 0 then
        channel:send {
            files = files,
            embed = embed
        }
    end

    channel:send { embed = embed }
end

-- messageDeleteUncached
function EventsToBind.messageDeleteUncached(channel, messageId)
    local logChannel = _G.Client:getChannel(Enums.Channels.Logs.Message_holder)
    --local message = channel:getMessage(messageId)

    logChannel:send {
        embed = {
            description = "An uncached message was deleted in " .. channel.mentionString .. "\n**message Id:** `" .. messageId .. "`",
            color = discordia.Color.fromRGB(1, 1, 1).value
        }
    }
end

return EventsToBind
