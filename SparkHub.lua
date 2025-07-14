-- SparkHub 2.0 - Rayfield Edition using Sirius Docs

-- Load Rayfield from Sirius menu
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create the UI Window
local Window = Rayfield:CreateWindow({
    Name = "⚡ SparkHub ⚡",
    LoadingTitle = "Loading SparkHub...",
    LoadingSubtitle = "Made by Sparks0911",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SparkHub",
        FileName = "config"
    },
    Discord = {Enabled = false},
    KeySystem = false,
})

-- Player Tab
local PlayerTab = Window:CreateTab("Player")

-- WalkSpeed
local walkSpeed = 16
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 300},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        walkSpeed = Value
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = walkSpeed end
    end,
})

-- JumpPower
local jumpPower = 50
PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        jumpPower = Value
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = jumpPower end
    end,
})

-- Infinite Jump
local UIS = game:GetService("UserInputService")
local infJump = false
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        infJump = Value
    end,
})
UIS.JumpRequest:Connect(function()
    if infJump then
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- Visuals Tab
local VisualTab = Window:CreateTab("Visuals")

-- Fullbright
local fullbright = false
local lighting = game:GetService("Lighting")
local original = {
    Ambient = lighting.Ambient,
    Brightness = lighting.Brightness,
    ClockTime = lighting.ClockTime,
    FogEnd = lighting.FogEnd,
}
VisualTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(val)
        fullbright = val
        if fullbright then
            lighting.Ambient = Color3.new(1,1,1)
            lighting.Brightness = 3
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
        else
            lighting.Ambient = original.Ambient
            lighting.Brightness = original.Brightness
            lighting.ClockTime = original.ClockTime
            lighting.FogEnd = original.FogEnd
        end
    end
})

-- ESP
local ESPEnabled = false
local ESPFolder = Instance.new("Folder", workspace)
ESPFolder.Name = "SparkHubESP"

function AddESP(player)
    if player == game.Players.LocalPlayer then return end
    local char = player.Character
    if char and not ESPFolder:FindFirstChild(player.Name) then
        local hl = Instance.new("Highlight", ESPFolder)
        hl.Adornee = char
        hl.FillColor = Color3.new(1, 0, 0)
        hl.OutlineColor = Color3.new(1, 0, 0)
        hl.Name = player.Name
    end
end

function RemoveESP(player)
    local hl = ESPFolder:FindFirstChild(player.Name)
    if hl then hl:Destroy() end
end

VisualTab:CreateToggle({
    Name = "Red Outline ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(val)
        ESPEnabled = val
        if not val then
            ESPFolder:ClearAllChildren()
        else
            for _, p in pairs(game.Players:GetPlayers()) do
                AddESP(p)
            end
        end
    end,
})

game.Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if ESPEnabled then task.wait(1) AddESP(p) end
    end)
end)

game.Players.PlayerRemoving:Connect(RemoveESP)

-- Combat Tab
local CombatTab = Window:CreateTab("Combat")

-- Aimbot
local cam = workspace.CurrentCamera
local aiming = false
local aimbotFOV = 100
CombatTab:CreateToggle({
    Name = "Hold E for Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(val)
        aiming = val
    end
})

CombatTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {10, 300},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(v)
        aimbotFOV = v
    end,
})

local UserInput = game:GetService("UserInputService")
local aimbotHeld = false
UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then aimbotHeld = true end
end)
UserInput.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then aimbotHeld = false end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if aiming and aimbotHeld then
        local closest, dist = nil, aimbotFOV
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local pos, onscreen = cam:WorldToViewportPoint(player.Character.Head.Position)
                local mouse = Vector2.new(UserInput:GetMouseLocation().X, UserInput:GetMouseLocation().Y)
                local distance = (mouse - Vector2.new(pos.X, pos.Y)).Magnitude
                if onscreen and distance < dist then
                    dist = distance
                    closest = player
                end
            end
        end
        if closest then
            cam.CFrame = CFrame.new(cam.CFrame.Position, closest.Character.Head.Position)
        end
    end
end)

-- Misc Tab
local MiscTab = Window:CreateTab("Misc")

-- Fly (F toggle)
local flying = false
local BV, BG
MiscTab:CreateToggle({
    Name = "Fly (Press F)",
    CurrentValue = false,
    Callback = function(v)
        flying = v
        local root = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        if v then
            BV = Instance.new("BodyVelocity", root)
            BV.Velocity = Vector3.zero
            BV.MaxForce = Vector3.new(1e5,1e5,1e5)
            BG = Instance.new("BodyGyro", root)
            BG.CFrame = root.CFrame
            BG.MaxTorque = Vector3.new(1e5,1e5,1e5)
        else
            if BV then BV:Destroy() end
            if BG then BG:Destroy() end
        end
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if flying and BV then
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
        BV.Velocity = move * 50
        BG.CFrame = cam.CFrame
    end
end)

-- Noclip
local noclip = false
MiscTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        noclip = v
    end
})
game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        for _, part in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Emergency Tab
local EmergencyTab = Window:CreateTab("🚨 Emergency 🚨")

-- Self Destruct
EmergencyTab:CreateButton({
    Name = "Self Destruct & Remove SparkHub",
    Callback = function()
        for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("BasePart") then v:Destroy() end
        end
        Rayfield:Destroy()
        ESPFolder:Destroy()
    end
})

-- Cleanup
EmergencyTab:CreateButton({
    Name = "Reset Speed/Jump/Fly/Noclip",
    Callback = function()
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        flying = false
        noclip = false
        infJump = false
        if BV then BV:Destroy() end
        if BG then BG:Destroy() end
        ESPFolder:ClearAllChildren()
    end
})

-- Load user config
Rayfield:LoadConfiguration()
