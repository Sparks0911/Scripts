-- SparkHub v1.0 — InkGame-inspired UI with rainbow title, toggles, ESP, fly, noclip, infjump, walkspeed slider, minimize button

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

if getgenv().SparkHubLoaded then
    warn("SparkHub already loaded!")
    return
end
getgenv().SparkHubLoaded = true

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SparkHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Shadow background
local shadow = Instance.new("Frame", screenGui)
shadow.Size = UDim2.new(1,0,1,0)
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = 0.6
shadow.ZIndex = 0

-- Main Frame
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 320, 0, 400)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 1
local mainUICorner = Instance.new("UICorner", mainFrame)
mainUICorner.CornerRadius = UDim.new(0, 12)

-- Draggable function
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 44)
title.Position = UDim2.new(0, 0, 0, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.Text = "⚡SparkHub⚡"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.TextStrokeTransparency = 0.6
title.TextXAlignment = Enum.TextXAlignment.Center
title.ZIndex = 2

-- Rainbow title animation
spawn(function()
    while true do
        for i = 0, 1, 0.02 do
            title.TextColor3 = Color3.fromHSV(i, 1, 1)
            task.wait(0.03)
        end
    end
end)

-- Minimize Button
local minimizeBtn = Instance.new("TextButton", mainFrame)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -38, 0, 8)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.Text = "-"
minimizeBtn.AutoButtonColor = true
local minBtnUICorner = Instance.new("UICorner", minimizeBtn)
minBtnUICorner.CornerRadius = UDim.new(0, 6)

local minimized = false
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, -32, 1, -80)
contentFrame.Position = UDim2.new(0, 16, 0, 56)
contentFrame.BackgroundTransparency = 1

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 320, 0, 60)
        minimizeBtn.Text = "+"
    else
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 320, 0, 400)
        minimizeBtn.Text = "-"
    end
end)

-- UIListLayout for content
local listLayout = Instance.new("UIListLayout", contentFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 18)

-- Toggle button function
local function createToggle(text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 20
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center

    local toggled = false
    label.MouseEnter:Connect(function()
        label.TextColor3 = Color3.fromRGB(150, 150, 150)
    end)
    label.MouseLeave:Connect(function()
        label.TextColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(230, 230, 230)
    end)

    label.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggled = not toggled
            label.TextColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(230, 230, 230)
            callback(toggled)
        end
    end)

    return frame
end

-- Fly toggle
local flying = false
local bodyVelocity
local function setFly(on)
    flying = on
    if on then
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
        bodyVelocity = Instance.new("BodyVelocity", Character.HumanoidRootPart)
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        RunService:BindToRenderStep("FlyMovement", Enum.RenderPriority.Input.Value, function()
            if not flying then return end
            local moveDirection = Vector3.new()
            local camCFrame = workspace.CurrentCamera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camCFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camCFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camCFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camCFrame.RightVector
            end
            bodyVelocity.Velocity = moveDirection.Unit * 50
        end)
    else
        RunService:UnbindFromRenderStep("FlyMovement")
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
    end
end

-- Noclip toggle
local noclipOn = false
local noclipConnection
local function setNoclip(on)
    noclipOn = on
    if on then
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

-- ESP toggle
local espOn = false
local espBoxes = {}
local function createESPBox(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1

    espBoxes[player] = box
end

local function removeESPBoxes()
    for _, box in pairs(espBoxes) do
        if box then
            box:Remove()
        end
    end
    espBoxes = {}
end

local function setESP(on)
    espOn = on
    if on then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESPBox(player)
            end
        end
    else
        removeESPBoxes()
    end
end

-- ESP Update
RunService.RenderStepped:Connect(function()
    if not espOn then return end
    for player, box in pairs(espBoxes) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos, visible = Camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
            if visible then
                box.Visible = true
                box.Size = 40
                box.Position = Vector2.new(pos.X - 20, pos.Y - 20)
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)

-- Infinite Jump toggle
local infJumpConn
local function setInfJump(on)
    if on then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            if Humanoid and Humanoid.Health > 0 then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConn then
            infJumpConn:Disconnect()
            infJumpConn = nil
        end
    end
end

-- WalkSpeed slider
local sliderFrame = Instance.new("Frame", mainFrame)
sliderFrame.Size = UDim2.new(1, -32, 0, 60)
sliderFrame.Position = UDim2.new(0, 16, 1, -70)
sliderFrame.BackgroundTransparency = 1

local sliderLabel = Instance.new("TextLabel", sliderFrame)
sliderLabel.Size = UDim2.new(1, 0, 0, 24)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "WalkSpeed: 16"
sliderLabel.Font = Enum.Font.GothamSemibold
sliderLabel.TextSize = 20
sliderLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Position = UDim2.new(0, 0, 0, 0)

local sliderBar = Instance.new("Frame", sliderFrame)
sliderBar.Size = UDim2.new(1, 0, 0, 12)
sliderBar.Position = UDim2.new(0, 0, 0, 34)
sliderBar.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
sliderBar.ClipsDescendants = true
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 6)

local fillBar = Instance.new("Frame", sliderBar)
fillBar.Size = UDim2.new(0, 0, 1, 0)
fillBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
Instance.new("UICorner", fillBar).CornerRadius = UDim.new(0, 6)

local handle = Instance.new("ImageButton", sliderBar)
handle.Size = UDim2.new(0, 20, 0, 20)
handle.Position = UDim2.new(0, -10, 0.5, -10)
handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
handle.AutoButtonColor = false
Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)

local dragging = false
local minSpeed = 1
local maxSpeed = 250
local currentSpeed = 16

local function updateSlider(x)
    local relativeX = math.clamp(x - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
    local percent = relativeX / sliderBar.AbsoluteSize.X
    fillBar.Size = UDim2.new(percent, 0, 1, 0)
    handle.Position = UDim2.new(percent, -10, 0.5, -10)
    currentSpeed = math.floor(minSpeed + (maxSpeed - minSpeed) * percent)
    sliderLabel.Text = "WalkSpeed: "..currentSpeed
    if Humanoid and Humanoid.Parent then
        Humanoid.WalkSpeed = currentSpeed
    end
end

handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

handle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

sliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        updateSlider(input.Position.X)
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
        updateSlider(input.Position.X)
    end
end)

task.spawn(function()
    task.wait(0.1)
    local initX = sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X * ((currentSpeed - minSpeed) / (maxSpeed - minSpeed))
    updateSlider(initX)
end)

-- Add toggles to UI
contentFrame.Size = UDim2.new(1, -32, 1, -110)
contentFrame.Position = UDim2.new(0, 16, 0, 56)

local flyToggle = createToggle("Fly", setFly)
flyToggle.Parent = contentFrame
local noclipToggle = createToggle("Noclip", setNoclip)
noclipToggle.Parent = contentFrame
local espToggle = createToggle("ESP", setESP)
espToggle.Parent = contentFrame
local infJumpToggle = createToggle("Infinite Jump", setInfJump)
infJumpToggle.Parent = contentFrame
