# Gamer-Discordia-Bot
A discord bot written in lua discordia.
Clean and simple to use and create new commands.

To create a new command enter the modules directory, then to the commands directory, and create a lua file corresponding to the new command's name, filenames are case sensitive. Initialize each new command with these variables.
```lua
--// Optional: local Discordia = _G.Discordia
local Client = _G.Client
local Message = _G.Message
local Arguments = _G.Arguments

--// To respond with a message simply return it.
return(Message:reply("Hello! How are you doing <@" .. Message.author.id .. ">?"))
```
