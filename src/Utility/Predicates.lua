local Predicates = {}

local function FindRole(array, roleID)
    for _, role in ipairs(array) do
        if role.id == roleID then
            return true
        end
    end
    return false
end

function Predicates.isModerator_v(member)
    if member:hasPermission("administrator") then return true end

    local array = member.roles:toArray()
    return FindRole(array, _G.Enums.Roles.Moderator)
end

function Predicates.isEmbedApprover_v(member)
    if member:hasPermission("administrator") then return true end

    local array = member.roles:toArray()
    return FindRole(array, _G.Enums.Roles.EmbedsApprover)
end

function Predicates.isRolesApprover_v(member)
    if member:hasPermission("administrator") then return true end

    local array = member.roles:toArray()
    return FindRole(array, _G.Enums.Roles.RolesApprover)
end

function Predicates.isValidToPunch_v(member)
    return not Predicates.isModerator_v(member) and not Predicates.isOwner_v(member)
end

function Predicates.isOwner_v(user)
    if user.id == "1167626422303596645" or user.id == "1082998290230038607" then
        return true
    end
    return false
end

return Predicates
