local Discordia = _G.Discordia
Discordia.extensions()

function CreateEmbed(title, data, color)
    local Embed = {}
    local Fields = {}
    
    for i = 1, #data, 2 do
        local Field = data[i]
        local Text = data[i + 1]
        table.insert(Fields, {
            name = Field,
            value = Text,
            inline = false
        })
    end
    
    Embed.title = title
    Embed.fields = Fields
    Embed.footer = {text = "coasting bot"}
    Embed.timestamp = Discordia.Date():toISO("T", "Z")
    Embed.color = color

    return {embed = Embed}
end


return{
    CreateEmbed = CreateEmbed
}
