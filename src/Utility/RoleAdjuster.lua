local RoleAdjuster = {}
RoleAdjuster.__index = RoleAdjuster

function RoleAdjuster.SetTierRoleByNameWithCleanup(member, roleName)
    assert(type(roleName) == "string", "Invalid Argument to RoleAdjuster Con")

    member:addRole(Enums.Roles.Levels[roleName])

    local roleNameWithoutNum = roleName:gsub("%d+", "")
    for i = roleName:match("%d+") + 3, 0, -1 do
        local indexedName = roleNameWithoutNum .. i
        local roleID = Enums.Roles.Levels[indexedName]

        if roleID and indexedName ~= roleName then
            member:removeRole(Enums.Roles.Levels[indexedName])
        end
    end
end

return RoleAdjuster
