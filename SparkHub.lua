local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if getgenv().SparkHubLoaded then return end
getgenv().SparkHubLoaded = true

local function createGUI()
    -- Remove old GUI if any
    local oldGui = LocalPlayer.PlayerGui:FindFirstChild("SparkHubGUI")
    if oldGui then oldGui:Destroy() end
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local camera = workspace.CurrentCamera

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SparkHubGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 360, 0, 460)
    mainFrame.Position = UDim2.new(0.5, -180, 0.5, -230)
    mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    mainFrame.BorderSizePixel = 0
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Parent = screenGui

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 32
    title.Text = "⚡SparkHub⚡"
    title.TextColor3 = Color3.fromRGB(255, 0, 0)
    title.TextStrokeTransparency = 0.6
    title.TextXAlignment = Enum.TextXAlignment.Center

    local hue = 0
    RunService.RenderStepped:Connect(function()
        if not title or not title.Parent then return end
        hue = (hue + 1) % 360
        title.TextColor3 = Color3.fromHSV(hue / 360, 1, 1)
    end)

    -- Dragging
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

    local container = Instance.new("Frame", mainFrame)
    container.Size = UDim2.new(1, -40, 1, -120)
    container.Position = UDim2.new(0, 20, 0, 60)
    container.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", container)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 18)

    local function createToggle(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.AutoButtonColor = false
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 22
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Text = name
        btn.BorderSizePixel = 0
        btn.ClipsDescendants = true
        btn.Name = name .. "Toggle"
        local uicorner = Instance.new("UICorner", btn)
        uicorner.CornerRadius = UDim.new(0, 8)

        local toggled = false
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = toggled and Color3.fromRGB(60, 130, 60) or Color3.fromRGB(45, 45, 45)
        end)

        btn.MouseButton1Click:Connect(function()
            toggled = not toggled
            btn.BackgroundColor3 = toggled and Color3.fromRGB(60, 130, 60) or Color3.fromRGB(45, 45, 45)
            callback(toggled)
        end)

        btn.Parent = container
        return btn
    end

    -- Fly
    local flying = false
    local bodyVelocity
    local function setFly(on)
        flying = on
        if on then
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            bodyVelocity = Instance.new("BodyVelocity", character.HumanoidRootPart)
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

    -- Noclip
    local noclipOn = false
    local noclipConnection
    local function setNoclip(on)
        noclipOn = on
        if on then
            noclipConnection = RunService.Stepped:Connect(function()
                for _, part in pairs(character:GetDescendants()) do
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

    -- Infinite Jump
    local infJumpConn
    local function setInfJump(on)
        if on then
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                if humanoid and humanoid.Health > 0 then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if infJumpConn then
                infJumpConn:Disconnect()
                infJumpConn = nil
            end
        end
    end

    -- ESP with Highlight outlines
    local espOn = false
    local highlights = {}

    local function createHighlight(player)
        if highlights[player] then return end
        local highlight = Instance.new("Highlight")
        highlight.Adornee = nil
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineTransparency = 0
        highlight.Parent = workspace
        highlights[player] = highlight
    end

    local function removeHighlights()
        for _, highlight in pairs(highlights) do
            highlight:Destroy()
        end
        highlights = {}
    end

    local function setESP(on)
        espOn = on
        if on then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    createHighlight(player)
                end
            end
        else
            removeHighlights()
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if espOn and player ~= LocalPlayer then
            createHighlight(player)
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not espOn then return end
        for player, highlight in pairs(highlights) do
            local char = player.Character
            if char and char.Parent then
                highlight.Adornee = char
                highlight.Enabled = true
            else
                highlight.Adornee = nil
                highlight.Enabled = false
            end
        end
    end)

    -- WalkSpeed slider
    local sliderFrame = Instance.new("Frame", mainFrame)
    sliderFrame.Size = UDim2.new(1, -40, 0, 60)
    sliderFrame.Position = UDim2.new(0, 20, 1, -80)
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
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = currentSpeed
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

    task.spawn(function()
        task.wait(0.1)
        local initX = sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X * ((currentSpeed - minSpeed) / (maxSpeed - minSpeed))
        updateSlider(initX)
    end)

    -- Aimbot toggle and logic
    local aimbotOn = false
    local aimbotFOV = 60
    local aimbotSmoothness = 0.15

    local function getNearestTarget()
        local nearestPlayer = nil
        local nearestDistance = math.huge
        local camCFrame = workspace.CurrentCamera.CFrame
        local camPos = camCFrame.Position

        local localTeam = LocalPlayer.Team

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                -- Ignore teammates
                if localTeam and player.Team == localTeam then
                    continue
                end

                local head = player.Character.Head
                local direction = (head.Position - camPos).Unit
                local dot = camCFrame.LookVector:Dot(direction)
                local angle = math.acos(dot) * (180 / math.pi)

                if angle < aimbotFOV then
                    local dist = (head.Position - camPos).Magnitude
                    if dist < nearestDistance then
                        nearestDistance = dist
                        nearestPlayer = player
                    end
                end
            end
        end
        return nearestPlayer
    end

    RunService.RenderStepped:Connect(function()
        if aimbotOn then
            local target = getNearestTarget()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local headPos = target.Character.Head.Position
                local cam = workspace.CurrentCamera
                local camPos = cam.CFrame.Position

                local lookVector = (headPos - camPos).Unit
                local targetCFrame = CFrame.new(camPos, camPos + lookVector)
                cam.CFrame = cam.CFrame:Lerp(targetCFrame, aimbotSmoothness)
            end
        end
    end)

    createToggle("Fly", setFly)
    createToggle("Noclip", setNoclip)
    createToggle("ESP", setESP)
    createToggle("Infinite Jump", setInfJump)
    createToggle("Aimbot", function(on) aimbotOn = on end)
end

createGUI()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    createGUI()
end)
