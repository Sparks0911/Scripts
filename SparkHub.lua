-- SparkHub vFinal: Clean UI with loading text, toggles, and draggable WalkSpeed slider
-- By Sparks0911

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Prevent multiple instances
if getgenv().SparkHubLoaded then
    warn("SparkHub already loaded!")
    return
end
getgenv().SparkHubLoaded = true

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SparkHubUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Loading Text
local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(0, 250, 0, 50)
loadingLabel.Position = UDim2.new(0.5, -125, 0.5, -25)
loadingLabel.BackgroundColor3 = Color3.fromRGB(18,18,18)
loadingLabel.BorderSizePixel = 0
loadingLabel.TextColor3 = Color3.fromRGB(255,255,255)
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.TextSize = 24
loadingLabel.Text = "SparkHub is loading..."
loadingLabel.TextWrapped = true
loadingLabel.TextXAlignment = Enum.TextXAlignment.Center
loadingLabel.TextYAlignment = Enum.TextYAlignment.Center
loadingLabel.Parent = screenGui
loadingLabel.BackgroundTransparency = 0
local corner = Instance.new("UICorner", loadingLabel)
corner.CornerRadius = UDim.new(0,12)

-- Wait 2 seconds then remove loading
task.delay(2, function()
    loadingLabel:Destroy()
    buildUI()
end)

-- UI Builder function
function buildUI()
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 12)
    uicorner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = mainFrame
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "SparkHub"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 28
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Position = UDim2.new(0, 0, 0, 8)

    local contentFrame = Instance.new("Frame")
    contentFrame.Parent = mainFrame
    contentFrame.Size = UDim2.new(1, -32, 1, -100)
    contentFrame.Position = UDim2.new(0, 16, 0, 56)
    contentFrame.BackgroundTransparency = 1

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = contentFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 18)

    -- Toggle creator
    local function createToggle(name, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundTransparency = 1
        frame.Parent = contentFrame
        frame.LayoutOrder = #contentFrame:GetChildren()

        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(1, -40, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 20
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0, 8, 0, 0)

        local checkbox = Instance.new("TextButton")
        checkbox.Parent = frame
        checkbox.Size = UDim2.new(0, 28, 0, 28)
        checkbox.Position = UDim2.new(1, -28, 0.5, -14)
        checkbox.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        checkbox.AutoButtonColor = false
        checkbox.Text = ""
        checkbox.BorderSizePixel = 0

        local corner = Instance.new("UICorner")
        corner.Parent = checkbox

        local checkmark = Instance.new("ImageLabel")
        checkmark.Parent = checkbox
        checkmark.Size = UDim2.new(0.7, 0, 0.7, 0)
        checkmark.Position = UDim2.new(0.15, 0, 0.15, 0)
        checkmark.Image = "rbxassetid://3926307971"
        checkmark.ImageColor3 = Color3.fromRGB(0, 255, 0)
        checkmark.BackgroundTransparency = 1
        checkmark.Visible = default or false

        local toggled = default or false

        checkbox.MouseButton1Click:Connect(function()
            toggled = not toggled
            checkmark.Visible = toggled
            if callback then
                callback(toggled)
            end
        end)

        return frame
    end

    -- Example toggles:
    local flyToggle = createToggle("Fly", false, function(on)
        if on then
            -- Fly logic here
        else
            -- Disable fly
        end
    end)

    local noclipToggle = createToggle("Noclip", false, function(on)
        if on then
            -- Noclip logic here
        else
            -- Disable noclip
        end
    end)

    local espToggle = createToggle("ESP", false, function(on)
        if on then
            -- ESP logic here
        else
            -- Disable ESP
        end
    end)

    local infJumpToggle = createToggle("Infinite Jump", false, function(on)
        if on then
            -- Infinite jump logic here
        else
            -- Disable infinite jump
        end
    end)

    -- WalkSpeed slider frame
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Parent = mainFrame
    sliderFrame.Size = UDim2.new(1, -32, 0, 60)
    sliderFrame.Position = UDim2.new(0, 16, 1, -70)
    sliderFrame.BackgroundTransparency = 1

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Parent = sliderFrame
    sliderLabel.Size = UDim2.new(1, 0, 0, 24)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = "WalkSpeed: 16"
    sliderLabel.Font = Enum.Font.GothamSemibold
    sliderLabel.TextSize = 20
    sliderLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)

    local sliderBar = Instance.new("Frame")
    sliderBar.Parent = sliderFrame
    sliderBar.Size = UDim2.new(1, 0, 0, 12)
    sliderBar.Position = UDim2.new(0, 0, 0, 34)
    sliderBar.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    sliderBar.ClipsDescendants = true
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.Parent = sliderBar

    local fillBar = Instance.new("Frame")
    fillBar.Parent = sliderBar
    fillBar.Size = UDim2.new(0, 0, 1, 0) -- start empty
    fillBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    local fillCorner = Instance.new("UICorner")
    fillCorner.Parent = fillBar

    local handle = Instance.new("ImageButton")
    handle.Parent = sliderBar
    handle.Size = UDim2.new(0, 20, 0, 20)
    handle.Position = UDim2.new(0, -10, 0.5, -10)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.AutoButtonColor = false
    handle.Name = "Handle"
    local handleCorner = Instance.new("UICorner")
    handleCorner.Parent = handle
    handleCorner.CornerRadius = UDim.new(1, 0)

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

        -- Apply WalkSpeed live
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

    -- Initialize slider at default speed 16
    task.spawn(function()
        task.wait(0.1)
        updateSlider(sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X * ((16 - minSpeed)/(maxSpeed - minSpeed)))
    end)
end
