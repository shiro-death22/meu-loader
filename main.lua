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

   KeySystem = false, -- Set this to true to use our key system
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

local Section = Tab:CreateSection("movimentacao") -- movimentacao

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

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local WalkSpeed = 16
local SpeedEnabled = false

local function ApplySpeed()
    local Character = LocalPlayer.Character
    if not Character then
        return
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then
        return
    end

    if SpeedEnabled then
        Humanoid.WalkSpeed = WalkSpeed
    else
        Humanoid.WalkSpeed = 16
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.2)
    ApplySpeed()
end)

local Section = Tab:CreateSection("Movement")

local Slider = Tab:CreateSlider({
    Name = "Velocidade",
    Range = {16, 200},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = WalkSpeed,
    Flag = "WalkSpeedValue",

    Callback = function(Value)
        WalkSpeed = Value

        if SpeedEnabled then
            ApplySpeed()
        end
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Speed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",

    Callback = function(Value)
        SpeedEnabled = Value
        ApplySpeed()
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

-- Proteções contra corpos/ragdolls fora do mapa
local MAX_TARGET_DISTANCE = 500
local MAX_VERTICAL_DISTANCE = 250

-- false = pode mirar através de paredes
local REQUIRE_LINE_OF_SIGHT = false

local AimbotEnabled = false
local Aiming = false

local MouseAiming = false
local KeyboardAiming = false

local TargetPlayer = nil
local TargetPartInstance = nil
local TargetHumanoid = nil
local TargetDiedConnection = nil

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

local function UpdateAimingState()
    Aiming = MouseAiming or KeyboardAiming
end

local function DisconnectTargetDeath()
    if TargetDiedConnection then
        TargetDiedConnection:Disconnect()
        TargetDiedConnection = nil
    end
end

local function ClearTarget()
    DisconnectTargetDeath()

    TargetPlayer = nil
    TargetPartInstance = nil
    TargetHumanoid = nil
end

local function StopAiming()
    Aiming = false
    ClearTarget()
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
        or Character:FindFirstChild("HumanoidRootPart")
end

local function HasDeathMarker(Character, Humanoid)
    if Character:GetAttribute("Dead") == true
        or Character:GetAttribute("IsDead") == true
        or Character:GetAttribute("Died") == true then
        return true
    end

    if Humanoid:GetAttribute("Dead") == true
        or Humanoid:GetAttribute("IsDead") == true then
        return true
    end

    if Character:FindFirstChild("Dead")
        or Character:FindFirstChild("Ragdoll") then
        return true
    end

    return false
end

local function IsTargetPositionValid(Character, Part)
    local MyCharacter = LocalPlayer.Character

    if not MyCharacter then
        return false
    end

    local MyRoot = MyCharacter:FindFirstChild("HumanoidRootPart")

    if not MyRoot or not Part then
        return false
    end

    local Difference = Part.Position - MyRoot.Position

    if Difference.Magnitude > MAX_TARGET_DISTANCE then
        return false
    end

    if math.abs(Difference.Y) > MAX_VERTICAL_DISTANCE then
        return false
    end

    local TargetY = Part.Position.Y
    local MyY = MyRoot.Position.Y

    if TargetY < MyY - MAX_VERTICAL_DISTANCE then
        return false
    end

    return true
end

local function HasLineOfSight(Character, Part)
    if not REQUIRE_LINE_OF_SIGHT then
        return true
    end

    if not Part then
        return false
    end

    local Origin = Camera.CFrame.Position
    local Direction = Part.Position - Origin

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        Character
    }
    Params.IgnoreWater = true

    local Result = workspace:Raycast(
        Origin,
        Direction,
        Params
    )

    if not Result then
        return true
    end

    return Result.Instance:IsDescendantOf(Character)
end

local function IsAlive(Player)
    if not Player or Player == LocalPlayer then
        return false
    end

    local Character = Player.Character

    if not Character then
        return false
    end

    if Character.Parent ~= workspace then
        return false
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Part = GetTargetPart(Character)

    if not Humanoid or not Part then
        return false
    end

    if Humanoid.Health <= 0 then
        return false
    end

    if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
        return false
    end

    if HasDeathMarker(Character, Humanoid) then
        return false
    end

    if not IsTargetPositionValid(Character, Part) then
        return false
    end

    if not HasLineOfSight(Character, Part) then
        return false
    end

    return true
end

local function SetTarget(Player, Part)
    ClearTarget()

    if not Player or not Part then
        return
    end

    if not IsAlive(Player) then
        return
    end

    TargetPlayer = Player
    TargetPartInstance = Part

    if Player.Character then
        TargetHumanoid =
            Player.Character:FindFirstChildOfClass("Humanoid")
    end

    if TargetHumanoid then
        TargetDiedConnection = TargetHumanoid.Died:Connect(function()
            StopAiming()
        end)
    end
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

        if TargetPlayer and IsAlive(TargetPlayer) then
            TargetPartInstance =
                GetTargetPart(TargetPlayer.Character)
        else
            ClearTarget()
        end
    end,
})

local Keybind = Tab:CreateKeybind({
    Name = "Tecla do Aim Bot",
    CurrentKeybind = "Q",
    HoldToInteract = true,
    Flag = "AimbotKey",

    Callback = function(Value)
        if not AimbotEnabled then
            KeyboardAiming = false
            MouseAiming = false
            StopAiming()
            return
        end

        KeyboardAiming = Value
        UpdateAimingState()

        if Value then
            local Player, Part = GetClosestTarget()

            if Player and Part then
                SetTarget(Player, Part)
            else
                ClearTarget()
            end
        elseif not MouseAiming then
            StopAiming()
        end
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Aim bot",
    CurrentValue = false,
    Flag = "Toggle2",

    Callback = function(Value)
        AimbotEnabled = Value

        if not Value then
            MouseAiming = false
            KeyboardAiming = false
            StopAiming()
        end

        FOVCircle.Visible = Value
    end,
})

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed or not AimbotEnabled then
        return
    end

    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        MouseAiming = true
        UpdateAimingState()

        local Player, Part = GetClosestTarget()

        if Player and Part then
            SetTarget(Player, Part)
        else
            ClearTarget()
        end
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        MouseAiming = false
        UpdateAimingState()

        if not KeyboardAiming then
            StopAiming()
        end
    end
end)

RunService:BindToRenderStep(
    "AimbotCamera",
    Enum.RenderPriority.Camera.Value + 1,

    function()
        FOVCircle.Position = GetMousePosition()

        if not AimbotEnabled or not Aiming then
            return
        end

        if not IsAlive(TargetPlayer) then
            StopAiming()
            return
        end

        local Character = TargetPlayer.Character

        if not Character then
            StopAiming()
            return
        end

        TargetPartInstance = GetTargetPart(Character)

        if not TargetPartInstance then
            StopAiming()
            return
        end

        TargetHumanoid =
            Character:FindFirstChildOfClass("Humanoid")

        if not TargetHumanoid then
            StopAiming()
            return
        end

        if TargetHumanoid.Health <= 0
            or TargetHumanoid:GetState() == Enum.HumanoidStateType.Dead
            or HasDeathMarker(Character, TargetHumanoid)
            or not IsTargetPositionValid(Character, TargetPartInstance) then

            StopAiming()
            return
        end

        Camera.CFrame = CFrame.lookAt(
            Camera.CFrame.Position,
            TargetPartInstance.Position
        )
    end
)

local Divider = Tab:CreateDivider() -- esp

local Section = Tab:CreateSection("Esp")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local ESPEnabled = false
local ShowName = true
local ShowDistance = true

local ESPObjects = {}
local ESPConnections = {}
local DistanceConnection

local function GetBodyPart(Character)
    return Character:FindFirstChild("Head")
        or Character:FindFirstChild("UpperTorso")
        or Character:FindFirstChild("Torso")
end

local function RemoveESP(Player)
    if ESPObjects[Player] then
        local Data = ESPObjects[Player]

        if Data.Highlight then
            Data.Highlight:Destroy()
        end

        if Data.Billboard then
            Data.Billboard:Destroy()
        end

        ESPObjects[Player] = nil
    end

    if ESPConnections[Player] then
        ESPConnections[Player]:Disconnect()
        ESPConnections[Player] = nil
    end
end

local function AddESP(Player)
    if Player == LocalPlayer then
        return
    end

    if not ESPEnabled then
        return
    end

    local function Apply(Character)
        if not Character or not ESPEnabled then
            return
        end

        RemoveESP(Player)

        -- Highlight
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "EnemyESP"
        Highlight.Adornee = Character
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.FillColor = Color3.fromRGB(255, 0, 0)
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.Parent = Character

        -- Parte onde o texto ficará
        local BodyPart = GetBodyPart(Character)

        local Billboard
        local NameLabel
        local DistanceLabel

        if BodyPart then
            Billboard = Instance.new("BillboardGui")
            Billboard.Name = "ESPInfo"
            Billboard.Adornee = BodyPart
            Billboard.Size = UDim2.fromOffset(180, 50)
            Billboard.StudsOffset = Vector3.new(0, 3, 0)
            Billboard.AlwaysOnTop = true
            Billboard.Parent = BodyPart

            -- Nome
            NameLabel = Instance.new("TextLabel")
            NameLabel.Name = "PlayerName"
            NameLabel.BackgroundTransparency = 1
            NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            NameLabel.Position = UDim2.fromScale(0, 0)
            NameLabel.Font = Enum.Font.SourceSansBold
            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLabel.TextStrokeTransparency = 0
            NameLabel.TextScaled = true
            NameLabel.Text = Player.Name
            NameLabel.Visible = ShowName
            NameLabel.Parent = Billboard

            -- Distância
            DistanceLabel = Instance.new("TextLabel")
            DistanceLabel.Name = "Distance"
            DistanceLabel.BackgroundTransparency = 1
            DistanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
            DistanceLabel.Position = UDim2.fromScale(0, 0.5)
            DistanceLabel.Font = Enum.Font.SourceSansBold
            DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            DistanceLabel.TextStrokeTransparency = 0
            DistanceLabel.TextScaled = true
            DistanceLabel.Text = "0 studs"
            DistanceLabel.Visible = ShowDistance
            DistanceLabel.Parent = Billboard
        end

        ESPObjects[Player] = {
            Highlight = Highlight,
            Billboard = Billboard,
            NameLabel = NameLabel,
            DistanceLabel = DistanceLabel
        }
    end

    if Player.Character then
        Apply(Player.Character)
    end

    ESPConnections[Player] = Player.CharacterAdded:Connect(function(Character)
        task.wait(0.1)

        if ESPEnabled then
            Apply(Character)
        end
    end)
end

-- ========================================
-- ESP
-- ========================================

local Toggle = Tab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "Toggle3",

    Callback = function(Value)
        ESPEnabled = Value

        if DistanceConnection then
            DistanceConnection:Disconnect()
            DistanceConnection = nil
        end

        if Value then
            -- Adiciona ESP em todos os jogadores existentes
            for _, Player in ipairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer then
                    AddESP(Player)
                end
            end

            -- Atualiza distância
            DistanceConnection = RunService.RenderStepped:Connect(function()
                if not ESPEnabled then
                    return
                end

                local MyCharacter = LocalPlayer.Character
                local MyRoot = MyCharacter
                    and MyCharacter:FindFirstChild("HumanoidRootPart")

                if not MyRoot then
                    return
                end

                for Player, Data in pairs(ESPObjects) do
                    if Player.Character and Data then
                        local Character = Player.Character

                        local Root =
                            Character:FindFirstChild("HumanoidRootPart")

                        local BodyPart =
                            GetBodyPart(Character)

                        if Root and BodyPart then
                            local Distance =
                                (MyRoot.Position - Root.Position).Magnitude

                            if Data.DistanceLabel then
                                Data.DistanceLabel.Text =
                                    string.format(
                                        "%d studs",
                                        math.floor(Distance)
                                    )

                                Data.DistanceLabel.Visible =
                                    ShowDistance
                            end

                            if Data.NameLabel then
                                Data.NameLabel.Visible =
                                    ShowName
                            end
                        end
                    end
                end
            end)

        else
            -- Remove todos os ESPs
            for _, Player in ipairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer then
                    RemoveESP(Player)
                end
            end
        end
    end,
})

-- ========================================
-- MOSTRAR NOME
-- ========================================

local NameToggle = Tab:CreateToggle({
    Name = "Mostrar nome",
    CurrentValue = true,
    Flag = "ESPShowName",

    Callback = function(Value)
        ShowName = Value

        for _, Data in pairs(ESPObjects) do
            if Data.NameLabel then
                Data.NameLabel.Visible = Value
            end
        end
    end,
})

-- ========================================
-- MOSTRAR DISTÂNCIA
-- ========================================

local DistanceToggle = Tab:CreateToggle({
    Name = "Mostrar distância",
    CurrentValue = true,
    Flag = "ESPShowDistance",

    Callback = function(Value)
        ShowDistance = Value

        for _, Data in pairs(ESPObjects) do
            if Data.DistanceLabel then
                Data.DistanceLabel.Visible = Value
            end
        end
    end,
})

-- ========================================
-- NOVOS JOGADORES
-- ========================================

Players.PlayerAdded:Connect(function(Player)
    if ESPEnabled then
        AddESP(Player)
    end
end)

Players.PlayerRemoving:Connect(function(Player)
    RemoveESP(Player)
end)