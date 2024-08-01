local discordia = require('discordia')
local Shared = require('../Shared')

local block = {}
block.__index = block

function block:new(target_member, target_id)
    self = setmetatable({}, block)

    self.target_id = target_id
    self.target_member = target_member

    return self
end

-- prefer block:append()
-- punsh does not insert the id into BLOCKED_MEMBERS table
function block:punsh()
    self.target_member:addRole('1266515724252483606')

    local target_roles = self.target_member.roles:toArray()
    for _, role in pairs(target_roles) do
        if role.id ~= '1266515724252483606' then
            self.target_member:removeRole(role.id)
        end
    end
end

function block:append()
    self:punsh()
    if not Shared.TABLE_FIND(Shared.BLOCKED_MEMBERS, self.target_id) then
        table.insert(Shared.BLOCKED_MEMBERS, self.target_id)
    end
end

function block:remove()
    self.target_member:removeRole('1266515724252483606')
    self.target_member:addRole('1061699881531605072')

    local pos = Shared.TABLE_FIND(Shared.BLOCKED_MEMBERS, self.target_id)
    if not pos then
        return
    end
    table.remove(Shared.BLOCKED_MEMBERS, pos)
end

function block:find()
    if Shared.TABLE_FIND(Shared.BLOCKED_MEMBERS, self.target_id) then
        return true
    end
    return false
end

return block