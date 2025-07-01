local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- Clean old GUI
local oldGui = playerGui:FindFirstChild("SparkHub")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SparkHub"
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 400)
frame.Position = UDim2.new(0.5, -200, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "✨ SparkHub ✨"
title.Font = Enum.Font.FredokaOne
title.TextSize = 32
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.Parent = frame

-- Utility to create toggle buttons
local function createToggle(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.TextColor3 = Color3.fromRGB(220, 220, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.Text = text .. ": OFF"
    btn.Parent = frame
    return btn
end

-- Variables
local toggles = {
    Fly = false,
    Noclip = false,
    ESP = false,
}

local walkSpeed = 16
local flying = false
local bv, bg

-- Create toggles
local flyBtn = createToggle("Fly", 80)
local noclipBtn = createToggle("Noclip", 130)
local espBtn = createToggle("ESP", 180)

-- Fly functions
local function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    flying = true
    humanoid.PlatformStand = true

    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0, 0, 0)

    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
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

noclipBtn.MouseButton1Click:Connect(function()
    toggles.Noclip = not toggles.Noclip
    noclipBtn.Text = "Noclip: " .. (toggles.Noclip and "ON" or "OFF")
end)

-- ESP (basic example - draws simple boxes)
local espBoxes = {}

local function createBox(player)
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(0, 170, 255)
    box.Thickness = 2
    box.Filled = false
    box.Visible = true
    return box
end

local function toggleESP(on)
    if on then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                espBoxes[plr] = createBox(plr)
            end
        end
        RunService.RenderStepped:Connect(function()
            for plr, box in pairs(espBoxes) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local pos, onScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local size = 50 / pos.Z
                        box.Size = Vector2.new(size, size * 2)
                        box.Position = Vector2.new(pos.X - size/2, pos.Y - size)
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
            end
        end)
    else
        for _, box in pairs(espBoxes) do
            box:Remove()
        end
        espBoxes = {}
    end
end

espBtn.MouseButton1Click:Connect(function()
    toggles.ESP = not toggles.ESP
    espBtn.Text = "ESP: " .. (toggles.ESP and "ON" or "OFF")
    toggleESP(toggles.ESP)
end)

-- WalkSpeed changer (optional, basic)
local walkSpeedBtn = createToggle("WalkSpeed (16 default)", 230)
walkSpeedBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        if walkSpeed == 16 then
            walkSpeed = 50
        else
            walkSpeed = 16
        end
        player.Character.Humanoid.WalkSpeed = walkSpeed
        walkSpeedBtn.Text = "WalkSpeed (" .. walkSpeed .. ")"
    end
end)

-- Set initial WalkSpeed
if player.Character and player.Character:FindFirstChild("Humanoid") then
    player.Character.Humanoid.WalkSpeed = walkSpeed
end

