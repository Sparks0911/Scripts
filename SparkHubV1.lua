-- SparkHub 2.0 - Fully customized GUI, no visible Rayfield branding
-- Features: Fly, WalkSpeed, JumpPower, Noclip, Infinite Jump, Aimbot, ESP Body Boxes

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "⚡SparkHub⚡",             -- Your custom GUI title here
    LoadingTitle = "",               -- Hide loading title
    LoadingSubtitle = "",            -- Hide loading subtitle
    ShowText = "",                   -- Hide Rayfield text
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SparkHub2",
        FileName = "PlayerConfig"
    }
})

local PlayerTab = Window:CreateTab("Player", 4483362458)

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Fly Implementation
local flyEnabled = false
local flySpeed = 50
local flyConnection
local bodyVelocity

local function enableFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = char.HumanoidRootPart

    flyConnection = RunService.RenderStepped:Connect(function()
        local vel = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            vel = vel + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            vel = vel - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            vel = vel - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            vel = vel + Camera.CFrame.RightVector
        end
        bodyVelocity.Velocity = vel.Unit * flySpeed
    end)
end

local function disableFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end

PlayerTab:CreateToggle({
    Name = "Fly (WASD)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(value)
        flyEnabled = value
        if flyEnabled then
            enableFly()
        else
            disableFly()
        end
    end
})

-- WalkSpeed Slider
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})

-- JumpPower Slider
PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 5,
    Suffix = "Jump",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end
    end
})

-- Noclip Toggle
local noclipEnabled = false
RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(value)
        noclipEnabled = value
    end
})

-- Infinite Jump Toggle
local infJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(value)
        infJumpEnabled = value
    end
})

-- Aimbot Toggle
local aimbotEnabled = false

local function getClosestEnemyToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mouseLocation = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            if char and char:FindFirstChild("Head") then
                local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(mouseLocation.X, mouseLocation.Y)).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestEnemyToCursor()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "Aimbot (Lock on Head)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(value)
        aimbotEnabled = value
    end
})

-- ESP (Body Box Outlines)
local espEnabled = false
local espAdornments = {}

local function createESPForCharacter(char)
    if espAdornments[char] then return end
    espAdornments[char] = {}
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "ESPBox"
            box.Adornee = part
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
            box.Transparency = 0.5
            box.Color3 = Color3.fromRGB(255, 0, 0)
            box.Parent = part
            table.insert(espAdornments[char], box)
        end
    end
end

local function clearESPForCharacter(char)
    if not espAdornments[char] then return end
    for _, adorn in pairs(espAdornments[char]) do
        if adorn and adorn.Parent then
            adorn:Destroy()
        end
    end
    espAdornments[char] = nil
end

local function toggleESP(state)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if state then
                createESPForCharacter(player.Character)
            else
                clearESPForCharacter(player.Character)
            end
        end
    end
end

PlayerTab:CreateToggle({
    Name = "ESP (Body Outline)",
    CurrentValue = false,
    Flag = "ESPBodyToggle",
    Callback = function(value)
        espEnabled = value
        toggleESP(value)
    end
})
