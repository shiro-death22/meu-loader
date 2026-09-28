local HttpService = game:GetService("HttpService")

local Rayfield = loadstring(
    game:HttpGet("https://sirius.menu/rayfield")
)()

local Window = Rayfield:CreateWindow({
    Name = "Meu Hub - Key System",
    LoadingTitle = "Meu Hub",
    LoadingSubtitle = "Validação de Key",
    ConfigurationSaving = {
        Enabled = false
    }
})

local Tab = Window:CreateTab("Key", 4483362458)

local UserKey = ""

Tab:CreateInput({
    Name = "Key",
    CurrentValue = "",
    PlaceholderText = "Digite sua key",
    RemoveTextAfterFocusLost = false,
    Flag = "UserKey",

    Callback = function(Text)
        UserKey = Text
    end
})

Tab:CreateButton({
    Name = "Validar Key",

    Callback = function()

        if UserKey == "" then
            Rayfield:Notify({
                Title = "Erro",
                Content = "Digite uma key.",
                Duration = 4
            })
            return
        end

        local ValidateURL =
            "https://meu-loader.onrender.com/validate?key="
            .. HttpService:UrlEncode(UserKey)

        local Success, Response = pcall(function()
            return game:HttpGet(ValidateURL)
        end)

        if not Success then
            Rayfield:Notify({
                Title = "Erro",
                Content = "Falha ao conectar à API.",
                Duration = 4
            })
            return
        end

        local Data

        local DecodeSuccess = pcall(function()
            Data = HttpService:JSONDecode(Response)
        end)

        if not DecodeSuccess or not Data then
            Rayfield:Notify({
                Title = "Erro",
                Content = "Resposta inválida da API.",
                Duration = 4
            })
            return
        end

        if not Data.valid then
            Rayfield:Notify({
                Title = "Key inválida",
                Content = Data.message or "A key foi recusada.",
                Duration = 4
            })
            return
        end

        local ScriptURL =
            "https://meu-loader.onrender.com/script?token="
            .. HttpService:UrlEncode(Data.token)

        local ScriptSuccess, Script = pcall(function()
            return game:HttpGet(ScriptURL)
        end)

        if not ScriptSuccess then
            Rayfield:Notify({
                Title = "Erro",
                Content = "Falha ao carregar o hub.",
                Duration = 4
            })
            return
        end

        local ExecuteSuccess, ErrorMessage = pcall(function()
            loadstring(Script)()
        end)

        if not ExecuteSuccess then
            Rayfield:Notify({
                Title = "Erro",
                Content = "Erro ao executar o hub.",
                Duration = 5
            })

            warn(ErrorMessage)
            return
        end

        Rayfield:Notify({
            Title = "Sucesso",
            Content = "Key validada!",
            Duration = 4
        })
    end
})