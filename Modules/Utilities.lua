local Discordia = _G.Discordia
Discordia.extensions()

local function Embed(title, fields, color)
    return{
        embed = {
            title = title,
            fields = fields,
            footer = {
                text = "lua discordia bot"
            },
            color = color,
            timestamp = Discordia.Date():toISO("T", "Z")
        }
    }
end


return{
    Embed = Embed
}  
