local RoleAdjuster = {}
RoleAdjuster.__index = RoleAdjuster

function RoleAdjuster.new(member, roleArgName)
    local self = setmetatable({}, RoleAdjuster)
    self.member = member
    self.roleArgName = roleArgName
    member:addRole(Enums.Roles.Levels[roleArgName])
    return self
end

function RoleAdjuster:Adjust()
    local roleNameWithoutNum = self.roleArgName:gsub("%d+", "")
    for i = self.roleArgName:match("%d+") + 3, 0, -1 do
        local indexedName = roleNameWithoutNum .. i
        local roleID = Enums.Roles.Levels[indexedName]

        if roleID and indexedName ~= self.roleArgName then
            self.member:removeRole(Enums.Roles.Levels[indexedName])
        end
    end
end

return RoleAdjuster
