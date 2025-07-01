local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SparkHubUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

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
titleLabel.Text = "⚡Spark"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 26
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Position = UDim2.new(0, 0, 0, 8)

local function createToggle(name, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -32, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = mainFrame

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
    checkmark.Image = "rbxassetid://3926307971" -- checkmark image
    checkmark.ImageColor3 = Color3.fromRGB(0, 255, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Visible = default or false

    local toggled = default or false

    checkbox.MouseButton1Click:Connect(function()
        toggled = not toggled
        checkmark.Visible = toggled
        -- TODO: add toggle functionality here
    end)
end

-- Create toggles here, e.g.:
createToggle("Fly", false)
createToggle("Noclip", false)
createToggle("ESP", false)
createToggle("Infinite Jump", false)

-- WalkSpeed slider (basic version)
local sliderFrame = Instance.new("Frame")
sliderFrame.Parent = mainFrame
sliderFrame.Size = UDim2.new(1, -32, 0, 50)
sliderFrame.Position = UDim2.new(0, 16, 1, -70)
sliderFrame.BackgroundTransparency = 1

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Parent = sliderFrame
sliderLabel.Size = UDim2.new(1, 0, 0, 20)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "WalkSpeed: 16"
sliderLabel.Font = Enum.Font.GothamSemibold
sliderLabel.TextSize = 20
sliderLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Position = UDim2.new(0, 0, 0, 0)

local sliderBar = Instance.new("Frame")
sliderBar.Parent = sliderFrame
sliderBar.Size = UDim2.new(1, 0, 0, 10)
sliderBar.Position = UDim2.new(0, 0, 0, 30)
sliderBar.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
sliderBar.ClipsDescendants = true
local sliderCorner = Instance.new("UICorner")
sliderCorner.Parent = sliderBar

local fillBar = Instance.new("Frame")
fillBar.Parent = sliderBar
fillBar.Size = UDim2.new(0.5, 0, 1, 0) -- 50% fill default
fillBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
local fillCorner = Instance.new("UICorner")
fillCorner.Parent = fillBar

local handle = Instance.new("ImageButton")
handle.Parent = sliderBar
handle.Size = UDim2.new(0, 16, 0, 16)
handle.Position = UDim2.new(0.5, -8, 0.5, -8)
handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
handle.AutoButtonColor = false
handle.Name = "Handle"
local handleCorner = Instance.new("UICorner")
handleCorner.Parent = handle
handleCorner.CornerRadius = UDim.new(1, 0)

local dragging = false
local walkSpeed = 16
local minSpeed = 16
local maxSpeed = 250

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

local function updateSlider(x)
    local relativeX = math.clamp(x - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
    local percent = relativeX / sliderBar.AbsoluteSize.X
    fillBar.Size = UDim2.new(percent, 0, 1, 0)
    handle.Position = UDim2.new(percent, -8, 0.5, -8)
    walkSpeed = math.floor(minSpeed + (maxSpeed - minSpeed) * percent)
    sliderLabel.Text = "WalkSpeed: " .. walkSpeed
    -- Apply the walk speed immediately
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = walkSpeed
    end
end

sliderBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSlider(input.Position.X)
    end
end)

sliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        updateSlider(input.Position.X)
    end
end)
