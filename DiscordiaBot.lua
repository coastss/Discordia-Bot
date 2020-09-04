local Discordia = require("discordia")
local Fs = require("fs")
local Json = require("json")
local PrettyPrint = require("pretty-print")

local Configuration = require("./Configuration.lua")
local Utilites = require("./Modules/Utilites.lua")

local Client = Discordia.Client()
Discordia.extensions()

local FS = {
    Writefile = Fs.writeFileSync,
    Readfile = Fs.readFileSync,
    UnlinkFile = Fs.unlink,
    RenameFile = Fs.rename,
    FileExists = Fs.existsSync
}

local Environment = {
    Discordia = Discordia,
    Client = Client,
    Configuration = Configuration,
    Utilites = Utilites,
    FS = FS,
    Json = Json,
    PrettyPrint = PrettyPrint
}

for i, v in pairs(Environment) do
    _G[i] = v
end

function CommandExists(command)
    local CommandName = command:gsub("^%l", string.upper)

    if FS.FileExists("./Commands/" .. CommandName .. ".lua") then
        return true
    else
        return false
    end
end

function LoadCommand(command)
    local CommandName = command:gsub("^%l", string.upper)
    local Environment = setmetatable({}, {__index = _G})

    assert(pcall(setfenv(assert(loadfile("./Commands/" .. CommandName .. ".lua")), Environment)))
    setmetatable(Environment, nil)
    
    return Environment
end

Client:on("messageCreate", function(message)
    pcall(function()
        local Arguments = message.content:split(" ")

        if Arguments[1]:find(Configuration.Prefix) then
            local Command = Arguments[1]:gsub(Configuration.Prefix, "")

            if CommandExists(Command) then
                table.remove(Arguments, 1)

                _G.Message = message
                _G.Arguments = Arguments
                LoadCommand(Command)
            end
        end
    end)
end)

Client:run(Configuration.Token)
