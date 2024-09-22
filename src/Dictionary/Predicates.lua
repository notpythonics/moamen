local Predicates = {}

function Predicates.isModerator_v(member)
    if member:hasPermission("administrator") then
        return true
    end
    local array = member.roles:toArray()
    for _, role in ipairs(array) do
        if role.id == _G.Enums.Roles.Moderator then
            return true
        end
    end
    return false
end

function Predicates.isValidToPunch(member)
    return not Predicates.isModerator_v(member) and not Predicates.isOwner_v(member)
end

function Predicates.isOwner_v(user)
    if user.id == "1167626422303596645" or user.id == "261969319188103179" then
        return true
    end
    return false
end

return Predicates
