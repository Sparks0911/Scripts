-- SparkHub V2 (No Troll/Kick) by Sparks0911
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("SparkHubV2")
if oldGui then oldGui:Destroy() end

local function new(class, properties)
    local obj = Instance.new(class)
    for k, v in pairs(properties) do
        obj[k] = v
    end
    return obj
end

local gui = new("ScreenGui", {
    Name = "SparkHubV2",
    ResetOnSpawn = false,
    Parent = playerGui,
})

-- Loading Screen (optional, you can remove if you want)
local loadingFrame = new("Frame", {
    Size = UDim2.new(1,0,1,0),
    BackgroundColor3 = Color3.fromRGB(20,20,30),
    Parent = gui,
})

local loadingText = new("TextLabel", {
    Text = "SparkHub Loading...",
    Font = Enum.Font.FredokaOne,
    TextSize = 36,
    TextColor3 = Color3.fromRGB(0, 170, 255),
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5,0,0.5,0),
    Parent = loadingFrame,
})

local loadingDots = 0
local loadingConnection
loadingConnection = RunService.Heartbeat:Connect(function()
    loadingDots = (loadingDots + 1) % 60
    local dots = string.rep(".", math.floor(loadingDots/15) + 1)
    loadingText.Text = "SparkHub Loading" .. dots
end)

task.delay(3, function()
    loadingConnection:Disconnect()
    loadingFrame:TweenSizeAndPosition(
        UDim2.new(0,0,0,0), -- shrink to nothing
        UDim2.new(0.5,0,0.5,0),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Quad,
        0.8,
        true,
        function()
            loadingFrame:Destroy()
        end
    )
end)

-- Main GUI
local mainFrame = new("Frame", {
    Size = UDim2.new(0, 420, 0, 480),
    Position = UDim2.new(0.5, -210, 0.5, -240),
    BackgroundColor3 = Color3.fromRGB(15,15,25),
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
    Parent = gui,
})

local header = new("TextLabel", {
    Text = "✨ SparkHub V2 ✨",
    Font = Enum.Font.FredokaOne,
    TextSize = 38,
    TextColor3 = Color3.fromRGB(0, 170, 255),
    BackgroundTransparency = 1,
    Size = UDim2.new(1,0,0,70),
    Parent = mainFrame,
})

local subtext = new("TextLabel", {
    Text = "Universal exploit script by Sparks0911",
    Font = Enum.Font.Gotham,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(120,120,140),
    BackgroundTransparency = 1,
    Position = UDim2.new(0,0,0,70),
    Size = UDim2.new(1,0,0,30),
    Parent = mainFrame,
})

local function createToggleBtn(name, posY)
    local btn = new("TextButton", {
        Size = UDim2.new(0, 190, 0, 50),
        Position = UDim2.new(0, 20, 0, posY),
        BackgroundColor3 = Color3.fromRGB(40, 40, 60),
        TextColor3 = Color3.fromRGB(230, 230, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        Text = name .. ": OFF",
        Parent = mainFrame,
    })
    return btn
end

local function createSlider(posY)
    local frame = new("Frame", {
        Size = UDim2.new(0, 380, 0, 60),
        Position = UDim2.new(0, 20, 0, posY),
        BackgroundColor3 = Color3.fromRGB(30, 30, 50),
        Parent = mainFrame,
    })
    local label = new("TextLabel", {
        Text = "WalkSpeed: 16",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(0, 170, 255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.02, 0, 0, 0),
        Size = UDim2.new(0.5, 0, 0, 60),
        Parent = frame,
    })
    local sliderBG = new("Frame", {
        Size = UDim2.new(0.45, 0, 0.3, 0),
        Position = UDim2.new(0.5, 0, 0.35, 0),
        BackgroundColor3 = Color3.fromRGB(60, 60, 90),
        Parent = frame,
        ClipsDescendants = true,
    })
    local sliderFill = new("Frame", {
        Size = UDim2.new(0.3, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 170, 255),
        Parent = sliderBG,
    })
    local sliderButton = new("ImageButton", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0.3, -9, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Image = "rbxassetid://3570695787",
        Parent = sliderBG,
        AutoButtonColor = false,
    })
    return frame, label, sliderBG, sliderFill, sliderButton
end

local flyBtn = createToggleBtn("Fly", 120)
local noclipBtn = createToggleBtn("Noclip", 190)
local espBtn = createToggleBtn("ESP", 260)

local wsFrame, wsLabel, wsBG, wsFill, wsBtn = createSlider(330)

local toggles = {
    Fly = false,
    Noclip = false,
    ESP = false,
}

local walkspeed = 16
local maxWalkspeed = 100

local bv, bg

local function setNoclip(on)
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not on
            end
        end
    end
end

local function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

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

local espBoxes = {}

local function createESPBox()
    local box = Drawing and Drawing.new and Drawing.new("Square") or nil
    if box then
        box.Color = Color3.fromRGB(0, 170, 255)
        box.Thickness = 2
        box.Filled = false
        box.Visible = false
    end
    return box
end

local function updateESP()
    for plr, box in pairs(espBoxes) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
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
                espBoxes[plr] = createESPBox()
            end
        end
    else
        for _, box in pairs(espBoxes) do
            if box and box.Visible ~= nil then
                box.Visible = false
                if box.Remove then pcall(box.Remove, box) end
            end
        end
        espBoxes = {}
    end
end

espBtn.MouseButton1Click:Connect(function()
    toggles.ESP = not toggles.ESP
    espBtn.Text = "ESP: " .. (toggles.ESP and "ON" or "OFF")
    toggleESP(toggles.ESP)
end)

local dragging = false
wsBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
wsBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local relativeX = math.clamp(mousePos.X - wsBG.AbsolutePosition.X, 0, wsBG.AbsoluteSize.X)
        local percent = relativeX / wsBG.AbsoluteSize.X
        walkspeed = math.floor(percent * maxWalkspeed)
        if walkspeed < 16 then walkspeed = 16 end
        wsFill.Size = UDim2.new(percent, 0, 1, 0)
        wsLabel.Text = "WalkSpeed: " .. walkspeed

        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = walkspeed
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if toggles.Fly and player.Character and bv and bg then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local camCF = Camera.CFrame
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
        end
    end

    if toggles.ESP then
        updateESP()
    end
end)

print("SparkHub V2 loaded — no kick/troll mode. Fly forever! 🚀")
