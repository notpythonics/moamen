local discordia = require("discordia")
local Interactions = require("./Interactions")
local SlashCommands = require("./SlashCommands")
local HowTo = require("./HowTo")
local MessageHandler = require("../Classes/MessageHandler")
local Shop = require("../Utility/Shop")
local Block = require("../Utility/Block")
local timer = require("timer")
local http = require('coro-http')
local tools = require("discordia-slash").util.tools()

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
            _G.Shop_Requests[message.author.id] = {
                created_embed,
                custom_id,
                message.author
            }

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
            color = Enums.Colors.Default
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

    -- Are they blocked?
    if Block.IsIdBlocked(member.id) then
        Block.Punch(member)
        return
    end

    timer.sleep(3000)
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

-- memberLeave
function EventsToBind.memberLeave(member)
    local channel = _G.Client:getChannel(Enums.Channels.Logs.Members_movements)

    channel:send {
        embed = {
            author = {
                name = member.username,
                icon_url = member.user.avatarURL
            },
            description = member.mentionString .. " Left the server",
            color = Enums.Colors.Default
        }
    }
end

do
    -- how many delete this emoji to delete a message
    local DELETE_THIS_COUNT = 4

    local function deleteThisTarget(message)
        if message.author.bot then return end
        local count = 0
        for _, reac in pairs(message.reactions:toArray()) do
            if reac.emojiHash == Enums.Emojis.Delete_this then
                count = count + 1
            end
        end

        if count >= DELETE_THIS_COUNT then
            message.channel:send {
                content = message.author.mentionString .. " a message of yours was deleted because it had " .. DELETE_THIS_COUNT .. message.guild:getEmoji(Enums.Emojis.Delete_this:match("%d+")).mentionString
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
end

-- messageDelete
function EventsToBind.messageDelete(message)
    if message.author.bot then return end

    local channel = _G.Client:getChannel(Enums.Channels.Logs.Message_holder)

    local embed = {
        author = {
            name = message.author.username,
            icon_url = message.author.avatarURL
        },
        description = "A message sent by " ..
            message.author.mentionString ..
            " was deleted in " ..
            message.channel.mentionString ..
            "\n\n**content:** " ..
            message.content ..
            "\n**referenced message: **" .. (message.referencedMessage and message.referencedMessage.link or "nil"),
        color = Enums.Colors.Default
    }

    local files = {}
    if message.attachment then
        for _, attachment in ipairs(message.attachments) do
            -- http request the file's body
            local res, body = http.request("GET", message.attachment.url)

            table.insert(files, { (attachment.content_type or "unknownType"), body })
        end
    end
    if #files > 0 then
        channel:send {
            files = files,
            embed = embed
        }
        return
    end

    channel:send { embed = embed }
end

-- messageDeleteUncached
function EventsToBind.messageDeleteUncached(channel, messageId)
    local logChannel = _G.Client:getChannel(Enums.Channels.Logs.Message_holder)
    --local message = channel:getMessage(messageId) -- errors

    logChannel:send {
        embed = {
            description = "An uncached message was deleted in " .. channel.mentionString .. "\n**message Id:** `" .. messageId .. "`",
            color = Enums.Colors.Default
        }
    }
end

-- ready
function EventsToBind.ready()
    local res, body = http.request("GET", "https://create.roblox.com/docs/reference/engine/classes")

    for title, path in string.gmatch(body, '{"title":"(.-)","path":"(.-)"}') do
        Docs[title] = "https://create.roblox.com/docs" .. path
    end
end

-- typingStart
function EventsToBind.typingStart(userId, channelId, timestamp)
    local logChannel = _G.Client:getChannel(Enums.Channels.Logs.Stalking_members)

    logChannel:send {
        embed = {
            description = _G.Client:getUser(userId).mentionString .. " started typing at `" .. timestamp .. "` in " .. _G.Client:getChannel(channelId).mentionString,
            color = Enums.Colors.Default
        }
    }
end

-- slashCommandAutocomplete
function EventsToBind.slashCommandAutocomplete(inter, cmd, focused)
    local function suggestOptions(source)
        local ac = {}
        local value = focused.value

        for title in pairs(source) do
            if #value > 0 then
                if title:lower():find(value:lower()) or value:sub(1, 1):lower() == title:sub(1, 1):lower() then
                    table.insert(ac, tools.choice(title, title))
                end
            end
            if #ac == 25 then
                break
            end
        end

        inter:autocomplete(ac)
    end

    if cmd.name == "docs" then
        suggestOptions(Docs)
    elseif cmd.name == "howto" then
        suggestOptions(HowTo)
    end
end

return EventsToBind
