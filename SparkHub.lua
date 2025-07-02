-- ⚡ SparkHub Universal Script ⚡
-- Full universal hack GUI with Player, Combat ⚔️, Visuals, and 🚨Emergency🚨 tabs

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
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

-- === Utility ===
local function isAlive(player)
    local char = player.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function isEnemy(player)
    return player ~= LocalPlayer and (not player.Team or player.Team ~= LocalPlayer.Team)
end

local function getRootPart(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function getHead(char)
    return char and char:FindFirstChild("Head")
end

-- === Player Tab ===
local PlayerTab = Window:CreateTab("Player", 4483362458)

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

-- Fly system
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
    if not aimEnabled then return end
    local closest, dist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if isEnemy(plr) and isAlive(plr) then
            local head = getHead(plr.Character)
            if head then
                local pos, visible = Camera:WorldToViewportPoint(head.Position)
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if visible and mag < dist then
                    closest, dist = head, mag
                end
            end
        end
    end
    if closest then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
    end
end)

-- === Visuals ===
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

local fullbrightEnabled = false
VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(state)
        fullbrightEnabled = state
        if state then
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.ClockTime = 12
            Lighting.Brightness = 2
        else
            Lighting.Ambient = Color3.new(0.5,0.5,0.5)
            Lighting.ClockTime = 14
            Lighting.Brightness = 1
        end
    end
})

local espEnabled = false
local highlights = {}
VisualsTab:CreateToggle({
    Name = "ESP Outline",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        if state then
            RunService:BindToRenderStep("ESP", Enum.RenderPriority.Camera.Value + 1, function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if isEnemy(player) and isAlive(player) then
                        if not highlights[player] then
                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                            highlight.FillTransparency = 0.2
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.Adornee = player.Character
                            highlight.Parent = player.Character
                            highlights[player] = highlight
                        end
                    elseif highlights[player] then
                        highlights[player]:Destroy()
                        highlights[player] = nil
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("ESP")
            for _, h in pairs(highlights) do
                if h then h:Destroy() end
            end
            highlights = {}
        end
    end
})

-- === 🚨 Emergency 🚨 ===
local EmergencyTab = Window:CreateTab("🚨Emergency🚨", 4483362458)

EmergencyTab:CreateButton({
    Name = "Self Destruct (IP BAN)",
    Callback = function()
        local gui = Instance.new("ScreenGui", game.CoreGui)
        gui.IgnoreGuiInset = true

        local frame = Instance.new("Frame", gui)
        frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        frame.Size = UDim2.new(1, 0, 1, 0)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = "⚠️ IP BANNED BY SPARKHUB ⚠️\nYour account and IP are now permanently terminated.\nYou violated section 101 of SparkHub protocols."
        label.TextColor3 = Color3.new(1,1,1)
        label.TextScaled = true
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBlack

        local sound = Instance.new("Sound", SoundService)
        sound.SoundId = "rbxassetid://9118823101"
        sound.Volume = 10
        sound.Looped = true
        sound:Play()

        for i = 1, 10 do
            frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            task.wait(0.1)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            task.wait(0.1)
        end

        game:Shutdown()
    end
})

print("✅ SparkHub Loaded")
