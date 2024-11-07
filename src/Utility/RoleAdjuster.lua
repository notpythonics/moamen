local RoleAdjuster = {}
RoleAdjuster.__index = RoleAdjuster

function RoleAdjuster.RemoveTierRoles(member, roleName)
    assert(type(roleName) == "string", "Invalid Argument to RoleAdjuster")

    local roleNameWithoutNum = roleName:gsub("%d+", "")
    for i = roleName:match("%d+") + 3, 0, -1 do
        local indexedName = roleNameWithoutNum .. i
        local roleID = Enums.Roles.Levels[indexedName]

        if roleID then
            member:removeRole(Enums.Roles.Levels[indexedName])
        end
    end
end

function RoleAdjuster.SetTierRole(member, roleName)
    assert(type(roleName) == "string", "Invalid Argument to RoleAdjuster")

    if Enums.Roles.Levels[roleName] then
        member:addRole(Enums.Roles.Levels[roleName])
    end
end

return RoleAdjuster
