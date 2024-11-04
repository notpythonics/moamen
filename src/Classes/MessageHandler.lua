local discordia = require("discordia")
local Predicates = require("../Utility/Predicates")
local Commands = require("../Dictionary/Commands")
local Block = require("../Utility/Block")
local http = require('coro-http')

local MessageHandler = {}
MessageHandler.__index = MessageHandler

function MessageHandler.new(message)
    local self = setmetatable({}, MessageHandler)
    self.content = message.content
    self.author_member = message.member
    self.author = message.author -- User obj
    self.mentionedUsers = message.mentionedUsers
    self.guild = message.guild
    self.channel = message.channel
    self.attachment = message.attachment
    self.attachments = message.attachments
    self.mentionedChannels = message.mentionedChannels
    self.mentionedRoles = message.mentionedRoles
    self.message = message
    return self
end

function MessageHandler.FindLinks(content)
    local links = {}

    for link in content:gmatch("https?://[%w-_%.%?%.:/%+=&]+") do
        table.insert(links, link)
    end

    return links
end

function MessageHandler:Add_like_and_dislike()
    pcall(function()
        self.message:addReaction("👍🏿")
        self.message:addReaction("👎🏿")
    end)
end

function MessageHandler:CreateThread()
    pcall(function()
        self.channel:startThread({
            name = self.author.username -- only required input
        }, self.message)
    end)
end

function MessageHandler:AddingReactions()
    -- Adding what reaction
    if (self.content:sub(1, 4) == "what" or
            self.content:sub(1, 3) == "wat") then
        pcall(function()
            self.message:addReaction(Enums.Emojis.What)
        end)
        return
    end

    -- Adding like and dislike reactions
    if (self.channel.id == Enums.Channels.your_doings) then
        if self.attachment or #self.FindLinks(self.content) > 0 then
            self:Add_like_and_dislike()
            self:CreateThread()
        else
            if not self.content:match("fe_embed") then
                if not self.author_member:hasPermission("administrator") then
                    self.message:delete()
                end
            else
                if not Predicates.isModerator_v(self.author_member) then
                    self.message:delete()
                end
            end
        end
    elseif (self.channel.id == Enums.Channels.your_games) then
        if #self.FindLinks(self.content) == 0 then -- Zero is true in lua
            if not self.author_member:hasPermission("administrator") then
                self.message:delete()
            end
        else
            if not self.content:find("/games/") and not self.content:find("ExperienceDetails") then
                self.message:delete()
                return
            end
            self:Add_like_and_dislike()
            self:CreateThread()
        end
    end
end

function MessageHandler:Filter()
    -- Member mentioned moderators?
    if not Predicates.isModerator_v(self.author_member) then
        for _, role in ipairs(self.mentionedRoles:toArray()) do
            if role.id == Enums.Roles.Moderator then
                self.channel:send {
                    content = self.author.mentionString .. " إشعارك للمشرف دون سبب مقنع قد يفضي للكتم "
                }
            end
        end
    end
    -- thanked a member
    if self.content:match("شكرا") then
        self.channel:send {
            content = "استخدم امر thank/ لتشكر العضو",
            reference = {
                message = self.message,
                mention = true,
            }
        }
    end

    -- Message from a hacked member?
    if self.content:sub(1, 14) == '50$ from steam'
        or self.content:sub(1, 14) == '$50 from steam'
        or self.content:sub(1, 18) == 'Bro steam gift 50$'
        or self.content:sub(1, 14) == "steam gift 50$"
        or self.content:find("اخونا ادريس") then -- hehe loser
        self.message:delete()
        Block.Append({ self.author_member }, self.channel, true)
        return
    end
end

function MessageHandler:ConvertToMp4()
    local files = {}
    if self.attachment then
        for _, attachment in ipairs(self.attachments) do
            if attachment.content_type then
                if attachment.content_type:match("x-matroska") then -- mkv --> video\x-matroska
                    -- http request the file's body
                    local res, body = http.request("GET", self.attachment.url)

                    table.insert(files, { "vid.mp4", body })
                end
            end
        end
    end
    if #files > 0 then
        self.channel:send {
            files = files,
            reference = {
                message = self.message,
                mention = true,
            },
            embed = {
                description = "A mkv file was implicitly converted to an mp4",
                footer = {
                    icon_url = self.author.avatarURL,
                    text = self.author.username .. "'s"
                },
                color = Enums.Colors.Default
            }
        }
    end
end

function MessageHandler:Process()
    coroutine.wrap(function()
        self:Filter()
        self:AddingReactions()
        self:ConvertToMp4()
    end)()

    self.content = self.content:lower() -- Lower the content
    if self.content:sub(1, 6) ~= _G.Prefix and self.content:sub(1, 2) ~= _G.Another_Prefix then return end

    -- Erasing prefixes
    self.content = self.content:gsub(_G.Prefix, "")
    if self.content == "" then return end
    self.content = self.content:gsub(_G.Another_Prefix, "")
    if self.content == "" then return end
    -- char-set https://www.lua.org/pil/20.2.html
    local raw_message = self.content:match("[%a_]+") -- Find first string
    if self.content == "" then return end
    raw_message = raw_message:gsub(" ", "")          -- Remove spacies
    --print("raw", raw_message, "\nplain", self.content)

    if Commands[raw_message] then
        Commands[raw_message](self)
        return
    end
end

return MessageHandler
