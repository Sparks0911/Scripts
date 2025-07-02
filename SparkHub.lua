-- SparkHub Universal Script
-- Multi-tab cheat UI with working Player, Combat, Visuals, Misc and Emergency tabs
-- No Rayfield branding visible; smooth, clean, and universal

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local Camera = workspace.CurrentCamera

-- Create Window with minimal loading texts (no Rayfield)
local Window = Rayfield:CreateWindow({
    Name = "⚡SparkHub⚡",
    LoadingTitle = "",
    LoadingSubtitle = "",
    ShowText = "",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SparkHubConfig",
        FileName = "Config"
    }
})

---------------- PLAYER TAB ----------------
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- WalkSpeed Slider
local walkSpeed = 16
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = walkSpeed,
    Flag = "WalkSpeedSlider",
    Callback = function(value)
        walkSpeed = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = walkSpeed
        end
    end
})

-- JumpPower Slider
local jumpPower = 50
PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 5,
    Suffix = "Jump",
    CurrentValue = jumpPower,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        jumpPower = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = jumpPower
        end
    end
})

-- Fly Toggle (WASD style fly)
local flyEnabled = false
local flySpeed = 50
local flyBodyGyro
local flyBodyVelocity
local flyingChar

local function enableFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    flyingChar = char

    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.PlatformStand = true

    flyBodyGyro = Instance.new("BodyGyro", hrp)
    flyBodyGyro.P = 9e4
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.CFrame = hrp.CFrame

    flyBodyVelocity = Instance.new("BodyVelocity", hrp)
    flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVelocity.Velocity = Vector3.new(0,0,0)

    RunService:BindToRenderStep("Fly", Enum.RenderPriority.Character.Value, function()
        if not flyEnabled or not flyingChar then
            RunService:UnbindFromRenderStep("Fly")
            return
        end
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction += Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction -= Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction -= Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction += Camera.CFrame.RightVector
        end
        if direction.Magnitude > 0 then
            flyBodyVelocity.Velocity = direction.Unit * flySpeed
        else
            flyBodyVelocity.Velocity = Vector3.new(0,0,0)
        end
        flyBodyGyro.CFrame = Camera.CFrame
    end)
end

local function disableFly()
    if flyingChar then
        local humanoid = flyingChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    RunService:UnbindFromRenderStep("Fly")
end

PlayerTab:CreateToggle({
    Name = "Fly (WASD)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(value)
        flyEnabled = value
        if flyEnabled then
            enableFly()
        else
            disableFly()
        end
    end
})

-- Noclip toggle (simple)
local noclipEnabled = false
RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(value)
        noclipEnabled = value
    end
})

-- Infinite Jump toggle
local infJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(value)
        infJumpEnabled = value
    end
})

-- Teleport to Mouse button
PlayerTab:CreateButton({
    Name = "Teleport to Mouse",
    Callback = function()
        local mousePos = UserInputService:GetMouseLocation()
        local ray = workspace.CurrentCamera:ScreenPointToRay(mousePos.X, mousePos.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

        local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 5000, raycastParams)
        if raycastResult and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
        end
    end
})

-- Teleport to Random Player button
PlayerTab:CreateButton({
    Name = "Teleport to Random Player",
    Callback = function()
        local players = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(players, plr)
            end
        end
        if #players == 0 then return end
        local randomPlayer = players[math.random(1, #players)]
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
        end
    end
})

-- Reset WalkSpeed and JumpPower buttons
PlayerTab:CreateButton({
    Name = "Reset WalkSpeed",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
        end
    end
})

PlayerTab:CreateButton({
    Name = "Reset JumpPower",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = 50
        end
    end
})

---------------- COMBAT TAB ----------------
local CombatTab = Window:CreateTab("Combat", 4483362458)

-- Aimbot variables
local aimbotEnabled = false
local aimSensitivity = 0.35

local function getClosestEnemyToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mouseLocation = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            if char and char:FindFirstChild("Head") then
                local pos, visible = Camera:WorldToViewportPoint(char.Head.Position)
                if visible then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouseLocation.X, mouseLocation.Y)).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestEnemyToCursor()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPos = target.Character.Head.Position
            local currentCFrame = Camera.CFrame
            local desiredCFrame = CFrame.new(currentCFrame.Position, targetPos)
            Camera.CFrame = currentCFrame:Lerp(desiredCFrame, aimSensitivity)
        end
    end
end)

CombatTab:CreateToggle({
    Name = "Aimbot (Head Lock)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(value)
        aimbotEnabled = value
    end
})

-- ESP variables
local espBodyEnabled = false
local espNameEnabled = false
local espDistanceEnabled = false
local espBoxes = {}
local espNames = {}

-- Helper function to create box adornment on a part
local function createBox(part)
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = part
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Transparency = 0.5
    box.Color3 = Color3.new(1, 0, 0)
    box.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
    box.Parent = part
    return box
end

-- Helper function to create BillboardGui name tag
local function createNameTag(char, player)
    local head = char:FindFirstChild("Head")
    if not head then return nil end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SparkHubNameTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 0, 0)
    textLabel.TextStrokeColor3 = Color3.new(0,0,0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.ArialBold
    textLabel.Text = player.Name
    textLabel.Parent = billboard

    return billboard
end

local function updateESP()
    -- Remove ESP for players who left or toggled off
    for char, boxList in pairs(espBoxes) do
        if not char.Parent or not espBodyEnabled then
            for _, box in pairs(boxList) do
                if box and box.Parent then
                    box:Destroy()
                end
            end
            espBoxes[char] = nil
        end
    end
    for char, nameTag in pairs(espNames) do
        if not char.Parent or not espNameEnabled then
            if nameTag and nameTag.Parent then
                nameTag:Destroy()
            end
            espNames[char] = nil
        end
    end

    if not espBodyEnabled and not espNameEnabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
            local char = player.Character

            -- Body ESP
            if espBodyEnabled then
                if not espBoxes[char] then
                    espBoxes[char] = {}
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            local box = createBox(part)
                            table.insert(espBoxes[char], box)
                        end
                    end
                end
            else
                -- Remove if turned off
                if espBoxes[char] then
                    for _, box in pairs(espBoxes[char]) do
                        if box and box.Parent then
                            box:Destroy()
                        end
                    end
                    espBoxes[char] = nil
                end
            end

            -- Name ESP
            if espNameEnabled then
                if not espNames[char] then
                    local nameTag = createNameTag(char, player)
                    espNames[char] = nameTag
                end
            else
                if espNames[char] then
                    if espNames[char] and espNames[char].Parent then
                        espNames[char]:Destroy()
                    end
                    espNames[char] = nil
                end
            end
        end
    end
end

CombatTab:CreateToggle({
    Name = "ESP (Body Boxes)",
    CurrentValue = false,
    Flag = "ESPBodyToggle",
    Callback = function(value)
        espBodyEnabled = value
        if not espBodyEnabled then
            -- Cleanup all boxes
            for char, boxList in pairs(espBoxes) do
                for _, box in pairs(boxList) do
                    if box and box.Parent then
                        box:Destroy()
                    end
                end
                espBoxes[char] = nil
            end
        end
    end
})

CombatTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Flag = "ESPNameToggle",
    Callback = function(value)
        espNameEnabled = value
        if not espNameEnabled then
            -- Cleanup all name tags
            for char, nameTag in pairs(espNames) do
                if nameTag and nameTag.Parent then
                    nameTag:Destroy()
                end
            end
            espNames = {}
        end
    end
})

-- Update ESP every half second
RunService.Heartbeat:Connect(function()
    updateESP()
end)

---------------- VISUALS TAB ----------------
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- Fullbright toggle
local originalBrightness = Lighting.Brightness
local fullbrightEnabled = false

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "FullbrightToggle",
    Callback = function(value)
        fullbrightEnabled = value
        if fullbrightEnabled then
            Lighting.Brightness = 2
            Lighting.FogEnd = 1e9
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.OutdoorAmbient = Color3.new(1,1,1)
        else
            Lighting.Brightness = originalBrightness
            Lighting.FogEnd = 1000
            Lighting.Ambient = Color3.new(0.5,0.5,0.5)
            Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
        end
    end
})

-- Remove Fog toggle
local fogRemoved = false

VisualsTab:CreateToggle({
    Name = "Remove Fog",
    CurrentValue = false,
    Flag = "RemoveFogToggle",
    Callback = function(value)
        fogRemoved = value
        if fogRemoved then
            Lighting.FogEnd = 1e9
        else
            Lighting.FogEnd = 1000
        end
    end
})

-- Chams toggle (simple colored character models)
local chamsEnabled = false
local chamParts = {}

local function applyChams()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Transparency ~= 0.5 then
                    part.Transparency = 0.5
                    part.Color = Color3.fromRGB(255, 0, 0)
                    chamParts[part] = true
                end
            end
        end
    end
end

local function removeChams()
    for part, _ in pairs(chamParts) do
        if part and part.Parent then
            part.Transparency = 0
            part.Color = Color3.new(1,1,1)
        end
    end
    chamParts = {}
end

VisualsTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Flag = "ChamsToggle",
    Callback = function(value)
        chamsEnabled = value
        if chamsEnabled then
            applyChams()
        else
            removeChams()
        end
    end
})

-- Rainbow ESP toggle (cycles ESP boxes color)
local rainbowEnabled = false
local hue = 0

VisualsTab
