-- SparkHub Final v2
-- Clean UI, loading text, toggles, draggable WalkSpeed slider (1-250)
-- By Sparks0911

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

if getgenv().SparkHubLoaded then
    warn("SparkHub already loaded!")
    return
end
getgenv().SparkHubLoaded = true

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SparkHubUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Loading label
local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(0, 280, 0, 50)
loadingLabel.Position = UDim2.new(0.5, -140, 0.5, -25)
loadingLabel.BackgroundColor3 = Color3.fromRGB(18,18,18)
loadingLabel.BorderSizePixel = 0
loadingLabel.TextColor3 = Color3.fromRGB(255,255,255)
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.TextSize = 26
loadingLabel.Text = "SparkHub is loading..."
loadingLabel.TextWrapped = true
loadingLabel.TextXAlignment = Enum.TextXAlignment.Center
loadingLabel.TextYAlignment = Enum.TextYAlignment.Center
loadingLabel.Parent = screenGui
local uic = Instance.new("UICorner", loadingLabel)
uic.CornerRadius = UDim.new(0,12)

task.delay(2, function()
    loadingLabel:Destroy()
    buildUI()
end)

function buildUI()
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)

    -- Title
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "SparkHub"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Position = UDim2.new(0, 0, 0, 8)

    -- Content frame for toggles + slider
    local contentFrame = Instance.new("Frame")
    contentFrame.Parent = mainFrame
    contentFrame.Size = UDim2.new(1, -32, 1, -100)
    contentFrame.Position = UDim2.new(0, 16, 0, 56)
    contentFrame.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout")
    layout.Parent = contentFrame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 18)

    -- Toggle creator helper
    local function createToggle(name, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundTransparency = 1
        frame.Parent = contentFrame
        frame.LayoutOrder = #contentFrame:GetChildren() + 1

        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(1, -40, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 20
        label.TextColor3 = Color3.fromRGB(230,230,230)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0, 8, 0, 0)

        local checkbox = Instance.new("TextButton")
        checkbox.Parent = frame
        checkbox.Size = UDim2.new(0, 28, 0, 28)
        checkbox.Position = UDim2.new(1, -28, 0.5, -14)
        checkbox.BackgroundColor3 = Color3.fromRGB(38,38,38)
        checkbox.AutoButtonColor = false
        checkbox.Text = ""
        checkbox.BorderSizePixel = 0
        Instance.new("UICorner", checkbox).CornerRadius = UDim.new(0,6)

        local checkmark = Instance.new("ImageLabel")
        checkmark.Parent = checkbox
        checkmark.Size = UDim2.new(0.7, 0, 0.7, 0)
        checkmark.Position = UDim2.new(0.15, 0, 0.15, 0)
        checkmark.Image = "rbxassetid://3926307971"
        checkmark.ImageColor3 = Color3.fromRGB(0,255,0)
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

    -- Create toggles and dummy callbacks:
    createToggle("Fly", false, function(on)
        print("Fly toggled", on)
        -- Put fly code here
    end)

    createToggle("Noclip", false, function(on)
        print("Noclip toggled", on)
        -- Put noclip code here
    end)

    createToggle("ESP", false, function(on)
        print("ESP toggled", on)
        -- Put ESP code here
    end)

    createToggle("Infinite Jump", false, function(on)
        print("Infinite Jump toggled", on)
        -- Put infinite jump code here
    end)

    -- WalkSpeed Slider frame
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
    sliderLabel.TextColor3 = Color3.fromRGB(230,230,230)
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)

    local sliderBar = Instance.new("Frame")
    sliderBar.Parent = sliderFrame
    sliderBar.Size = UDim2.new(1, 0, 0, 12)
    sliderBar.Position = UDim2.new(0, 0, 0, 34)
    sliderBar.BackgroundColor3 = Color3.fromRGB(38,38,38)
    sliderBar.ClipsDescendants = true
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 6)

    local fillBar = Instance.new("Frame")
    fillBar.Parent = sliderBar
    fillBar.Size = UDim2.new(0, 0, 1, 0) -- Start empty
    fillBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    Instance.new("UICorner", fillBar).CornerRadius = UDim.new(0, 6)

    local handle = Instance.new("ImageButton")
    handle.Parent = sliderBar
    handle.Size = UDim2.new(0, 20, 0, 20)
    handle.Position = UDim2.new(0, -10, 0.5, -10)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.AutoButtonColor = false
    handle.Name = "Handle"
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

        -- Apply live WalkSpeed
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

    -- Initialize slider at default 16
    task.spawn(function()
        task.wait(0.1)
        local initX = sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X * ((16 - minSpeed) / (maxSpeed - minSpeed))
        updateSlider(initX)
    end)
end
