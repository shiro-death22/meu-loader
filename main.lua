local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Meu Hub",
    LoadingTitle = "Meu Hub",
    LoadingSubtitle = "Carregando..."
})

local Tab = Window:CreateTab("Principal")
local Section = Tab:CreateSection("AimBot aura")

Tab:CreateToggle({
    Name = "Aim Bot",
    CurrentValue = false,
    Flag = "AimBot",
    Callback = function(Value)
        print("AimBot:", Value)
    end
})