-- SparkHub Ultimate by Sparks0911 v1.1

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- Remove old GUI if exists
local oldGui = playerGui:FindFirstChild("SparkHub")
if oldGui then oldGui:Destroy() end

-- State variables
local toggles = {Fly=false, Noclip=false, ESP=false, InfiniteJump=false}
local flySpeed = 50
local walkSpeed = 16
local jumpPower = 50

local espBoxes = {}
local espConnections = {}

-- Create GUI container (starts disabled)
local gui = Instance.new("ScreenGui")
gui.Name = "SparkHub"
gui.Enabled = false
gui.Parent = playerGui

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 520)
frame.Position = UDim2.new(0.5, -210, 0.5, -260)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "⚡ SparkHub Ultimate ⚡"
title.Font = Enum.Font.FredokaOne
title.TextSize = 36
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.TextStrokeTransparency = 0.4
title.Parent = frame

-- Loading screen (over frame)
local loadingFrame = Instance.new("Frame", gui)
loadingFrame.Size = frame.Size
loadingFrame.Position = frame.Position
loadingFrame.AnchorPoint = frame.AnchorPoint
loadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)

local loadingText = Instance.new("TextLabel", loadingFrame)
loadingText.Size = UDim2.new(1, 0, 0, 30)
loadingText.Position = UDim2.new(0, 0, 0, 10)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Loading SparkHub... 0%"
loadingText.Font = Enum.Font.GothamBold
loadingText.TextSize = 20
loadingText.TextColor3 = Color3.fromRGB(170, 170, 255)

local loadingBarBack = Instance.new("Frame", loadingFrame)
loadingBarBack.Size = UDim2.new(1, -40, 0, 20)
loadingBarBack.Position = UDim2.new(0, 20, 0, 50)
loadingBarBack.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
loadingBarBack.BorderSizePixel = 0

local loadingBarFill = Instance.new("Frame", loadingBarBack)
loadingBarFill.Size = UDim2.new(0, 0, 1, 0)
loadingBarFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
loadingBarFill.BorderSizePixel = 0

local function tweenLoading(percent)
    local tween = TweenService:Create(loadingBarFill, TweenInfo.new(0.3), {Size = UDim2.new(percent, 0, 1, 0)})
    tween:Play()
    loadingText.Text = ("Loading SparkHub... %d%%"):format(percent * 100)
    tween.Completed:Wait()
end

-- Fake loading sequence
spawn(function()
    for i = 0, 1, 0.1 do
        tweenLoading(i)
        wait(0.25)
    end
    tweenLoading(1)
    wait(0.1)
    loadingFrame:Destroy()
    gui.Enabled = true
end)

-- Helper: Create toggle button
local function createToggle(name, y)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.TextColor3 = Color3.fromRGB(230, 230, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.Text = name .. ": OFF"
    btn.AutoButtonColor = true
    return btn
end

-- Helper: Create slider
local function createSlider(name, y, minVal, maxVal, defaultVal)
    local sliderFrame = Instance.new("Frame", frame)
    sliderFrame.Size = UDim2.new(0, 180, 0, 40)
    sliderFrame.Position = UDim2.new(0, 20, 0, y)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.ClipsDescendants = true

    local label = Instance.new("TextLabel", sliderFrame)
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(defaultVal)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(210, 210, 255)
    label.TextStrokeTransparency = 0.6
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0, 4, 0, 0)

    local sliderBar = Instance.new("Frame", sliderFrame)
    sliderBar.Size = UDim2.new(1, -10, 0, 10)
    sliderBar.Position = UDim2.new(0, 5, 0, 25)
    sliderBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    sliderBar.BorderSizePixel = 0
    sliderBar.AnchorPoint = Vector2.new(0, 0)

    local fill = Instance.new("Frame", sliderBar)
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0

    local dragging = false
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    sliderBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local x = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
            local percent = x / sliderBar.AbsoluteSize.X
            fill.Size = UDim2.new(percent, 0, 1, 0)
            local val = math.floor(minVal + (maxVal - minVal) * percent)
            label.Text = name .. ": " .. val
            if name == "WalkSpeed" then
                walkSpeed = val
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = walkSpeed
                end
            elseif name == "JumpPower" then
                jumpPower = val
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.JumpPower = jumpPower
                end
            elseif name == "FlySpeed" then
                flySpeed = val
            end
        end
    end)

    return sliderFrame
end

-- ESP Functions
local function createBoxForPlayer(p)
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(0, 170, 255)
    box.Thickness = 2
    box.Filled = false
    box.Visible = true
    return box
end

local function toggleESP(on)
    if on then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                espBoxes[p] = createBoxForPlayer(p)
            end
        end
        espConnections.RenderStepped = RunService.RenderStepped:Connect(function()
            for p, box in pairs(espBoxes) do
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                    local pos, onScreen = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        box.Visible = true
                        local size = 50 / pos.Z
                        box.Size = Vector2.new(size, size * 2)
                        box.Position = Vector2.new(pos.X - size/2, pos.Y - size)
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
            end
        end)

        espConnections.PlayerAdded = Players.PlayerAdded:Connect(function(p)
            if p ~= player then
                espBoxes[p] = createBoxForPlayer(p)
            end
        end)

        espConnections.PlayerRemoving = Players.PlayerRemoving:Connect(function(p)
            if espBoxes[p] then
                espBoxes[p]:Remove()
                espBoxes[p] = nil
            end
        end)

    else
        if espConnections.RenderStepped then espConnections.RenderStepped:Disconnect() end
        if espConnections.PlayerAdded then espConnections.PlayerAdded:Disconnect() end
        if espConnections.PlayerRemoving then espConnections.PlayerRemoving:Disconnect() end
        for _, box in pairs(espBoxes) do
            box:Remove()
        end
        espBoxes = {}
    end
end

-- Create toggles and sliders
local flyBtn = createToggle("Fly", 80)
local noclipBtn = createToggle("Noclip", 130)
local espBtn = createToggle("ESP", 180)
local infJumpBtn = createToggle("InfiniteJump", 230)

local walkSpeedSlider = createSlider("WalkSpeed", 280, 16, 150, walkSpeed)
local jumpPowerSlider = createSlider("JumpPower", 320, 50, 200, jumpPower)
local flySpeedSlider = createSlider("FlySpeed", 360, 50, 300, flySpeed)

-- Fly mechanics
local flying = false
local bv, bg

local function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    flying = true
    humanoid.PlatformStand = true

    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = Vector3.new()

    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bg.CFrame = hrp.CFrame
end

local function stopFly()
    flying = false
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = false end
end

flyBtn.MouseButton1Click:Connect(function()
    toggles.Fly = not toggles.Fly
    flyBtn.Text = "Fly: " .. (toggles.Fly and "ON" or "OFF")
    if toggles.Fly then startFly() else stopFly() end
end)

noclipBtn.MouseButton1Click:Connect(function()
    toggles.Noclip = not toggles.Noclip
    noclipBtn.Text = "Noclip: " .. (toggles.Noclip and "ON" or "OFF")
end)

espBtn.MouseButton1Click:Connect(function()
    toggles.ESP = not toggles.ESP
    espBtn.Text = "ESP: " .. (toggles.ESP and "ON" or "OFF")
    toggleESP(toggles.ESP)
end)

infJumpBtn.MouseButton1Click:Connect(function()
    toggles.InfiniteJump = not toggles.InfiniteJump
    infJumpBtn.Text = "InfiniteJump: " .. (toggles.InfiniteJump and "ON" or "OFF")
end)

-- Apply WalkSpeed & JumpPower on respawn & start
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = walkSpeed
    humanoid.JumpPower = jumpPower
end)

if player.Character and player.Character:FindFirstChild("Humanoid") then
    player.Character.Humanoid.WalkSpeed = walkSpeed
    player.Character.Humanoid.JumpPower = jumpPower
end

-- Infinite Jump handler
UserInputService.JumpRequest:Connect(function()
    if toggles.InfiniteJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip loop
RunService.Stepped:Connect(function()
    if toggles.Noclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    elseif player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

-- Fly movement update
RunService.RenderStepped:Connect(function()
    if toggles.Fly and flying and player.Character and bv and bg then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end
        bv.Velocity = moveDir * flySpeed
        bg.CFrame = camera.CFrame
    end
end)

