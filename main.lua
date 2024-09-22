local discordia = require("discordia")

local Bot = require("./src/Classes/Bot.lua")
local Enums = require("./src/Dictionary/Enums")

-- Globals
_G.Prefix = "moamen"
_G.Another_Prefix = "mn"
_G.Client = discordia.Client():enableAllIntents() -- Client() gets retruned only once
_G.Enums = Enums
_G.IsBots_Entry_Allowed = false
_G.Shop_Requests = {}

local token = ""
local botObj = Bot(token)
