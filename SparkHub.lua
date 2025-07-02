-- ⚡ SparkHub Universal Script with Aimbot ⚡

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
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

-- Helpers
local function isAlive(player)
    local char = player.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function isEnemy(player)
    return player ~= LocalPlayer and (not player.Team or player.Team ~= LocalPlayer.Team)
end

local function getRootPart(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
end

local function getHead(char)
    return char and char:FindFirstChild("Head")
end

-- === Player Tab ===
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- WalkSpeed Slider
PlayerTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

-- JumpPower Slider
PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end
})

-- Infinite Jump Toggle
local infJump = false
UserInputService.JumpRequest:Connect(function()
    if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        infJump = v
    end
})

-- Noclip Toggle
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
    Callback = function(v)
        noclip = v
    end
})

-- Fly System (fixed controls)
local flying = false
local manualFlyEnabled = false
local flySpeed = 60
local moveVector = Vector3.new(0,0,0)
local flyVelocity
local flyGyro
local hrp = nil

local function startManualFly()
    if flying then return end
    hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyVelocity.Velocity = Vector3.new(0,0,0)
    flyVelocity.Parent = hrp

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    flyGyro.CFrame = hrp.CFrame
    flyGyro.Parent = hrp

    flying = true
    manualFlyEnabled = true
    moveVector = Vector3.new(0,0,0)

    RunService:BindToRenderStep("ManualFly", Enum.RenderPriority.Input.Value, function()
        if not flying or not hrp then return end
        local camCFrame = Camera.CFrame
        local dir = (camCFrame.LookVector * moveVector.Z) + (camCFrame.RightVector * moveVector.X) + Vector3.new(0, moveVector.Y, 0)
        if dir.Magnitude > 0 then
            dir = dir.Unit * flySpeed
        else
            dir = Vector3.new(0,0,0)
        end
        flyVelocity.Velocity = dir
        flyGyro.CFrame = camCFrame
    end)
end

local function stopManualFly()
    flying = false
    manualFlyEnabled = false
    RunService:UnbindFromRenderStep("ManualFly")
    if flyVelocity then flyVelocity:Destroy() flyVelocity=nil end
    if flyGyro then flyGyro:Destroy() flyGyro=nil end
    hrp = nil
    moveVector = Vector3.new(0,0,0)
end

-- Manual Fly input controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not manualFlyEnabled then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.W then moveVector = moveVector + Vector3.new(0,0,1)
    elseif k == Enum.KeyCode.S then moveVector = moveVector + Vector3.new(0,0,-1)
    elseif k == Enum.KeyCode.A then moveVector = moveVector + Vector3.new(-1,0,0)
    elseif k == Enum.KeyCode.D then moveVector = moveVector + Vector3.new(1,0,0)
    elseif k == Enum.KeyCode.Space then moveVector = moveVector + Vector3.new(0,1,0)
    elseif k == Enum.KeyCode.LeftControl then moveVector = moveVector + Vector3.new(0,-1,0)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or not manualFlyEnabled then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.W then moveVector = moveVector - Vector3.new(0,0,1)
    elseif k == Enum.KeyCode.S then moveVector = moveVector - Vector3.new(0,0,-1)
    elseif k == Enum.KeyCode.A then moveVector = moveVector - Vector3.new(-1,0,0)
    elseif k == Enum.KeyCode.D then moveVector = moveVector - Vector3.new(1,0,0)
    elseif k == Enum.KeyCode.Space then moveVector = moveVector - Vector3.new(0,1,0)
    elseif k == Enum.KeyCode.LeftControl then moveVector = moveVector - Vector3.new(0,-1,0)
    end
end)

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)
        if v then
            startManualFly()
        else
            stopManualFly()
        end
    end
})

-- === Combat Tab ⚔️ ===
local CombatTab = Window:CreateTab("Combat ⚔️", 4483362458)

-- Aimbot Variables
local aimbotEnabled = false
local aimbotTarget = nil
local aimbotFOV = 70 -- degrees (not visible in UI as per your request)
local aimbotSmoothness = 0.15 -- how smoothly the camera moves
local mouse = game.Players.LocalPlayer:GetMouse()

-- Function to find closest enemy head within FOV
local function getClosestTarget()
    local closestPlayer = nil
    local closestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and isAlive(player) and player.Character then
            local head = getHead(player.Character)
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mousePos = Vector2.new(mouse.X, mouse.Y)
                    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (mousePos - targetPos).Magnitude
                    if dist < closestDist and dist <= aimbotFOV then
                        closestDist = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Smoothly move camera toward target's head
RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if not aimbotEnabled then return end
    local target = getClosestTarget()
    if target and target.Character and isAlive(target) then
        local head = getHead(target.Character)
        if head then
            local currentCF = Camera.CFrame
            local direction = (head.Position - currentCF.Position).Unit
            local newLookVector = currentCF.LookVector:Lerp(direction, aimbotSmoothness)
            Camera.CFrame = CFrame.new(currentCF.Position, currentCF.Position + newLookVector)
        end
    end
end)

CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(v)
        aimbotEnabled = v
    end
})

-- === Visuals Tab ===
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- Fullbright Toggle
local fullbrightOn = false
local originalLighting = {}

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)
        fullbrightOn = v
        if v then
            originalLighting.Ambient = Lighting.Ambient
            originalLighting.Brightness = Lighting.Brightness
            originalLighting.ClockTime = Lighting.ClockTime
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
        else
            if originalLighting.Ambient then Lighting.Ambient = originalLighting.Ambient end
            if originalLighting.Brightness then Lighting.Brightness = originalLighting.Brightness end
            if originalLighting.ClockTime then Lighting.ClockTime = originalLighting.ClockTime end
        end
    end
})

-- Body Outline ESP (whole character glows red through walls)
local highlights = {}
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and isAlive(player) then
            if not highlights[player] then
                local char = player.Character
                if char then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.4
                    highlight.OutlineColor = Color3.new(1, 0, 0)
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = char
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = char
                    highlights[player] = highlight
                end
            end
        else
            if highlights[player] then
                highlights[player]:Destroy()
                highlights[player] = nil
            end
        end
    end
end

VisualsTab:CreateToggle({
    Name = "Body Outline ESP",
    CurrentValue = false,
    Callback = function(v)
        if v then
            RunService:BindToRenderStep("SparkHubESP", Enum.RenderPriority.Camera.Value + 1, updateESP)
        else
            RunService:UnbindFromRenderStep("SparkHubESP")
            for _, h in pairs(highlights) do
                if h then h:Destroy() end
            end
            highlights = {}
        end
    end
})

-- === Emergency Tab 🚨 ===
local EmergencyTab = Window:CreateTab("🚨Emergency🚨", 4483362458)

EmergencyTab:CreateButton({
    Name = "Self Destruct",
    Callback = function()
        local flicker = true

        -- Create ScreenGui with flashing text
        local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
        screenGui.ResetOnSpawn = false
        local textLabel = Instance.new("TextLabel", screenGui)
        textLabel.Size = UDim2.new(1,0,1,0)
        textLabel.BackgroundColor3 = Color3.new(0,0,0)
        textLabel.TextColor3 = Color3.new(1,0,0)
        textLabel.TextScaled = true
        textLabel.Text = "!!! SYSTEM TERMINATED !!!"
        textLabel.Font = Enum.Font.Fantasy
        textLabel.TextStrokeTransparency = 0
        textLabel.TextWrapped = true

        -- Flicker effect
        spawn(function()
            while flicker do
                textLabel.TextTransparency = math.random()
                textLabel.BackgroundColor3 = Color3.new(math.random(),0,0)
                wait(0.05)
            end
        end)

        -- Loud scary sound
        local sound = Instance.new("Sound", workspace)
        sound.SoundId = "rbxassetid://1843521708" -- Loud siren sound
        sound.Volume = 1.5
        sound.Looped = true
        sound:Play()

        -- Screen shake effect
        local originalCamCFrame = Camera.CFrame
        spawn(function()
            while flicker do
                local offset = Vector3.new(
                    math.random(-5,5)/50,
                    math.random(-5,5)/50,
                    math.random(-5,5)/50
                )
                Camera.CFrame = originalCamCFrame * CFrame.new(offset)
                wait(0.05)
            end
            Camera.CFrame = originalCamCFrame
        end)

        -- After 7 seconds kick with ban message
        delay(7, function()
            flicker = false
            sound:Stop()
            screenGui:Destroy()
            LocalPlayer:Kick("You have been TERMINATED. IP logged. No appeals.")
        end)
    end
})

-- Finished --

print("⚡ SparkHub loaded successfully! Press K to toggle UI.")

-- Auto-load last saved configs
Rayfield:LoadConfiguration()

-- Reapply settings after respawn
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    wait(1)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = Window.Flags["Walkspeed"] or 16
    humanoid.JumpPower = Window.Flags["Jump Power"] or 50

    -- Reapply noclip
    if noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Reapply fly if active
    if manualFlyEnabled then
        stopManualFly()
        startManualFly()
    end

    -- Reapply ESP if active
    if Window.Flags["Body Outline ESP"] then
        RunService:BindToRenderStep("SparkHubESP", Enum.RenderPriority.Camera.Value + 1, updateESP)
    end
end)
