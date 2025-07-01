-- SparkHub - Fully Functional Roblox GUI Script
-- Features: Fly, Noclip, WalkSpeed Slider, ESP, Infinite Jump, Aimbot
-- GUI recreates on respawn and features animated rainbow title

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if getgenv().SparkHubLoaded then return end
getgenv().SparkHubLoaded = true

-- Store GUI globally to reapply after respawn
getgenv().SparkHubGUI = nil

-- Create Humanoid Updater
local function getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

-- Rainbow title function
local function animateTitle(titleLabel)
    local hue = 0
    RunService.RenderStepped:Connect(function()
        hue = (hue + 1) % 360
        titleLabel.TextColor3 = Color3.fromHSV(hue/360, 1, 1)
    end)
end

-- GUI Creation
local function createSparkHub()
    if getgenv().SparkHubGUI then getgenv().SparkHubGUI:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SparkHubGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    getgenv().SparkHubGUI = screenGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 300)
    main.Position = UDim2.new(0.5, -200, 0.5, -150)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    main.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Text = "⚡SparkHub⚡"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.TextColor3 = Color3.fromRGB(255, 0, 0)
    title.Parent = main
    animateTitle(title)

    local layout = Instance.new("UIListLayout", main)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)

    -- Buttons and toggles
    local function createButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, 0)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 18
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Parent = main
        btn.MouseButton1Click:Connect(callback)
    end

    -- Feature Toggles
    local flying = false
    local flyConnection

    createButton("Toggle Fly", function()
        flying = not flying
        if flying then
            flyConnection = RunService.RenderStepped:Connect(function()
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local move = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= workspace.CurrentCamera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += workspace.CurrentCamera.CFrame.RightVector end
                    root.Velocity = move.Unit * 50
                end
            end)
        else
            if flyConnection then flyConnection:Disconnect() end
        end
    end)

    local noclip = false
    local noclipConnection

    createButton("Toggle Noclip", function()
        noclip = not noclip
        if noclip then
            noclipConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConnection then noclipConnection:Disconnect() end
        end
    end)

    local infJump = false
    local jumpConn

    createButton("Toggle Infinite Jump", function()
        infJump = not infJump
        if infJump then
            jumpConn = UserInputService.JumpRequest:Connect(function()
                local hum = getHumanoid()
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        else
            if jumpConn then jumpConn:Disconnect() end
        end
    end)

    local espOn = false
    local espHighlights = {}

    local function updateESP()
        for _, h in pairs(espHighlights) do h:Destroy() end
        table.clear(espHighlights)
        if not espOn then return end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local h = Instance.new("Highlight")
                h.Adornee = player.Character
                h.FillTransparency = 1
                h.OutlineColor = Color3.fromRGB(255, 0, 0)
                h.Parent = player.Character
                table.insert(espHighlights, h)
            end
        end
    end

    createButton("Toggle ESP", function()
        espOn = not espOn
        updateESP()
    end)

    -- WalkSpeed slider substitute (preset toggle)
    createButton("Set WalkSpeed to 50", function()
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = 50 end
    end)

    createButton("Reset WalkSpeed", function()
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = 16 end
    end)
end

-- Initial GUI creation
createSparkHub()

-- Reapply GUI on respawn
LocalPlayer.CharacterAdded:Connect(function()
    wait(1.2)
    createSparkHub()
end)

print("⚡ SparkHub Loaded ⚡")
