local Discordia = require("discordia")
local Configuration = require("../Configuration.lua")
Discordia.extensions()

local function Embed(title, fields, color)
    return{
        embed = {
            title = title,
            fields = fields,
            footer = {
                text = "coasting bot"
            },
            color = color,
            timestamp = Discordia.Date():toISO("T", "Z")
        }
    }
end

local function GenerateKey()
    local UpperCaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local LowerCaseLetters = "abcdefghijklmnopqrstuvwxyz"
    local Numbers = "0123456789"
    local StringLength = 18

    local CharacterSet = UpperCaseLetters .. LowerCaseLetters .. Numbers
    local Output = ""

    for i = 1, StringLength do
        local Random = math.random(#CharacterSet)
        Output = Output .. string.sub(CharacterSet, Random, Random)
    end

    return Output
end

local function SplitString(text, chunksize)
    local Split = {}
    for i = 1, #text, chunksize do
        Split [#Split + 1] = text:sub(i, i + chunksize - 1)
    end
    
    return Split
end

local function ParseDiscordMention(mentioneduser)
    local CharactersToParse = {"<", ">", "!", "@"}

    for i, v in pairs(CharactersToParse) do
        mentioneduser = string.gsub(mentioneduser, v, "")
    end

    return mentioneduser
end

local Constants = {
    MentionUser = "<@%s>",
    Markdown = "```%s\n%s\n```"
}

--// Lua execution for the epic bot.
local Sandbox = setmetatable({ }, { __index = _G })

local function Code(str)
    return string.format("```lua\n%s```", str)
end

local function PrintLine(...)
    local Ret = {}

    for i = 1, select("#", ...) do
        local Arg = tostring(select(i, ...))
        table.insert(Ret, Arg)
    end
    return table.concat(Ret, "\t")
end

local function PrettyLine(...)
    local Ret = {}

    for i = 1, select("#", ...) do
        local Arg = PrettyPrint.strip(PrettyPrint.dump(select(i, ...)))
        table.insert(Ret, Arg)
    end
    return table.concat(Ret, "\t")
end

local function Execute(argument, message)
    if not argument then return end

    argument = argument:gsub("```\n?", "")

    local Lines = {}

    Sandbox.message = message

    Sandbox.print = function(...)
        table.insert(Lines, PrintLine(...))
    end

    Sandbox.p = function(...)
        table.insert(Lines, PrettyLine(...))
    end

    local fn, SyntaxError = load(argument, "CoastingBot", "t", Sandbox)
    if not fn then return message:reply(Embed("Coasting", {{name = "Syntax Error:", value = Code(SyntaxError)}}, Configuration.Colors.EpicalRed)) end

    local Success, RuntimeError = pcall(fn)
    if not Success then return message:reply(Embed("Coasting", {{name = "Runtime Error:", value = Code(RuntimeError)}}, Configuration.Colors.EpicalRed)) end
    
    Lines = table.concat(Lines, "\n")

    if #Lines > 1990 then
        Lines = Lines:sub(1, 1990)
    end

    return message:reply(Embed("Coasting", {{name = "Response:", value = Code(Lines)}}, Configuration.Colors.EpicalRed))
end

return{
    Embed = Embed,
    GenerateKey = GenerateKey,
    SplitString = SplitString,
    Constants = Constants,
    ParseDiscordMention = ParseDiscordMention,
    Execute = Execute,
}  