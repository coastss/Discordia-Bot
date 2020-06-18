--[[
    Todo List:
    - getscript
    - whitelist
    - blacklist
    - transferdata
    - wipedata
    - getrole
    - postupdate
    - sayembed
    - say
    - eval
    - ban
    - kick
    - clear
]]

local Discordia = require("discordia")
local FS = require("fs")
local Json = require("json")
local Http = require("coro-http")

local Configuration = require("./Configuration.lua")
local Base64 = require("./Modules/Base64.lua")
local Database = require("./Modules/Database.lua")
local ShaHashing = require("./Modules/ShaHashing.lua")
local Utilites = require("./Modules/Utilities.lua")

local Client = Discordia.Client()
Discordia.extensions()

_G.Discordia = Discordia
_G.Client = Client

local Writefile = FS.writeFileSync
local Readfile = FS.readFileSync
local UnlinkFile = FS.unlink
local RenameFile = FS.rename
local FileExists = FS.existsSync

require("./libs/weblit-app.lua")
    .bind({
        host = "0.0.0.0",
        port = 444
    })

    .use(require("./libs/weblit-auto-headers.lua"))

    .route({method = "GET", path = "/getfile", domain = ""}, function(req, res, go)
        if not Database.IsUserInDatabase(Base64.Decode(req.query.id)) or req.query.exploit == (nil or "") then 
            res.code = 200
            res.headers = {}
            res.body = ""

            return go()
        end

        local ScriptId = req.query.id
        local Exploit = req.query.exploit

        if Database.IsUserInDatabase(Base64.Decode(ScriptId)) and Exploit == "SynapseX" or Exploit == "ProtoSmasher" then
            local Content = [==[
                local QueueForTeleport = queue_for_teleport or syn.queue_on_teleport
                local GetRegistry = getregistry or debug.getregistry

                local AuthKey = shared.AuthKey
                
                GetRegistry().AuthKey = AuthKey
                GetRegistry().ScriptId = "%s"

                QueueForTeleport([[
                    shared.AuthKey = AuthKey
                    local Exploit = (syn and "SynapseX") or (getwally and "ProtoSmasher")
                    loadstring(game:HttpGet("http://coasts.cool:444/getfile?id=" .. GetRegistry().ScriptId .. "&exploit=" .. Exploit))()
                ]])
            ]==]

            local ScriptContent = Content:format(ScriptId):gsub("    ", "")

            res.code = 200
            res.headers = {}
            res.body = (ScriptContent .. "\n" .. module:load("./CoastingScript/" .. Exploit .. ".lua"))

            return go()
        end
    end)

    .route({method = "GET", path = "/whitelist", domain = ""}, function(req, res, go)
        if not Database.IsUserInDatabase(Base64.Decode(req.query.scriptid)) or req.query.key == (nil or "") or req.query.hwid == (nil or "") or req.query.clientdata == (nil or "") then 
            res.code = 200
            res.headers = {}
            res.body = "Data is missing, please report this in #bug-reports"

            return go()
        end

        local SentClientKey = "EhCFil!OM5AxptOi7J5w@jn1l&MHM1K#5T5B&zP6srVRh7FdR$$64GpZv8MT8MYjKDbGa%wMlrS4&Tg#LKjv$0WhwPiQKMkux3wR"
        local ToSendServerKey = "R90ozKAb3dKwcyL26ll59gHsxtGn!w6ESpC@@cZvB@Ad0M*$QU6wSPvRmA88j7$GBPI#vXZyzAt14hShv3pM51j^NGPE6pEtws4s"
        local ClientKeySplit = Utilites.SplitString(SentClientKey, 50)
        local ServerKeySplit = Utilites.SplitString(ToSendServerKey, 50)

        local ScriptId = req.query.scriptid
        local Key = req.query.key
        local HWID = req.query.hwid
        local UserIP = req.query.ip
        local ClientData = req.query.clientdata
        local ServerData = ShaHashing.GamerSha(ClientKeySplit[1], ScriptId .. Key .. HWID .. ClientKeySplit[2])

        local function SendLoginLog()
            local WebhookUrl = "https://discordapp.com/api/webhooks/717582966821224448/ixTPTDN3o8GQmB6dtDZVSm4trk1k5D27Anx0phAEyRfXsJRtX2PSLVXWAB1CAFe6Oeg0"
            local Headers = {
                {"content-type", "application/json"}
            }
            local WebhookEmbed = {
                title = "Coasting Logins",
                fields = {
                    {
                        name = "User:",
                        value = Utilites.Constants.MentionUser:format(Base64.Decode(ScriptId))
                    },
                    {
                        name = "Key:",
                        value = Key
                    },
                    {
                        name = "HWID:",
                        value = HWID
                    },
                    {
                        name = "Script Id:",
                        value = ScriptId
                    },
                    {
                        name = "IP:",
                        value = UserIP
                    }
                },
                footer = {
                    text = "coasting logins"
                },
                color = Configuration.Colors.EpicalRed,
                timestamp = Discordia.Date():toISO("T", "Z")
            }
    
            coroutine.wrap(function()
                local Response, Body = Http.request("POST", WebhookUrl, Headers, Json.encode({embeds = {WebhookEmbed}}))
                print(Response)
                print(Body)
            end)()
        end

        local function SendFailedLoginLog(reason)
            local WebhookUrl = "https://discordapp.com/api/webhooks/718894527435243551/jTGru8xLNmok8kn-azwtxvRb2-LE8JGmnX-riSTsJ8IAteOZ9dQkZbgcM5MyvCf7G8oh"
            local Headers = {
                {"content-type", "application/json"}
            }
            local WebhookEmbed = {
                title = "Coasting Failed Logins",
                fields = {
                    {
                        name = "User:",
                        value = Utilites.Constants.MentionUser:format(Base64.Decode(ScriptId))
                    },
                    {
                        name = "Reason:",
                        value = reason
                    },
                    {
                        name = "Key:",
                        value = Key
                    },
                    {
                        name = "HWID:",
                        value = HWID
                    },
                    {
                        name = "Script Id:",
                        value = ScriptId
                    },
                    {
                        name = "IP:",
                        value = UserIP
                    }
                },
                footer = {
                    text = "coasting failed logins"
                },
                color = Configuration.Colors.EpicalRed,
                timestamp = Discordia.Date():toISO("T", "Z")
            }
    
            coroutine.wrap(function()
                local Response, Body = Http.request("POST", WebhookUrl, Headers, Json.encode({embeds = {WebhookEmbed}}))
                print(Response)
                print(Body)
            end)()
        end

        if Database.IsUserInDatabase(Base64.Decode(ScriptId)) then
            local UserScriptId = Database.GetUserDataElement(Base64.Decode(ScriptId), "ScriptId")
            local UserKey = Database.GetUserDataElement(Base64.Decode(ScriptId), "Key")
            local UserHWID = Database.GetUserDataElement(Base64.Decode(ScriptId), "HWID")

            if ScriptId == UserScriptId and Key == UserKey and HWID == UserHWID and ClientData == ServerData then
                res.code = 200
                res.headers = {}
                res.body = ShaHashing.GamerSha(ServerKeySplit[1], ScriptId .. Key .. HWID .. ServerKeySplit[2])
                SendLoginLog("has successfully logged in.")

                return go()
            elseif ScriptId ~= UserScriptId then
                res.code = 200
                res.headers = {}
                res.body = "User Mismatch"
                SendFailedLoginLog("User Mismatch")

                return go()
            elseif Key ~= UserKey then
                res.code = 200
                res.headers = {}
                res.body = "Invalid Key"
                SendFailedLoginLog("Invalid Key")

                return go()
            elseif HWID ~= UserHWID then
                res.code = 200
                res.headers = {}
                res.body = "HWID Mismatch"
                SendFailedLoginLog("HWID Mismatch")
    
                return go()
            elseif ClientData ~= ServerData then
                res.code = 200
                res.headers = {}
                res.body = "Data Mismatch"
                SendFailedLoginLog("Data Mismatch")

                return go()
            end
        end
    end)
.start()

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