-- ⚡ SparkHub ⚡
-- Universal hack GUI for Roblox with Player, Combat, Visuals, Emergency tabs

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Load Rayfield UI
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

-- UTILS
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

-- Persistent toggles store
local toggles = {
    walkspeed = 16,
    jumppower = 50,
    infiniteJump = false,
    noclip = false,
    fly = false,
    aimbot = false,
    espBox = false,
    espName = false,
    espHealth = false,
    espOutline = false,
    fullbright = false,
}

-- ====================== PLAYER TAB ======================
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = toggles.walkspeed,
    Callback = function(v)
        toggles.walkspeed = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = toggles.jumppower,
    Callback = function(v)
        toggles.jumppower = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end
})

local infJump = false
UserInputService.JumpRequest:Connect(function()
    if toggles.infiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = toggles.infiniteJump,
    Callback = function(v)
        toggles.infiniteJump = v
    end
})

-- Noclip implementation
local noclipActive = false
local function noclipCharacter()
    if not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

RunService.Stepped:Connect(function()
    if toggles.noclip and LocalPlayer.Character then
        noclipCharacter()
    end
end)

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = toggles.noclip,
    Callback = function(v)
        toggles.noclip = v
    end
})

-- Fly implementation - fixed no fling by moving character CFrame directly
local flying = false
local flyConnection

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flying = true

    -- Disable physics control by server, set network owner to nil to reduce conflict
    hrp:SetNetworkOwner(nil)

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not hrp then return end

        local moveVec = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVec = moveVec + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVec = moveVec - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVec = moveVec - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVec = moveVec + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVec = moveVec + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveVec = moveVec - Vector3.new(0, 1, 0)
        end

        if moveVec.Magnitude > 0 then
            moveVec = moveVec.Unit * 50 -- flying speed
            local newCFrame = hrp.CFrame + moveVec
            hrp.CFrame = newCFrame
        end
    end)
end

local function stopFly()
    flying = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    -- Restore network ownership to player for proper physics
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp:SetNetworkOwner(LocalPlayer)
    end
end

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = toggles.fly,
    Callback = function(v)
        toggles.fly = v
        if v then
            startFly()
        else
            stopFly()
        end
    end
})

-- ====================== COMBAT TAB ======================
local CombatTab = Window:CreateTab("Combat ⚔️", 2809202154)

local aimbotEnabled = false

local maxAimDistance = 100 -- pixels max distance from mouse to head for locking

-- Helper: get closest enemy to mouse within maxAimDistance
local function getClosestEnemyToMouse()
    local closestPlayer = nil
    local shortestDistance = maxAimDistance + 1
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if isEnemy(player) and isAlive(player) and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
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

local function aimbotUpdate()
    if not aimbotEnabled or not isAlive(LocalPlayer) then return end

    local target = getClosestEnemyToMouse()
    if not target or not target.Character then return end

    local head = target.Character:FindFirstChild("Head")
    if not head then return end

    local mousePos = UserInputService:GetMouseLocation()
    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
    if not onScreen then return end

    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
    if dist > maxAimDistance then return end -- outside deadzone

    -- Get current camera position
    local camPos = Camera.CFrame.Position
    local targetPos = head.Position

    -- Calculate horizontal (yaw) rotation only
    local camLookVector = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z).Unit
    local targetDir = Vector3.new((targetPos - camPos).X, 0, (targetPos - camPos).Z).Unit

    local currentYaw = math.atan2(camLookVector.Z, camLookVector.X)
    local targetYaw = math.atan2(targetDir.Z, targetDir.X)
    local yawDiff = targetYaw - currentYaw

    if yawDiff > math.pi then
        yawDiff = yawDiff - 2*math.pi
    elseif yawDiff < -math.pi then
        yawDiff = yawDiff + 2*math.pi
    end

    local smoothFactor = 0.3
    local newYaw = currentYaw + yawDiff * smoothFactor

    local pitch = math.asin(Camera.CFrame.LookVector.Y)

    local newLook = Vector3.new(math.cos(newYaw) * math.cos(pitch), math.sin(pitch), math.sin(newYaw) * math.cos(pitch))

    Camera.CFrame = CFrame.new(camPos, camPos + newLook)
end

CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = aimbotEnabled,
    Callback = function(v)
        aimbotEnabled = v
    end
})

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        aimbotUpdate()
    end
end)

-- ====================== VISUALS TAB ======================
local VisualsTab = Window:CreateTab("Visuals", 6034287594)

-- Fullbright
local normalAmbient = Lighting.Ambient
VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = toggles.fullbright,
    Callback = function(v)
        toggles.fullbright = v
        Lighting.Ambient = v and Color3.new(1,1,1) or normalAmbient
    end
})

-- ESP Setup
local espEnabled = {
    Box = false,
    Name = false,
    Health = false,
    Outline = false,
}

local espData = {}

local function clearESP()
    for player, drawings in pairs(espData) do
        for _, d in pairs(drawings) do
            d:Remove()
        end
    end
    table.clear(espData)
end

-- Store original colors for outline to restore
local originalColors = {}

local function setCharacterOutlineRed(player)
    if not player.Character then return end
    if originalColors[player] then return end -- already applied

    originalColors[player] = {}

    for _, part in pairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            originalColors[player][part] = part.Color
            part.Color = Color3.new(1, 0, 0)
            -- Optional: make them fully visible ignoring lighting
            part.Material = Enum.Material.Neon
        end
    end
end

local function removeCharacterOutline(player)
    if not player.Character then return end
    if not originalColors[player] then return end

    for part, color in pairs(originalColors[player]) do
        if part and part:IsA("BasePart") then
            part.Color = color
            part.Material = Enum.Material.Plastic
        end
    end

    originalColors[player] = nil
end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if espEnabled.Outline and isEnemy(player) and isAlive(player) then
            setCharacterOutlineRed(player)
        else
            removeCharacterOutline(player)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    for player, drawings in pairs(espData) do
        for _, d in pairs(drawings) do
            d.Visible = false
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if isEnemy(player) and isAlive(player) then
            local char = player.Character
            local hrp = getRootPart(char)
            if not hrp then continue end

            if not espData[player] then espData[player] = {} end

            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChild("Humanoid")
                local height = 60
                if head and hrp then
                    height = math.abs(Camera:WorldToViewportPoint(head.Position).Y - pos.Y) * 2
                end

                if espEnabled.Box and not espData[player].box then
                    local box = Drawing.new("Square")
                    box.Color = Color3.new(1, 0, 0)
                    box.Thickness = 2
                    box.Filled = false
                    espData[player].box = box
                end

                if espEnabled.Name and not espData[player].name then
                    local text = Drawing.new("Text")
                    text.Size = 13
                    text.Color = Color3.new(1,1,1)
                    text.Center = true
                    text.Outline = true
                    espData[player].name = text
                end

                if espEnabled.Health and not espData[player].health then
                    local health = Drawing.new("Text")
                    health.Size = 13
                    health.Color = Color3.new(0,1,0)
                    health.Center = true
                    health.Outline = true
                    espData[player].health = health
                end

                -- Position updates
                local boxSize = Vector2.new(height / 2, height)
                if espData[player].box then
                    espData[player].box.Size = boxSize
                    espData[player].box.Position = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
                    espData[player].box.Visible = true
                end
                if espData[player].name and head then
                    espData[player].name.Text = player.Name
                    espData[player].name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y/2 - 16)
                    espData[player].name.Visible = true
                end
                if espData[player].health and hum then
                    espData[player].health.Text = tostring(math.floor(hum.Health))
                    espData[player].health.Position = Vector2.new(pos.X, pos.Y + boxSize.Y/2 + 2)
                    espData[player].health.Visible = true
                end
            else
                for _, d in pairs(espData[player]) do
                    d.Visible = false
                end
            end
        else
            if espData[player] then
                for _, d in pairs(espData[player]) do
                    d.Visible = false
                end
            end
        end
    end
end)

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = toggles.fullbright,
    Callback = function(v)
        toggles.fullbright = v
        Lighting.Ambient = v and Color3.new(1,1,1) or normalAmbient
    end
})

VisualsTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = toggles.espBox,
    Callback = function(v)
        toggles.espBox = v
        espEnabled.Box = v
        if not v then clearESP() end
    end
})

VisualsTab:CreateToggle({
    Name = "ESP Name",
    CurrentValue = toggles.espName,
    Callback = function(v)
        toggles.espName = v
        espEnabled.Name = v
        if not v then clearESP() end
    end
})

VisualsTab:CreateToggle({
    Name = "ESP Health",
    CurrentValue = toggles.espHealth,
    Callback = function(v)
        toggles.espHealth = v
        espEnabled.Health = v
        if not v then clearESP() end
    end
})

VisualsTab:CreateToggle({
    Name = "ESP Outline",
    CurrentValue = toggles.espOutline,
    Callback = function(v)
        toggles.espOutline = v
        espEnabled.Outline = v
    end
})

-- ====================== EMERGENCY TAB ======================
local EmergencyTab = Window:CreateTab("🚨Emergency🚨", 150759850)

local function emergencySelfDestruct()
    -- Create flashing red UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "EmergencyGui"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(1, 0, 0)
    frame.BackgroundTransparency = 0
    frame.Parent = gui

    -- Loud siren sound
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9118824324" -- siren sound, replace if you want
    sound.Volume = 1
    sound.Looped = true
    sound.Parent = frame
    sound:Play()

    -- Flashing effect
    spawn(function()
        local toggle = false
        for i = 1, 40 do
            frame.BackgroundTransparency = toggle and 0.6 or 0
            toggle = not toggle
            wait(0.1)
        end
    end)

    -- Ban message
    local StarterGui = game:GetService("StarterGui")
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Text = "You have been terminated.\nIP BANNED.\nContact admin for appeal."
    label.Font = Enum.Font.ArialBold
    label.Parent = gui

    wait(4)

    sound:Stop()
    gui:Destroy()

    LocalPlayer:Kick("You have been terminated.\nIP BANNED.\nContact admin for appeal.")
end

EmergencyTab:CreateButton({
    Name = "Self Destruct",
    Callback = emergencySelfDestruct
})

-- ====================== REAPPLY TOGGLES ON RESPAWN ======================
local function reapplyToggles()
    -- Player
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = toggles.walkspeed
        LocalPlayer.Character.Humanoid.JumpPower = toggles.jumppower
    end

    -- Noclip reapplied by RunService Stepped

    -- Fly reapplied by toggle
    if toggles.fly then
        startFly()
    else
        stopFly()
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    reapplyToggles()
end)

-- INITIAL APPLY
reapplyToggles()

print("⚡ SparkHub Loaded — Player, Combat, Visuals & Emergency Tabs Ready")
