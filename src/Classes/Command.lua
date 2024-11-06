local Command = {}
Command.__index = Command

function Command.new(predicate, executeFunction)
    assert(type(predicate) == "function", "Predicate must be a function")
    assert(type(executeFunction) == "function", "Execute Function must be a function")

    local self = setmetatable({}, Command)
    self.predicate = predicate or function() return true end
    self.excuteFunction = executeFunction
    return self
end

function Command:Execute(MessageHandlerObj)
    assert(type(MessageHandlerObj) == "table")
    if not self.predicate(MessageHandlerObj.author_member) then return end

    self.excuteFunction(MessageHandlerObj)
end

return Command
