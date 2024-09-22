local EventsToBind = require("../Dictionary/EventsToBind")

local Bot = {}
Bot.__index = Bot
setmetatable(Bot, Bot)

local function INIT()
    for eventName, eventFun in pairs(EventsToBind) do
        _G.Client:on(eventName, eventFun)
    end
end

function Bot.__call(_, token)
    INIT()

    _G.Client:run("Bot " .. token)
end

return Bot
