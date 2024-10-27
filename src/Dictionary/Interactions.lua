-- Should I move this file to Dictionaries dir? Interactions file-erase handler function -- done
local discordia = require("discordia")
local dModals = require("discordia-modals")
local timer = require("timer")
local Predicates = require("../Utility/Predicates")
local Shop = require("../Utility/Shop")
local Block = require("../Utility/Block")

local Interactions = {}

-- Roles embed
function Interactions.roles_embed(inter)
    inter:replyDeferred(true)

    -- Create a channel
    local created_channel = inter.guild:createTextChannel(inter.member.username:sub(1, 2) ..
        " " .. inter.data.values[1] .. " 🔓")
    created_channel:setCategory(Enums.Categories.AskForRoles)

    -- Make it priavte
    created_channel:getPermissionOverwriteFor(inter.guild:getRole(Enums.Roles.Everyone)):denyPermissions(
        "readMessages")
    -- Make it visible to mods and the maker
    created_channel:getPermissionOverwriteFor(inter.guild:getRole(Enums.Roles.Moderator)):allowPermissions(
        "readMessages")
    created_channel:getPermissionOverwriteFor(inter.member):allowPermissions("readMessages")

    -- Mention the maker
    created_channel:send(inter.member.user.mentionString)

    -- Send an emebd to the created_channel
    created_channel:sendComponents({
        embed = {
            title = "روم التقديم",
            description = "شغلك واعمالك ارسلهم هنا",
            image = { url = Enums.Images.Header },
            color = Enums.Colors.Default
        }
    }, discordia.Components {
        discordia.Button("delete") -- id
            :label "حذف الروم"
            :style "danger",
        discordia.Button("close") -- id
            :label "(سكره)قفل الروم"
            :style "secondary" })

    inter:reply("إنشأ روم تحت")
end

do
    local function is_member(inter)
        if not Predicates.isModerator_v(inter.member) then
            if string.find(inter.channel.name, "🔒") then
                inter:updateDeferred()
                return true
            end
            inter.channel:send("صاحب التقديم ممنوع يحذف التكت")
            inter:updateDeferred()
            return true
        end
        return false
    end

    -- Close ticket
    function Interactions.close(inter)
        if is_member(inter) then return end

        if string.find(inter.channel.name, "🔒") then
            inter:replyDeferred(true)
            inter:reply("الروم مقفل اساسا")
            return
        end

        local user_who_made_channel = inter.channel:getFirstMessage().mentionedUsers.first
        if not user_who_made_channel then
            inter.channel:send("👩🏿‍🦱 صاحب التكت مو موجود")
            return
        end
        inter:updateDeferred()
        local member_who_made_channel = inter.guild:getMember(user_who_made_channel.id)

        --print(user_who_made_channel.name, '\n', member_who_made_channel.name)
        inter.channel:getPermissionOverwriteFor(member_who_made_channel):denyPermissions("sendMessages")
        inter.channel:send {
            embed = {
                title = "🔒 " .. inter.member.username .. " closed this channel",
                description = "you can't reopen this channel via any commands\n`note:`the owner of the ticket can still see the channel",
                color = Enums.Colors.Default
            }
        }

        local c_name = inter.channel.name
        local new_name = string.gsub(c_name, "🔓", "🔒")
        inter.channel:setName(new_name)
    end

    -- Delete ticket
    function Interactions.delete(inter)
        if is_member(inter) then return end

        pcall(function()
            inter.channel:send("الروم ينحذف بعد 3 ثواني")
            timer.sleep(3000)
            inter.channel:delete()
        end)
    end
end

-- Shop
local function foo(inter, custom_id)
    inter:replyDeferred(true)
    if _G.Shop_Requests[inter.user.id] then
        inter:reply("في إمبد مرسلة")
        return
    end
    if Block.IsIdBlocked(inter.user.id) then
        inter:reply("أنت محظور")
        return
    end
    inter:reply("خاص")
    Shop.append_working(inter.member.user, custom_id)
end
Interactions.lfd_request = foo
Interactions.fh_request = foo
Interactions.sell_request = foo

-- Request accept
function Interactions.request_accept(inter)
    local embed_author_id = (inter.message.embed.fields[2].value):match("%d+")
    local r_embed = _G.Shop_Requests[embed_author_id]
    if not r_embed then
        inter:replyDeferred(true)
        inter:reply("حدث خطأ")
        inter.message:delete()
        return
    end

    if not Predicates.isEmbedApprover_v(inter.member) then
        inter:replyDeferred(true)
        inter:reply("أنت مو مسؤولاً عن الإمبد")
        return
    end

    local user = _G.Client:getUser(embed_author_id)
    local message_link = Shop.send(inter.message, r_embed[1], r_embed[2])

    local p_channel = user:getPrivateChannel()
    if p_channel then
        p_channel:send {
            embed = {
                title = "الإمبد انقبل",
                description = "رابط الإمبد " .. message_link,
                color = discordia.Color.fromRGB(21, 73, 64).value
            }
        }
    end
    inter:updateDeferred()
    inter.message:delete()

    _G.Client:getChannel(Enums.Channels.Logs.Embeds):send {
        embed = {
            title = r_embed[2] .. " ✔️",
            description = "an embed requested by " .. user.mentionString .. ", was accepted by " .. inter.member.mentionString
        }
    }
    _G.Shop_Requests[embed_author_id] = nil
end

-- Request decline
function Interactions.request_decline(inter)
    local embed_author_id = (inter.message.embed.fields[2].value):match("%d+")
    local r_embed = _G.Shop_Requests[embed_author_id]
    if not r_embed then
        inter:replyDeferred(true)
        inter:reply("حدث خطأ")
        inter.message:delete()
        return
    end
    -- This is a reply
    inter:modal(dModals.Modal {
        title = "رفض الإمبد",
        id = "decline_reason_modal", -- id
        dModals.TextInput({
            id = "decline_reason_textInput",
            style = "paragraph",
            label = "السبب",
            placeholder = ""
        })
    })
end

-- Decline modal
function Interactions.decline_reason_modal(inter)
    local embed_author_id = (inter.message.embed.fields[2].value):match("%d+")
    local r_embed = _G.Shop_Requests[embed_author_id]
    if not r_embed then
        inter:replyDeferred(true)
        inter:reply("حدث خطأ")
        inter.message:delete()
        return
    end
    local user = _G.Client:getUser(embed_author_id)

    -- Get what"s in the textInput
    local textInputValue = inter.data.components[1].components[1].value

    local p_channel = user:getPrivateChannel()
    if p_channel then
        p_channel:send {
            embed = {
                title = "الإمبد انرفض",
                description = "السبب: " .. textInputValue,
                color = discordia.Color.fromRGB(146, 27, 56).value
            }
        }
    end
    inter:updateDeferred()
    inter.message:delete()

    _G.Client:getChannel(Enums.Channels.Logs.Embeds):send {
        embed = {
            title = r_embed[2] .. " ❌",
            description = "an embed requested by " .. user.mentionString .. ", was declined by " .. inter.member.mentionString,

            fields = {
                { name = "reason",
                    value = textInputValue,
                    inline = true }
            }
        }
    }
    _G.Shop_Requests[embed_author_id] = nil
end

return Interactions
