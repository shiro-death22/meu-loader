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

local Toggle = Tab:CreateToggle({
    Name = "Aim bot",
    CurrentValue = false,
    Flag = "Toggle2",

    Callback = function(Value)

        if AimbotConnection then
            AimbotConnection:Disconnect()
            AimbotConnection = nil
        end

        if InputBeganConnection then
            InputBeganConnection:Disconnect()
            InputBeganConnection = nil
        end

        if InputEndedConnection then
            InputEndedConnection:Disconnect()
            InputEndedConnection = nil
        end

        Aiming = false
        Target = nil
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
                Target = GetClosestTarget()
            end
        end)

        InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton2 then
                Aiming = false
                Target = nil
            end
        end)

        AimbotConnection = RunService.RenderStepped:Connect(function()
            FOVCircle.Position = GetMousePosition()

            if not Aiming then
                return
            end

            if not Target
                or not Target.Parent
                or not Target:IsDescendantOf(workspace) then

                Target = GetClosestTarget()
            end

            if Target then
                local Character = Target.Parent
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

                if not Humanoid or Humanoid.Health <= 0 then
                    Target = GetClosestTarget()
                    return
                end

                Camera.CFrame = CFrame.lookAt(
                    Camera.CFrame.Position,
                    Target.Position
                )
            end
        end)
    end,
})

local Divider = Tab:CreateDivider() -- esp

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESPObjects = {}
local ESPConnections = {}

local function AddESP(Player)
    if Player == LocalPlayer then
        return
    end

    local function Apply(Character)
        if not Character then return end

        if ESPObjects[Player] then
            ESPObjects[Player]:Destroy()
        end

        local Highlight = Instance.new("Highlight")
        Highlight.Name = "EnemyESP"
        Highlight.Adornee = Character
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.FillColor = Color3.fromRGB(255, 0, 0)
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.Parent = Character

        ESPObjects[Player] = Highlight
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

        if Value then
            for _, Player in ipairs(Players:GetPlayers()) do
                AddESP(Player)
            end
        else
            for Player, Highlight in pairs(ESPObjects) do
                if Highlight then
                    Highlight:Destroy()
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