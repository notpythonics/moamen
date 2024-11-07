local discordia = require("discordia")
local tools = require("discordia-slash").util.tools()

local Bot = require("./src/Classes/Bot.lua")
local Enums = require("./src/Dictionary/Enums")

-- Globals
_G.Prefix = "moamen"
_G.Another_Prefix = "mn"
_G.Client = discordia.Client():enableAllIntents() -- Client() gets returned only once
_G.Client:useApplicationCommands()
_G.Enums = Enums
_G.IsBots_Entry_Allowed = false
_G.Docs = {}

local token = ""
--[[local botObj = ]]Bot(token)
