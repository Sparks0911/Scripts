local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SparkHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 440)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1,0,0,40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(18,18,18)
TitleLabel.BorderSizePixel = 0
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 24
TitleLabel.Text = "⚡SparkHub⚡"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Parent = MainFrame

local hue = 0
spawn(function()
    while true do
        hue = (hue + 1) % 360
        TitleLabel.TextColor3 = Color3.fromHSV(hue/360, 1, 1)
        wait(0.03)
    end
end)

local Tabs = {"Player", "Visuals", "Misc", "🚨Emergency🚨"}

local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Size = UDim2.new(1,0,0,30)
TabButtonsFrame.Position = UDim2.new(0,0,0,40)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.Parent = MainFrame

local TabContents = {}
local SelectedTab = nil

for i, tabName in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#Tabs, -6, 1, 0)
    btn.Position = UDim2.new((i-1)/#Tabs, 3, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Parent = TabButtonsFrame

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 1, -80)
    frame.Position = UDim2.new(0, 10, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = MainFrame
    TabContents[tabName] = frame

    btn.MouseButton1Click:Connect(function()
        if SelectedTab then TabContents[SelectedTab].Visible = false end
        SelectedTab = tabName
        frame.Visible = true
        for _, b in pairs(TabButtonsFrame:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = (b == btn) and Color3.fromRGB(70,70,70) or Color3.fromRGB(40,40,40)
            end
        end
    end)
end
SelectedTab = Tabs[1]
TabContents[SelectedTab].Visible = true
for _, b in pairs(TabButtonsFrame:GetChildren()) do
    if b:IsA("TextButton") then
        b.BackgroundColor3 = (b.Text == SelectedTab) and Color3.fromRGB(70,70,70) or Color3.fromRGB(40,40,40)
    end
end

local function CreateToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 22)
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -11)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.Parent = frame

    local toggled = default

    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleBtn.Text = toggled and "ON" or "OFF"
        callback(toggled)
    end)

    return frame, function() return toggled end
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 12)
    sliderFrame.Position = UDim2.new(0, 5, 0, 24)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderFrame.Parent = frame
    sliderFrame.BorderSizePixel = 0
    sliderFrame.ClipsDescendants = true

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    sliderFill.Parent = sliderFrame

    local dragging = false

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
            local percent = relativeX / sliderFrame.AbsoluteSize.X
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            local value = min + (max - min) * percent
            callback(value)
        end
    end)

    return frame
end

local toggles = {
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    ESP = false,
    Aimbot = false,
    FullBright = false,
}

local walkSpeedValue = 16

local flySpeed = 50
local flyBodyVelocity = nil
local flyBodyGyro = nil

local function startFly()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBodyVelocity.Velocity = Vector3.new(0,0,0)
    flyBodyVelocity.Parent = hrp
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    flyBodyGyro.Parent = hrp
end

local function stopFly()
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
end

local flyControlVector = Vector3.new(0,0,0)
UserInputService.InputBegan:Connect(function(input)
    if toggles.Fly then
        if input.KeyCode == Enum.KeyCode.W then flyControlVector = flyControlVector + Vector3.new(0,0,-1) end
        if input.KeyCode == Enum.KeyCode.S then flyControlVector = flyControlVector + Vector3.new(0,0,1) end
        if input.KeyCode == Enum.KeyCode.A then flyControlVector = flyControlVector + Vector3.new(-1,0,0) end
        if input.KeyCode == Enum.KeyCode.D then flyControlVector = flyControlVector + Vector3.new(1,0,0) end
        if input.KeyCode == Enum.KeyCode.Space then flyControlVector = flyControlVector + Vector3.new(0,1,0) end
        if input.KeyCode == Enum.KeyCode.LeftControl then flyControlVector = flyControlVector + Vector3.new(0,-1,0) end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if toggles.Fly then
        if input.KeyCode == Enum.KeyCode.W then flyControlVector = flyControlVector - Vector3.new(0,0,-1) end
        if input.KeyCode == Enum.KeyCode.S then flyControlVector = flyControlVector - Vector3.new(0,0,1) end
        if input.KeyCode == Enum.KeyCode.A then flyControlVector = flyControlVector - Vector3.new(-1,0,0) end
        if input.KeyCode == Enum.KeyCode.D then flyControlVector = flyControlVector - Vector3.new(1,0,0) end
        if input.KeyCode == Enum.KeyCode.Space then flyControlVector = flyControlVector - Vector3.new(0,1,0) end
        if input.KeyCode == Enum.KeyCode.LeftControl then flyControlVector = flyControlVector - Vector3.new(0,-1,0) end
    end
end)

RunService.Heartbeat:Connect(function()
    if toggles.Fly and flyBodyVelocity and flyBodyGyro then
        local cameraCFrame = workspace.CurrentCamera.CFrame
        local moveVec = (cameraCFrame.RightVector * flyControlVector.X) + (cameraCFrame.LookVector * flyControlVector.Z) + Vector3.new(0, flyControlVector.Y, 0)
        flyBodyVelocity.Velocity = moveVec.Unit * flySpeed
        flyBodyGyro.CFrame = cameraCFrame
    end
end)

local noclipConnection = nil
local function startNoclip()
    noclipConnection = RunService.Stepped:Connect(function()
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end)
end
local function stopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

UserInputService.JumpRequest:Connect(function()
    if toggles.InfiniteJump then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local humanoid = nil
local function updateWalkSpeed(value)
    humanoid = humanoid or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
    if humanoid then
        humanoid.WalkSpeed = value
    end
    walkSpeedValue = value
end

LocalPlayer.CharacterAdded:Connect(function(char)
    humanoid = nil
    wait(1)
    humanoid = char:WaitForChild("Humanoid")
    if toggles.Fly then startFly() end
    if toggles.Noclip then startNoclip() end
    updateWalkSpeed(walkSpeedValue)
    if toggles.ESP then enableESP() end
    if toggles.Aimbot then startAimbot() end
end)

local ESPObjects = {}
local function createESPForCharacter(character)
    if ESPObjects[character] then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.Parent = Camera
    ESPObjects[character] = highlight
end

local function removeESPForCharacter(character)
    if ESPObjects[character] then
        ESPObjects[character]:Destroy()
        ESPObjects[character] = nil
    end
end

function enableESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            createESPForCharacter(plr.Character)
        end
    end
end

function disableESP()
    for character, highlight in pairs(ESPObjects) do
        highlight:Destroy()
        ESPObjects[character] = nil
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if toggles.ESP then
            createESPForCharacter(char)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        removeESPForCharacter(plr.Character)
    end
end)

local aimbotTarget = nil
local aimbotEnabled = false

local function getClosestTarget()
    local closestDist = math.huge
    local target = nil
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local head = plr.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if dist < closestDist and dist < 100 then
                    closestDist = dist
                    target = plr
                end
            end
        end
    end
    return target
end

local function startAimbot()
    aimbotEnabled = true
end

local function stopAimbot()
    aimbotEnabled = false
    aimbotTarget = nil
end

RunService.RenderStepped:Connect(function()
    if toggles.Aimbot and aimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            aimbotTarget = target
            local headPos = target.Character.Head.Position
            local cameraPos = Camera.CFrame.Position
            local direction = (headPos - cameraPos).Unit
            Camera.CFrame = CFrame.new(cameraPos, cameraPos + direction)
        else
            aimbotTarget = nil
        end
    end
end)

local function applyToggles()
    if toggles.Fly then startFly() else stopFly() end
    if toggles.Noclip then startNoclip() else stopNoclip() end
    if toggles.ESP then enableESP() else disableESP() end
    if toggles.Aimbot then startAimbot() else stopAimbot() end
    updateWalkSpeed(walkSpeedValue)
end

local playerTab = TabContents["Player"]
local flyToggle, getFly = CreateToggle(playerTab, "Fly", false, function(state)
    toggles.Fly = state
    applyToggles()
end)
flyToggle.Position = UDim2.new(0, 10, 0, 10)

local noclipToggle, getNoclip = CreateToggle(playerTab, "Noclip", false, function(state)
    toggles.Noclip = state
    applyToggles()
end)
noclipToggle.Position = UDim2.new(0, 10, 0, 50)

local infiniteJumpToggle, getInfiniteJump = CreateToggle(playerTab, "Infinite Jump", false, function(state)
    toggles.InfiniteJump = state
end)
infiniteJumpToggle.Position = UDim2.new(0, 10, 0, 90)

local walkSpeedSlider = CreateSlider(playerTab, "WalkSpeed", 8, 100, 16, function(value)
    walkSpeedValue = math.floor(value)
    updateWalkSpeed(walkSpeedValue)
end)
walkSpeedSlider.Position = UDim2.new(0, 10, 0, 130)

local visualsTab = TabContents["Visuals"]
local espToggle, getESP = CreateToggle(visualsTab, "ESP (Red Neon)", false, function(state)
    toggles.ESP = state
    applyToggles()
end)
espToggle.Position = UDim2.new(0, 10, 0, 10)

local aimbotToggle, getAimbot = CreateToggle(visualsTab, "Aimbot", false, function(state)
    toggles.Aimbot = state
    applyToggles()
end)
aimbotToggle.Position = UDim2.new(0, 10, 0, 50)

local miscTab = TabContents["Misc"]
local fullBrightToggle, getFullBright = CreateToggle(miscTab, "FullBright (One Toggle)", false, function(state)
    toggles.FullBright = state
    if state then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").ClockTime = 12
        game:GetService("Lighting").FogEnd = 1000
    end
end)
fullBrightToggle.Position = UDim2.new(0, 10, 0, 10)

local emergencyTab = TabContents["🚨Emergency🚨"]
local selfDestructToggle, getSelfDestruct = CreateToggle(emergencyTab, "Self Destruct (Kick & Effects)", false, function(state)
    if state then
        local flash = Instance.new("Frame")
        flash.Size = UDim2.new(1,0,1,0)
        flash.BackgroundColor3 = Color3.new(1,0,0)
        flash.BackgroundTransparency = 0.5
        flash.Parent = ScreenGui
        wait(3)
        LocalPlayer:Kick("Self destruct activated by SparkHub")
    else
        local flash = ScreenGui:FindFirstChildWhichIsA("Frame")
        if flash then flash:Destroy() end
    end
end)
selfDestructToggle.Position = UDim2.new(0, 10, 0, 10)

LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    applyToggles()
end)

applyToggles()
