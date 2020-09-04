local Discordia = _G.Discordia
local Client = _G.Client
local Message = _G.Message
local Arguments = _G.Arguments

local Configuration = _G.Configuration
local Utilites = _G.Utilites
local FS = _G.FS

local AuthorId = Message.author.id
local Guild = Client:getGuild(Configuration.ServerId)
local IsDirectMessages = (Message.channel.type == 1 and true or false)
--// Initialize every new command with the stuff above this comment, you can insert more things from the enviroment table in the main file then insert them by doing. local NewVariable = _G.NewVariable.

return Message:reply(Utilites.CreateEmbed("Games", {
        "No I like:",
        "Minecraft.",
        "Header",
        "Description, and so on!"
}, Configuration.Colors.Red))
