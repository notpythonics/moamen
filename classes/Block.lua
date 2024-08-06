local discordia = require('discordia')
local Shared = require('../Shared')
local Enums = require('../Enums')

local block = {}
block.__index = block

-- an array to store blocked members IDs
local blocked_members = {}

function block:blocked_members_tbl()
    return blocked_members
end

function block.new(target_member, target_id)
    local self = setmetatable({}, block)

    self.target_id = target_id
    self.target_member = target_member

    return self
end

-- prefer block:append()
-- punsh does not insert the id into BLOCKED_MEMBERS array
function block:punsh()
    self.target_member:addRole(Enums.roles.blocked)

    local target_roles = self.target_member.roles:toArray()
    for _, role in pairs(target_roles) do
        if role.id ~= Enums.roles.blocked then
            self.target_member:removeRole(role.id)
        end
    end
end

function block:append()
    self:punsh()
    if not Shared.TABLE_FIND(blocked_members, self.target_id) then
        table.insert(blocked_members, self.target_id)
    end
end

function block:remove()
    self.target_member:removeRole(Enums.roles.blocked)
    self.target_member:addRole(Enums.roles.member)

    local pos = Shared.TABLE_FIND(blocked_members, self.target_id)
    if not pos then
        return
    end
    table.remove(blocked_members, pos)
end

function block:find()
    if Shared.TABLE_FIND(blocked_members, self.target_id) then
        return true
    end
    return false
end

return block