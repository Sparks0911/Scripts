-- SparkHub Exploit GUI Script by Sparks0911
-- Features: Fly (with 10 sec kick), Noclip, ESP, WalkSpeed slider, flashy scary troll effects

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean up old GUI if exists
local oldGui = playerGui:FindFirstChild("SparkHub")
if oldGui then oldGui:Destroy() end

-- Helper functions
local function createTextLabel(props)
    local label = Instance.new("TextLabel")
    for k,v in pairs(props) do label[k] = v end
    return label
end
local function createButton(props)
    local btn = Instance.new("TextButton")
    for k,v in pairs(props) do btn[k] = v end
    return btn
end
local function createFrame(props)
    local frame = Instance.new("Frame")
    for k,v in pairs(props) do frame[k] = v end
    return frame
end

-- Main GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SparkHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local mainFrame = createFrame{
    Name = "MainFrame",
    Size = UDim2.new(0, 400, 0, 460),
    Position = UDim2.new(0.5, -200, 0.5, -230),
    BackgroundColor3 = Color3.fromRGB(20,20,30),
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
    Parent = gui
}

local title = createTextLabel{
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundTransparency = 1,
    Text = "✨ SparkHub ✨",
    Font = Enum.Font.FredokaOne,
    TextSize = 36,
    TextColor3 = Color3.fromRGB(0, 170, 255),
    Parent = mainFrame,
}

-- Loading label (fades out on load)
local loadingLabel = createTextLabel{
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 60),
    BackgroundTransparency = 1,
    Text = "Loading...",
    Font = Enum.Font.FredokaOne,
    TextSize = 24,
    TextColor3 = Color3.fromRGB(0, 170, 255),
    Parent = mainFrame,
}

-- Tween out loading label after 3 seconds
task.delay(3, function()
    TweenService:Create(loadingLabel, TweenInfo.new(1), {TextTransparency=1}):Play()
    TweenService:Create(loadingLabel, TweenInfo.new(1), {BackgroundTransparency=1}):Play()
    task.wait(1)
    loadingLabel:Destroy()
end)

-- State variables
local toggles = {
    Fly = false,
    Noclip = false,
    ESP = false,
}
local flyTimer = 0
local flyKickTime = 10 -- seconds until kick after flying

-- Walkspeed vars
local walkspeed = 16
local maxWalkspeed = 100

-- ESP containers
local espBoxes = {}

-- Sounds for trolling
local alarmSound = Instance.new("Sound", playerGui)
alarmSound.SoundId = "rbxassetid://142376088" -- alarm siren
alarmSound.Looped = true
alarmSound.Volume = 0

local staticSound = Instance.new("Sound", playerGui)
staticSound.SoundId = "rbxassetid://9118826040" -- static noise
staticSound.Looped = true
staticSound.Volume = 0

-- Flash frame for scary flashing effect
local flashFrame = createFrame{
    Size = UDim2.new(1,0,1,0),
    BackgroundColor3 = Color3.fromRGB(255,0,0),
    BackgroundTransparency = 1,
    Parent = gui
}

-- Toggle Button creator function
local function createToggleButton(text, y)
    local btn = createButton{
        Size = UDim2.new(0, 180, 0, 45),
        Position = UDim2.new(0, 20, 0, y),
        BackgroundColor3 = Color3.fromRGB(50, 50, 70),
        TextColor3 = Color3.fromRGB(220, 220, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        Text = text .. ": OFF",
        Parent = mainFrame,
    }
    return btn
end

-- Walkspeed slider creator function
local function createSlider(y)
    local frame = createFrame{
        Size = UDim2.new(0, 360, 0, 50),
        Position = UDim2.new(0, 20, 0, y),
        BackgroundColor3 = Color3.fromRGB(40, 40, 55),
        Parent = mainFrame,
    }
    local label = createTextLabel{
        Size = UDim2.new(0.3, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "WalkSpeed",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(170, 170, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    }
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0.65, 0, 0.6, 0)
    slider.Position = UDim2.new(0.35, 0, 0.2, 0)
    slider.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    slider.Text = ""
    slider.Parent = frame

    local fill = createFrame{
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 170, 255),
        Parent = slider,
    }

    return frame, slider, fill
end

-- Create toggles/buttons
local flyBtn = createToggleButton("Fly", 110)
local noclipBtn = createToggleButton("Noclip", 170)
local espBtn = createToggleButton("ESP", 230)

-- WalkSpeed slider UI
local wsFrame, wsSlider, wsFill = createSlider(290)
local wsLabel = wsFrame:FindFirstChildWhichIsA("TextLabel")
wsFill.Size = UDim2.new(walkspeed/maxWalkspeed, 0, 1, 0)
wsLabel.Text = "WalkSpeed: " .. walkspeed

-- Fly vars
local bv, bg

-- Fly function
local function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    flyTimer = 0
    toggles.Fly = true
    flyBtn.Text = "Fly: ON"

    humanoid.PlatformStand = true

    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = Vector3.new(0,0,0)

    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bg.CFrame = hrp.CFrame
end

local function stopFly()
    toggles.Fly = false
    flyBtn.Text = "Fly: OFF"
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = false end
end

-- Noclip function
local function setNoclip(on)
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not on
            end
        end
    end
end

-- ESP functions
local function createBox()
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(0,170,255)
    box.Thickness = 2
    box.Filled = false
    box.Visible = true
    return box
end

local function updateESP()
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
end

local function toggleESP(on)
    if on then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                espBoxes[plr] = createBox()
            end
        end
    else
        for _, box in pairs(espBoxes) do
            box:Remove()
        end
        espBoxes = {}
    end
end

-- Toggle button handlers
flyBtn.MouseButton1Click:Connect(function()
    if toggles.Fly then
        stopFly()
    else
        startFly()
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    toggles.Noclip = not toggles.Noclip
    noclipBtn.Text = "Noclip: " .. (toggles.Noclip and "ON" or "OFF")
    setNoclip(toggles.Noclip)
end)

espBtn.MouseButton1Click:Connect(function()
    toggles.ESP = not toggles.ESP
    espBtn.Text = "ESP: " .. (toggles.ESP and "ON" or "OFF")
    toggleESP(toggles.ESP)
end)

-- WalkSpeed slider logic
local dragging = false
wsSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
wsSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local relativeX = math.clamp(mousePos.X - wsSlider.AbsolutePosition.X, 0, wsSlider.AbsoluteSize.X)
        local percent = relativeX / wsSlider.AbsoluteSize.X
        walkspeed = math.floor(percent * maxWalkspeed)
        if walkspeed < 16 then walkspeed = 16 end -- minimum walkspeed
        wsFill.Size = UDim2.new(percent, 0, 1, 0)
        wsLabel.Text = "WalkSpeed: " .. walkspeed

        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = walkspeed
        end
    end
end)

-- Fly movement control + kick timer
RunService.RenderStepped:Connect(function(dt)
    -- Fly controls
    if toggles.Fly and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and bv and bg then
            local camCF = camera.CFrame
            local vel = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                vel = vel + camCF.LookVector * 50
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                vel = vel - camCF.LookVector * 50
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                vel = vel - camCF.RightVector * 50
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                vel = vel + camCF.RightVector * 50
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vel = vel + Vector3.new(0, 50, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vel = vel - Vector3.new(0, 50, 0)
            end

            bv.Velocity = vel
            bg.CFrame = camCF

            -- Increment fly timer and kick if over limit
            flyTimer = flyTimer + dt
            if flyTimer > flyKickTime then
                player:Kick("You have been kicked for flying too long! Cheat detected.")
            end
        end
    end

    -- ESP update
    if toggles.ESP then
        updateESP()
    end
end)

-- Scary troll effects (flashing red screen and sounds) when fly is toggled ON
local flashOn = false
RunService.Heartbeat:Connect(function()
    if toggles.Fly then
        flashFrame.BackgroundTransparency = flashFrame.BackgroundTransparency > 0.5 and 0 or 1
        alarmSound.Volume = 1
        staticSound.Volume = 0.5
        if not alarmSound.IsPlaying then alarmSound:Play() end
        if not staticSound.IsPlaying then staticSound:Play() end
    else
        flashFrame.BackgroundTransparency = 1
        alarmSound.Volume = 0
        staticSound.Volume = 0
        alarmSound:Stop()
        staticSound:Stop()
    end
end)

print("SparkHub loaded successfully.")
