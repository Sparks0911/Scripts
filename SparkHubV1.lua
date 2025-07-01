-- SparkHub V3 - Stylish Redesign Inspired by Ink Game
-- Clean checkboxes, slider, and improved layout

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "SparkHubV3"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 350)
frame.Position = UDim2.new(0.4, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "⚡ SparkHub ⚡"
title.Font = Enum.Font.GothamBlack
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Parent = frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = frame
UIListLayout.FillDirection = Enum.FillDirection.Vertical

-- UI helper
local function createCheckbox(text, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 30)
    container.BackgroundTransparency = 1
    container.LayoutOrder = 1

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Parent = container

    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0.25, 0, 1, 0)
    checkbox.Position = UDim2.new(0.75, 0, 0, 0)
    checkbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    checkbox.Text = "✘"
    checkbox.Font = Enum.Font.GothamBold
    checkbox.TextColor3 = Color3.fromRGB(255, 0, 0)
    checkbox.TextScaled = true
    checkbox.Parent = container

    local enabled = false
    checkbox.MouseButton1Click:Connect(function()
        enabled = not enabled
        checkbox.Text = enabled and "✔" or "✘"
        checkbox.TextColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(enabled)
    end)

    container.Parent = frame
    return container
end

-- Fly
local flyConn
local function toggleFly(state)
    if state then
        local root = Character:WaitForChild("HumanoidRootPart")
        flyConn = RunService.RenderStepped:Connect(function()
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.new(0,1,0) end
            root.Velocity = direction * 50
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.zero
    end
end

-- Noclip
local noclipConn
local function toggleNoclip(state)
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- ESP (box outline version)
local Drawing = Drawing or {} -- fail-safe
local espEnabled = false
local espBoxes = {}

local function createESPBox(player)
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 1.5
    box.Transparency = 1
    box.Visible = false
    espBoxes[player] = box
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espBoxes[player] then createESPBox(player) end
            local part = player.Character.HumanoidRootPart
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
            local size = Vector2.new(50, 100)
            local box = espBoxes[player]
            box.Size = size
            box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
            box.Visible = onScreen and espEnabled
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

-- Inf Jump
local infJumpConn
local function toggleInfJump(state)
    if state then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    else
        if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    end
end

-- WalkSpeed
local speedSlider, labelSlider
local function toggleWalkSpeed(state)
    if state then
        speedSlider = Instance.new("TextButton")
        speedSlider.Size = UDim2.new(1, -20, 0, 30)
        speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        speedSlider.Font = Enum.Font.Gotham
        speedSlider.TextColor3 = Color3.new(1, 1, 1)
        speedSlider.Text = "Speed: 16"
        speedSlider.TextScaled = true
        speedSlider.Parent = frame

        local speed = 16
        speedSlider.MouseButton1Click:Connect(function()
            speed += 4
            if speed > 100 then speed = 16 end
            speedSlider.Text = "Speed: " .. speed
            Humanoid.WalkSpeed = speed
        end)
    else
        Humanoid.WalkSpeed = 16
        if speedSlider then speedSlider:Destroy() speedSlider = nil end
    end
end

-- Add checkboxes
createCheckbox("Fly", toggleFly)
createCheckbox("Noclip", toggleNoclip)
createCheckbox("ESP", function(state) espEnabled = state end)
createCheckbox("WalkSpeed", toggleWalkSpeed)
createCheckbox("Infinite Jump", toggleInfJump)

print("✅ SparkHub V3 loaded")