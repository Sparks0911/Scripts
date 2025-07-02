-- ⚡ SparkHub Universal Script ⚡
-- Full universal hack GUI with Player, Combat ⚔️, Visuals 🎨, and 🚨Emergency🚨 tabs (auto re-enable supported)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "⚡SparkHub⚡",
    LoadingTitle = "",
    LoadingSubtitle = "",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SparkHub",
        FileName = "Config"
    },
    KeySystem = false,
    ToggleUIKeybind = "K"
})

-- Helper functions
local function isAlive(player)
    local char = player.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function isEnemy(player)
    return player ~= LocalPlayer and (not player.Team or player.Team ~= LocalPlayer.Team)
end

local function getHead(char)
    return char and char:FindFirstChild("Head")
end

local function getRootPart(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

-- === Player Tab ===
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- WalkSpeed
PlayerTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end
})

-- Jump Power
PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = val
        end
    end
})

-- Infinite Jump
local infJump = false
UserInputService.JumpRequest:Connect(function()
    if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v) infJump = v end
})

-- Noclip
local noclip = false
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v) noclip = v end
})

-- Fly
local flying = false
local direction = Vector3.zero
local vel, gyro

local function startFly()
    local hrp = getRootPart(LocalPlayer.Character)
    if not hrp then return end
    vel = Instance.new("BodyVelocity")
    vel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    vel.Velocity = Vector3.zero
    vel.Parent = hrp
    gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    gyro.CFrame = hrp.CFrame
    gyro.Parent = hrp
    flying = true
    RunService:BindToRenderStep("Fly", Enum.RenderPriority.Input.Value, function()
        if not flying then return end
        vel.Velocity = Camera.CFrame:VectorToWorldSpace(direction) * 60
        gyro.CFrame = Camera.CFrame
    end)
end

local function stopFly()
    flying = false
    RunService:UnbindFromRenderStep("Fly")
    if vel then vel:Destroy() end
    if gyro then gyro:Destroy() end
end

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)
        if v then startFly() else stopFly() end
    end
})

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.W then direction += Vector3.new(0,0,-1) end
    if input.KeyCode == Enum.KeyCode.S then direction += Vector3.new(0,0,1) end
    if input.KeyCode == Enum.KeyCode.A then direction += Vector3.new(-1,0,0) end
    if input.KeyCode == Enum.KeyCode.D then direction += Vector3.new(1,0,0) end
    if input.KeyCode == Enum.KeyCode.Space then direction += Vector3.new(0,1,0) end
    if input.KeyCode == Enum.KeyCode.LeftControl then direction += Vector3.new(0,-1,0) end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.W then direction -= Vector3.new(0,0,-1) end
    if input.KeyCode == Enum.KeyCode.S then direction -= Vector3.new(0,0,1) end
    if input.KeyCode == Enum.KeyCode.A then direction -= Vector3.new(-1,0,0) end
    if input.KeyCode == Enum.KeyCode.D then direction -= Vector3.new(1,0,0) end
    if input.KeyCode == Enum.KeyCode.Space then direction -= Vector3.new(0,1,0) end
    if input.KeyCode == Enum.KeyCode.LeftControl then direction -= Vector3.new(0,-1,0) end
end)

-- === Combat ⚔️ ===
local CombatTab = Window:CreateTab("Combat ⚔️", 4483362458)
local aimEnabled = false

CombatTab:CreateToggle({
    Name = "Aimbot (Lock Head)",
    CurrentValue = false,
    Callback = function(val)
        aimEnabled = val
    end
})

RunService.RenderStepped:Connect(function()
    if not aimEnabled or not LocalPlayer.Character then return end

    local closest, dist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if isEnemy(plr) and isAlive(plr) then
            local head = getHead(plr.Character)
            if head then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local diff = (Vector2.new(screenPoint.X, screenPoint.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if diff < dist and diff < 250 then
                        closest = head
                        dist = diff
                    end
                end
            end
        end
    end

    if closest then
        local camPos = Camera.CFrame.Position
        local newLookVector = (closest.Position - camPos).Unit
        Camera.CFrame = CFrame.new(camPos, camPos + newLookVector)
    end
end)

-- === Visuals 🎨 ===
local VisualsTab = Window:CreateTab("Visuals 🎨", 4483362458)

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)
        if v then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.Brightness = 5
        else
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            Lighting.Brightness = 1
        end
    end
})

-- Body Outline ESP
local highlightFolder = CoreGui:FindFirstChild("SparkESP")
if not highlightFolder then
    highlightFolder = Instance.new("Folder", CoreGui)
    highlightFolder.Name = "SparkESP"
end

local function refreshESP()
    highlightFolder:ClearAllChildren()
    for _, plr in pairs(Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character then
            local hl = Instance.new("Highlight")
            hl.Adornee = plr.Character
            hl.FillColor = Color3.new(1, 0, 0)
            hl.OutlineColor = Color3.new(1, 0, 0)
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = highlightFolder
        end
    end
end

VisualsTab:CreateToggle({
    Name = "Body Outline ESP",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            refreshESP()
        else
            highlightFolder:ClearAllChildren()
        end
    end
})

-- Auto re-enable ESP on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    local espToggle = VisualsTab:FindFirstChild("Body Outline ESP")
    if espToggle == nil or _G.EnableESP == nil then
        refreshESP()
    elseif _G.EnableESP then
        refreshESP()
    else
        highlightFolder:ClearAllChildren()
    end
end)

-- === Emergency 🚨 ===
local EmergencyTab = Window:CreateTab("🚨Emergency🚨", 4483362458)

EmergencyTab:CreateButton({
    Name = "💀 Self Destruct",
    Callback = function()
        local sound = Instance.new("Sound", workspace)
        sound.SoundId = "rbxassetid://138186576" -- loud scary sound
        sound.Volume = 10
        sound:Play()

        for i = 1, 20 do
            Lighting.Ambient = Color3.new(math.random(), math.random(), math.random())
            task.wait(0.1)
        end

        StarterGui:SetCore("SendNotification", {
            Title = "⚠️ Terminated ⚠️",
            Text = "You have been IP Banned by SparkHub. Your data has been flagged.",
            Duration = 5
        })

        task.wait(2)
        LocalPlayer:Kick("[SparkHub] You have been permanently terminated. Error Code: 403 (IP_BANNED)")
    end
})
