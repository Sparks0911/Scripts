-- SparkHub v1.1 - GUI styled exactly like Rolo's video with Fly, Noclip, ESP, InfJump, WalkSpeed slider

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

if getgenv().SparkHubLoaded then return end
getgenv().SparkHubLoaded = true

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SparkHubGUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 420)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Parent = screenGui

local uICorner = Instance.new("UICorner", mainFrame)
uICorner.CornerRadius = UDim.new(0, 14)

-- Title Label
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 45)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.Text = "⚡SparkHub⚡"
title.TextColor3 = Color3.fromRGB(255, 120, 0)
title.TextStrokeTransparency = 0.6
title.TextXAlignment = Enum.TextXAlignment.Center

-- Draggable
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
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- UIListLayout for buttons
local buttonContainer = Instance.new("Frame", mainFrame)
buttonContainer.Size = UDim2.new(1, -32, 1, -100)
buttonContainer.Position = UDim2.new(0, 16, 0, 60)
buttonContainer.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", buttonContainer)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 18)

-- Function to create toggle buttons
local function createToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.AutoButtonColor = true
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 20
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Text = name
    btn.BorderSizePixel = 0
    btn.ClipsDescendants = true
    btn.Name = name .. "Toggle"
    local uicorner = Instance.new("UICorner", btn)
    uicorner.CornerRadius = UDim.new(0, 6)

    local toggled = false
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = toggled and Color3.fromRGB(60, 130, 60) or Color3.fromRGB(45, 45, 45)
    end)

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.BackgroundColor3 = toggled and Color3.fromRGB(60, 130, 60) or Color3.fromRGB(45, 45, 45)
        callback(toggled)
    end)

    btn.Parent = buttonContainer
    return btn
end

-- Fly toggle
local flying = false
local bodyVelocity
local function setFly(on)
    flying = on
    if on then
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
        bodyVelocity = Instance.new("BodyVelocity", Character.HumanoidRootPart)
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
            if moveDirection.Magnitude > 0 then
                bodyVelocity.Velocity = moveDirection.Unit * 50
            else
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
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
sliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Position = UDim2.new(0, 0, 0, 0)

local sliderBar = Instance.new("Frame", sliderFrame)
sliderBar.Size = UDim2.new(1, 0, 0, 12)
sliderBar.Position = UDim2.new(0, 0, 0, 34)
sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
sliderBar.ClipsDescendants = true
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 6)

local fillBar = Instance.new("Frame", sliderBar)
fillBar.Size = UDim2.new(0, 0, 1, 0)
fillBar.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
Instance.new("UICorner", fillBar).CornerRadius = UDim.new(0, 6)

local handle = Instance.new("ImageButton", sliderBar)
handle.Size = UDim2.new(0, 20, 0, 20)
handle.Position = UDim2.new(0, -10, 0.5, -10)
handle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
handle.AutoButtonColor = false
Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)

local draggingSlider = false
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
        draggingSlider = true
    end
end)

handle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

sliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        updateSlider(input.Position.X)
        draggingSlider = true
    end
end)

sliderBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

sliderBar.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSlider(input.Position.X)
    end
end)

-- Initialize slider fill and handle
task.spawn(function()
    task.wait(0.1)
    local initX = sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X * ((currentSpeed - minSpeed) / (maxSpeed - minSpeed))
    updateSlider(initX)
end)

-- Create toggles
createToggle("Fly", setFly)
createToggle("Noclip", setNoclip)
createToggle("ESP", setESP)
createToggle("Infinite Jump", setInfJump)
