local Discordia = require("discordia")
local FS = require("fs")

local Configuration = require("./Configuration.lua")

local Client = Discordia.Client()
Discordia.extensions()

--// Clean & easy environment injection.
local Environment = {
    Discordia = Discordia
    Client = Client
}

for i, v in pairs(Environment) do
    _G[i] = v
end

local Writefile = FS.writeFileSync
local Readfile = FS.readFileSync
local UnlinkFile = FS.unlink
local RenameFile = FS.rename
local FileExists = FS.existsSync

local function CommandExists(command)
    if FileExists("./Modules/Commands/" .. command .. ".lua") then
        return true
    else
        return false
    end
end

local function LoadCommand(command)
    local Environment = setmetatable({}, {__index = _G})
    assert(pcall(setfenv(assert(loadfile("./Modules/Commands/" .. command .. ".lua")), Environment)))
    setmetatable(Environment, nil)
    
    return Environment
end

--// Runs the command from the command's file.
Client:on("messageCreate", function(message)
    local Arguments = message.content:split(" ")

    if Arguments[1]:find(Configuration.Prefix) then
        local Command = Arguments[1]:gsub("!", "")

        if CommandExists(Command) then
            pcall(function()
                table.remove(Arguments, 1)

                _G.Message = message
                _G.Arguments = Arguments
                LoadCommand(Command)
            end)
        end
    end
end)

Client:run(Configuration.Token)
