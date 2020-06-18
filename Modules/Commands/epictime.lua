local Message = _G.Message
local Arguments = _G.Arguments

local EpicTime = table.concat(Arguments, " ")

return(Message:reply("this 😎 dude said " .. EpicTime))
