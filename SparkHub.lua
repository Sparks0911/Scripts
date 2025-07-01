-- SparkHub v2.0 - Smooth Aimbot + Persistent Toggles
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

if getgenv().SparkHubLoaded then return end
getgenv().SparkHubLoaded = true

local toggles = {
    fly = false,
    noclip = false,
    infJump = false,
    esp = false,
    aimbot = false,
    walkspeed = 16,
}

local GUI = nil

local function getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local function animateTitle(label)
    local hue = 0
    RunService.RenderStepped:Connect(function()
        hue = (hue + 1) % 360
        label.TextColor3 = Color3.fromHSV(hue / 360, 1, 1)
    end)
end

local espHighlights = {}

local function updateESP()
    for _, h in pairs(espHighlights) do
        h:Destroy()
    end
    espHighlights = {}
    if not toggles.esp then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = player.Character
            highlight.FillTransparency = 1
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            highlight.Parent = player.Character
            table.insert(espHighlights, highlight)
        end
    end
end

local flyConnection
local function enableFly()
    flyConnection = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        root.Velocity = move.Unit * 50
    end)
end
local function disableFly()
    if flyConnection then flyConnection:Disconnect() end
end

local noclipConnection
local function enableNoclip()
    noclipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end
local function disableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
end

local infJumpConn
local function enableInfJump()
    infJumpConn = UserInputService.JumpRequest:Connect(function()
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end
local function disableInfJump()
    if infJumpConn then infJumpConn:Disconnect() end
end

local aimbotConnection
local function getClosestEnemy()
    local closestDist = math.huge
    local closestPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Team ~= LocalPlayer.Team then
            local root = player.Character.HumanoidRootPart
            local dist = (root.Position - Camera.CFrame.Position).magnitude
            if dist < closestDist then
                closestDist = dist
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end
local function enableAimbot()
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not toggles.aimbot then return end
        local targetPlayer = getClosestEnemy()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local head = targetPlayer.Character.Head
            local camPos = Camera.CFrame.Position
            local desired = CFrame.new(camPos, head.Position)
            Camera.CFrame = Camera.CFrame:Lerp(desired, 0.2)
        end
    end)
end
local function disableAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
end

local function setWalkSpeed(speed)
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = speed
        toggles.walkspeed = speed
    end
end

local function createGUI()
    if GUI then GUI:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SparkHubGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    GUI = screenGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 420, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    mainFrame.Active = true
    mainFrame.Draggable = true

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "⚡SparkHub⚡"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.Parent = mainFrame
    animateTitle(title)

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = mainFrame
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 8)

    local function createToggle(name, state, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 36)
        frame.BackgroundTransparency = 1
        frame.LayoutOrder = 1
        frame.Parent = mainFrame

        local label = Instance.new("TextLabel")
        label.Text = name
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 18
        label.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 70, 0, 25)
        toggle.Position = UDim2.new(0.75, 0, 0.15, 0)
        toggle.BackgroundColor3 = state and Color3.fromRGB(0,170,255) or Color3.fromRGB(70,70,70)
        toggle.TextColor3 = Color3.fromRGB(255,255,255)
        toggle.Font = Enum.Font.GothamSemibold
        toggle.TextSize = 18
        toggle.Text = state and "ON" or "OFF"
        toggle.Parent = frame

        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(0,170,255) or Color3.fromRGB(70,70,70)
            toggle.Text = state and "ON" or "OFF"
            callback(state)
        end)
    end

    createToggle("Fly", toggles.fly, function(val)
        toggles.fly = val
        if val then enableFly() else disableFly() end
    end)

    createToggle("Noclip", toggles.noclip, function(val)
        toggles.noclip = val
        if val then enableNoclip() else disableNoclip() end
    end)

    createToggle("Infinite Jump", toggles.infJump, function(val)
        toggles.infJump = val
        if val then enableInfJump() else disableInfJump() end
    end)

    createToggle("ESP", toggles.esp, function(val)
        toggles.esp = val
        updateESP()
    end)

    createToggle("Aimbot", toggles.aimbot, function(val)
        toggles.aimbot = val
        if val then enableAimbot() else disableAimbot() end
    end)

    local wsFrame = Instance.new("Frame")
    wsFrame.Size = UDim2.new(1, -20, 0, 50)
    wsFrame.BackgroundTransparency = 1
    wsFrame.LayoutOrder = 1
    wsFrame.Parent = mainFrame

    local wsLabel = Instance.new("TextLabel")
    wsLabel.Text = "WalkSpeed: " .. tostring(toggles.walkspeed)
    wsLabel.Size = UDim2.new(0.5, 0, 1, 0)
    wsLabel.BackgroundTransparency = 1
    wsLabel.TextColor3 = Color3.fromRGB(255,255,255)
    wsLabel.TextXAlignment = Enum.TextXAlignment.Left
    wsLabel.Font = Enum.Font.GothamSemibold
    wsLabel.TextSize = 18
    wsLabel.Parent = wsFrame

    local wsSlider = Instance.new("TextButton")
    wsSlider.Size = UDim2.new(0.45, 0, 0.5, 0)
    wsSlider.Position = UDim2.new(0.5, 0, 0.25, 0)
    wsSlider.BackgroundColor3 = Color3.fromRGB(70,70,70)
    wsSlider.Text = ""
    wsSlider.Parent = wsFrame

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
    wsSlider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = math.clamp(input.Position.X - wsSlider.AbsolutePosition.X, 0, wsSlider.AbsoluteSize.X)
            local percent = mouseX / wsSlider.AbsoluteSize.X
            local speed = math.floor(1 + percent * 249)
            setWalkSpeed(speed)
            wsLabel.Text = "WalkSpeed: " .. speed
        end
    end)

    setWalkSpeed(toggles.walkspeed)
end

createGUI()

LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    createGUI()
    if toggles.fly then enableFly() end
    if toggles.noclip then enableNoclip() end
    if toggles.infJump then enableInfJump() end
    if toggles.esp then updateESP() end
    if toggles.aimbot then enableAimbot() end
    setWalkSpeed(toggles.walkspeed)
end)

print("⚡ SparkHub Loaded ⚡")
