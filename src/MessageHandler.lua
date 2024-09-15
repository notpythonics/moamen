local Predicates = require("./Dictionaries/Predicates")
local Commands = require("./Dictionaries/Commands")

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
    self.mentionedChannels = message.mentionedChannels
    self.m_message = message
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
        self.m_message:addReaction("👍🏿")
        self.m_message:addReaction("👎🏿")
    end)
end

function MessageHandler:AddingReactions()
    -- Adding what reaction
    if (self.content:sub(1, 4) == "what" or
            self.content:sub(1, 3) == "wat") then
        pcall(function()
            self.m_message:addReaction("what:1268763017257160794")
        end)
        return
    end

    -- Adding like and dislike reactions
    if (self.channel.id == Enums.Channels.your_doings) then
        if self.attachment or #self.FindLinks(self.content) > 0 then
            self:Add_like_and_dislike()
        else
            if not self.content:match("fe_embed") then
                if not self.author_member:hasPermission("administrator") then
                    self.m_message:delete()
                end
            else
                if not Predicates.isModerator_v(self.author_member) then
                    self.m_message:delete()
                end
            end
        end
    elseif (self.channel.id == Enums.Channels.your_games) then
        if #self.FindLinks(self.content) == 0 then -- Zero is true in lua
            if not self.author_member:hasPermission("administrator") then
                self.m_message:delete()
            end
        else
            self:Add_like_and_dislike()
        end
    end
end

function MessageHandler:Process()
    self:AddingReactions()

    self.content = self.content:lower()                                                       -- Lower the content
    if self.content:sub(1, 6) ~= _G.Prefix and self.content:sub(1, 2) ~= _G.Another_Prefix then return end
    self.content = self.content:gsub(_G.Prefix, ""):gsub(_G.Another_Prefix, ""):gsub(" ", "") -- Erase prefix and spacies

    local raw_message = self.content:match("[%w_]+"):gsub("<", ""):gsub(">", "")
    -- print("raw", raw_message)
    -- print("plain", self.content)
    if Commands[raw_message] then
        Commands[raw_message](self)
        return
    end
    if Commands[self.content] then
        Commands[self.content](self)
        return
    end
    if Commands[raw_message:sub(1, 4)] then Commands[raw_message:sub(1, 4)](self) end -- For mute and wiki
end

return MessageHandler
