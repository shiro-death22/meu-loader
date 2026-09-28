local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "AuraHub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Carregando a aura do Renan",
   LoadingSubtitle = "por shiro",
   ShowText = "Aurahub", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "Default", -- Check https://[Log in to view URL]

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   -- ScriptID = "sid_xxxxxxxxxxxx", -- Your Script ID from developer.sirius.menu — enables analytics, managed keys, and script hosting

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include Discord.gg/. E.g. Discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the Discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Coloque a chave!",
      Subtitle = "sistema de chave",
      Note = "Converse com o Renan para pegar a chave do script", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique, as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Vinifilhadaputa"} -- List of keys that the system will accept, can be RAW file links (pastebin, github, etc.) or simple strings ("hello", "key22")
   }
})

local Tab = Window:CreateTab("original", 4483362458) -- Title, Image

local JumpConnection

local Toggle = Tab:CreateToggle({
    Name = "pulo infinito",
    CurrentValue = false,
    Flag = "Toggle1",

    Callback = function(Value)
        if JumpConnection then
            JumpConnection:Disconnect()
            JumpConnection = nil
        end

        if Value then
            local UserInputService = game:GetService("UserInputService")
            local Players = game:GetService("Players")
            local Player = Players.LocalPlayer

            JumpConnection = UserInputService.JumpRequest:Connect(function()
                local Character = Player.Character
                if not Character then return end

                local Humanoid = Character:FindFirstChildOfClass("Humanoid")

                if Humanoid then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end,
})

local Divider = Tab:CreateDivider()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FOV_RADIUS = 180
local TargetPart = "Head"

local AimbotConnection
local InputBeganConnection
local InputEndedConnection

local Aiming = false
local Target = nil

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = FOV_RADIUS
FOVCircle.NumSides = 100
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1

local function GetMousePosition()
    return UserInputService:GetMouseLocation()
end

local function IsAlive(Player)
    if Player == LocalPlayer or not Player.Character then
        return false
    end

    local Character = Player.Character
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Part = Character:FindFirstChild(TargetPart)

    return Humanoid and Humanoid.Health > 0 and Part
end

local function GetClosestTarget()
    local MousePosition = GetMousePosition()
    local Closest = nil
    local ClosestDistance = FOV_RADIUS

    for _, Player in ipairs(Players:GetPlayers()) do
        if IsAlive(Player) then
            local Part = Player.Character[TargetPart]

            local ScreenPosition, Visible =
                Camera:WorldToViewportPoint(Part.Position)

            if Visible and ScreenPosition.Z > 0 then
                local Distance = (
                    Vector2.new(ScreenPosition.X, ScreenPosition.Y)
                    - MousePosition
                ).Magnitude

                if Distance <= ClosestDistance then
                    ClosestDistance = Distance
                    Closest = Part
                end
            end
        end
    end

    return Closest
end

local Section = Tab:CreateSection("AimBot aura") -- aimbot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FOV_RADIUS = 180
local TargetPart = "Head"

local InputBeganConnection
local InputEndedConnection

local Aiming = false
local TargetPlayer = nil
local TargetPartInstance = nil

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = FOV_RADIUS
FOVCircle.NumSides = 100
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1

local function GetMousePosition()
    return UserInputService:GetMouseLocation()
end

local function GetTargetPart(Character)
    if not Character then
        return nil
    end

    if TargetPart == "Head" then
        return Character:FindFirstChild("Head")
    end

    return Character:FindFirstChild("UpperTorso")
        or Character:FindFirstChild("Torso")
end

local function IsAlive(Player)
    if not Player or Player == LocalPlayer then
        return false
    end

    local Character = Player.Character
    if not Character then
        return false
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Part = GetTargetPart(Character)

    if not Humanoid or Humanoid.Health <= 0 or not Part then
        return false
    end

    return true
end

local function GetClosestTarget()
    local MousePosition = GetMousePosition()

    local ClosestPlayer = nil
    local ClosestPart = nil
    local ClosestDistance = FOV_RADIUS

    for _, Player in ipairs(Players:GetPlayers()) do
        if IsAlive(Player) then
            local Character = Player.Character
            local Part = GetTargetPart(Character)

            if Part then
                local ScreenPosition, Visible =
                    Camera:WorldToViewportPoint(Part.Position)

                if Visible and ScreenPosition.Z > 0 then
                    local Distance = (
                        Vector2.new(ScreenPosition.X, ScreenPosition.Y)
                        - MousePosition
                    ).Magnitude

                    if Distance <= ClosestDistance then
                        ClosestDistance = Distance
                        ClosestPlayer = Player
                        ClosestPart = Part
                    end
                end
            end
        end
    end

    return ClosestPlayer, ClosestPart
end

local Section = Tab:CreateSection("AimBot aura")

local Slider = Tab:CreateSlider({
    Name = "FOV",
    Range = {50, 500},
    Increment = 10,
    Suffix = " FOV",
    CurrentValue = FOV_RADIUS,
    Flag = "AimbotFOV",

    Callback = function(Value)
        FOV_RADIUS = Value
        FOVCircle.Radius = Value
    end,
})

local Dropdown = Tab:CreateDropdown({
    Name = "Parte da mira",
    Options = {"Cabeça", "Tronco"},
    CurrentOption = {"Cabeça"},
    MultipleOptions = false,
    Flag = "AimbotTargetPart",

    Callback = function(Options)
        local Selected = Options[1]

        if Selected == "Cabeça" then
            TargetPart = "Head"
        elseif Selected == "Tronco" then
            TargetPart = "UpperTorso"
        end

        -- Atualiza a parte do alvo atual imediatamente
        if TargetPlayer and IsAlive(TargetPlayer) then
            TargetPartInstance = GetTargetPart(TargetPlayer.Character)
        end
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Aim bot",
    CurrentValue = false,
    Flag = "Toggle2",

    Callback = function(Value)

        if InputBeganConnection then
            InputBeganConnection:Disconnect()
            InputBeganConnection = nil
        end

        if InputEndedConnection then
            InputEndedConnection:Disconnect()
            InputEndedConnection = nil
        end

        RunService:UnbindFromRenderStep("AimbotCamera")

        Aiming = false
        TargetPlayer = nil
        TargetPartInstance = nil

        FOVCircle.Visible = Value

        if not Value then
            return
        end

        InputBeganConnection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
            if GameProcessed then
                return
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton2 then
                Aiming = true

                TargetPlayer, TargetPartInstance = GetClosestTarget()
            end
        end)

        InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton2 then
                Aiming = false
                TargetPlayer = nil
                TargetPartInstance = nil
            end
        end)

        RunService:BindToRenderStep(
            "AimbotCamera",
            Enum.RenderPriority.Camera.Value + 1,

            function()
                FOVCircle.Position = GetMousePosition()

                if not Aiming then
                    return
                end

                if not IsAlive(TargetPlayer) then
                    Aiming = false
                    TargetPlayer = nil
                    TargetPartInstance = nil
                    return
                end

                TargetPartInstance = GetTargetPart(TargetPlayer.Character)

                if not TargetPartInstance then
                    Aiming = false
                    TargetPlayer = nil
                    TargetPartInstance = nil
                    return
                end

                Camera.CFrame = CFrame.lookAt(
                    Camera.CFrame.Position,
                    TargetPartInstance.Position
                )
            end
        )
    end,
})

local Divider = Tab:CreateDivider() -- esp

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local ESPObjects = {}
local ESPConnections = {}
local DistanceConnection

local function AddESP(Player)
    if Player == LocalPlayer then
        return
    end

    local function Apply(Character)
        if not Character then return end

        if ESPObjects[Player] then
            ESPObjects[Player]:Destroy()
            ESPObjects[Player] = nil
        end

        local Highlight = Instance.new("Highlight")
        Highlight.Name = "EnemyESP"
        Highlight.Adornee = Character
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.FillColor = Color3.fromRGB(255, 0, 0)
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.Parent = Character

        local Head = Character:FindFirstChild("Head")
            or Character:FindFirstChild("UpperTorso")
            or Character:FindFirstChild("Torso")

        if Head then
            local Billboard = Instance.new("BillboardGui")
            Billboard.Name = "DistanceESP"
            Billboard.Adornee = Head
            Billboard.Size = UDim2.fromOffset(120, 35)
            Billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            Billboard.AlwaysOnTop = true
            Billboard.Parent = Head

            local DistanceLabel = Instance.new("TextLabel")
            DistanceLabel.Name = "Distance"
            DistanceLabel.BackgroundTransparency = 1
            DistanceLabel.Size = UDim2.fromScale(1, 1)
            DistanceLabel.Font = Enum.Font.SourceSansBold
            DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            DistanceLabel.TextStrokeTransparency = 0
            DistanceLabel.TextScaled = true
            DistanceLabel.Text = "0 studs"
            DistanceLabel.Parent = Billboard

            ESPObjects[Player] = Highlight

            -- Guardamos os dois para remover depois
            Highlight:SetAttribute("HasDistance", true)
            Billboard.Parent = Head
        else
            ESPObjects[Player] = Highlight
        end
    end

    if Player.Character then
        Apply(Player.Character)
    end

    ESPConnections[Player] = Player.CharacterAdded:Connect(Apply)
end

local Toggle = Tab:CreateToggle({
    Name = "Esp",
    CurrentValue = false,
    Flag = "Toggle3",

    Callback = function(Value)

        if DistanceConnection then
            DistanceConnection:Disconnect()
            DistanceConnection = nil
        end

        if Value then

            for _, Player in ipairs(Players:GetPlayers()) do
                AddESP(Player)
            end

            DistanceConnection = RunService.RenderStepped:Connect(function()
                local MyCharacter = LocalPlayer.Character
                local MyRoot = MyCharacter and MyCharacter:FindFirstChild("HumanoidRootPart")

                if not MyRoot then
                    return
                end

                for Player, Highlight in pairs(ESPObjects) do
                    if Player.Character and Highlight then
                        local Character = Player.Character
                        local Root = Character:FindFirstChild("HumanoidRootPart")
                        local Head = Character:FindFirstChild("Head")
                            or Character:FindFirstChild("UpperTorso")
                            or Character:FindFirstChild("Torso")

                        if Root and Head then
                            local Distance = (MyRoot.Position - Root.Position).Magnitude

                            local Billboard = Head:FindFirstChild("DistanceESP")

                            if Billboard then
                                local Label = Billboard:FindFirstChild("Distance")

                                if Label then
                                    Label.Text = string.format("%d studs", math.floor(Distance))
                                end
                            end
                        end
                    end
                end
            end)

        else

            for Player, Highlight in pairs(ESPObjects) do
                if Highlight then
                    Highlight:Destroy()
                end

                if Player.Character then
                    local Head = Player.Character:FindFirstChild("Head")
                        or Player.Character:FindFirstChild("UpperTorso")
                        or Player.Character:FindFirstChild("Torso")

                    if Head then
                        local Billboard = Head:FindFirstChild("DistanceESP")

                        if Billboard then
                            Billboard:Destroy()
                        end
                    end
                end

                ESPObjects[Player] = nil
            end

            for Player, Connection in pairs(ESPConnections) do
                Connection:Disconnect()
                ESPConnections[Player] = nil
            end
        end
    end,
})

