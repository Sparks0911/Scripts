--// SparkHub V2 - Clean, Toggleable, No Sounds, Fully Functional 
--// By Sparks0911 + ChatGPT ❤️

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ScreenGui setup
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "SparkHubV2"

-- Main frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "✨ SparkHub V2 ✨"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 170, 255)

-- Layout
local layout = Instance.new("UIListLayout", frame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
title.LayoutOrder = 0

-- Helper function
local function createToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.Text = name .. ": OFF"

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state, btn)
    end)

    return btn
end

--// Features

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
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ESP
local espEnabled = false
local espObjects = {}

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if not espObjects[player] then
                local box = Drawing.new("Text")
                box.Text = player.Name
                box.Size = 16
                box.Color = Color3.new(1, 1, 1)
                box.Outline = true
                box.Visible = true
                espObjects[player] = box
            end

            local head = player.Character.Head
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
            espObjects[player].Position = Vector2.new(pos.X, pos.Y)
            espObjects[player].Visible = onScreen
        end
    end
end

RunService.RenderStepped:Connect(function()
    if espEnabled then
        updateESP()
    else
        for _, v in pairs(espObjects) do v.Visible = false end
    end
end)

-- WalkSpeed
local wsSlider, wsLabel
local function toggleWalkSpeed(state, btn)
    if state then
        wsSlider = Instance.new("TextButton")
        wsSlider.Size = UDim2.new(1, -20, 0, 40)
        wsSlider.Text = "WalkSpeed: 16"
        wsSlider.Font = Enum.Font.Gotham
        wsSlider.TextSize = 18
        wsSlider.TextColor3 = Color3.fromRGB(200,200,255)
        wsSlider.BackgroundColor3 = Color3.fromRGB(35,35,50)
        wsSlider.Parent = frame

        local speed = 16
        wsSlider.MouseButton1Click:Connect(function()
            speed += 4
            if speed > 100 then speed = 16 end
            Humanoid.WalkSpeed = speed
            wsSlider.Text = "WalkSpeed: " .. tostring(speed)
        end)
    else
        Humanoid.WalkSpeed = 16
        if wsSlider then wsSlider:Destroy() wsSlider = nil end
    end
end

-- Infinite Jump
local ijConn
local function toggleInfJump(state)
    if state then
        ijConn = UserInputService.JumpRequest:Connect(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    else
        if ijConn then ijConn:Disconnect() ijConn = nil end
    end
end

-- Add Toggles
local features = {
    {"Fly", toggleFly},
    {"Noclip", toggleNoclip},
    {"ESP", function(state) espEnabled = state end},
    {"WalkSpeed", toggleWalkSpeed},
    {"Infinite Jump", toggleInfJump},
}

for _, data in ipairs(features) do
    local btn = createToggle(data[1], data[2])
    btn.Parent = frame
end

print("SparkHub V2 loaded successfully ✅")
