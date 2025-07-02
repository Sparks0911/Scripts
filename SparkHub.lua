--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Create Window
local Window = Rayfield:CreateWindow({
    Name = "⚡SparkHub V2⚡",
    LoadingTitle = "",
    LoadingSubtitle = "",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SparkHubConfigs",
        FileName = "UniversalConfig"
    },
    KeySystem = false,
    ToggleUIKeybind = "K"
})

--// GLOBAL VARIABLES
local flySpeed = 50
local flyEnabled = false
local noclipEnabled = false
local infiniteJumpEnabled = false
local aimbotEnabled = false
local aimbotFOV = 30
local espEnabled = false
local rainbowESP = false
local antiAfkEnabled = false
local chatSpamEnabled = false
local spamMessage = "I am unstoppable! ⚡SparkHub⚡"
local RunServiceHeartbeatConnection

local targetPlayer = nil -- For trolling tab

-- ESP containers
local espBoxes = {}
local hue = 0

-- UTILS
local function isAlive(player)
    return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart")
end

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if Players.Team and player.Team and LocalPlayer.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

--// PLAYER TAB
local PlayerTab = Window:CreateTab("Player", 4483362458)

local walkspeedSlider = PlayerTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkspeedSlider",
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end,
})

local jumppowerSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 250},
    Increment = 5,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end,
})

local flyToggle = PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(value)
        flyEnabled = value
        if flyEnabled then
            startFly()
        else
            stopFly()
        end
    end,
})

local flySpeedSlider = PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = flySpeed,
    Flag = "FlySpeedSlider",
    Callback = function(value)
        flySpeed = value
    end,
})

local noclipToggle = PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(value)
        noclipEnabled = value
    end,
})

local infiniteJumpToggle = PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(value)
        infiniteJumpEnabled = value
    end,
})

local aimbotToggle = PlayerTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(value)
        aimbotEnabled = value
    end,
})

local aimbotFOVSlider = PlayerTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {10, 100},
    Increment = 1,
    Suffix = "Pixels",
    CurrentValue = 30,
    Flag = "AimbotFOVSlider",
    Callback = function(value)
        aimbotFOV = value
    end,
})

-- Fly functionality
local flying = false
local flyBodyVelocity, flyBodyGyro

function startFly()
    if flying then return end
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flying = true

    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = hrp

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp

    spawn(function()
        while flyEnabled and flying and hrp and flyBodyVelocity and flyBodyGyro do
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
                flyBodyVelocity.Velocity = moveDir * flySpeed
                flyBodyGyro.CFrame = Camera.CFrame
            else
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

function stopFly()
    flying = false
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
end

-- Noclip logic
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Infinite jump logic
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--// VISUALS TAB
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

local function createESPBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    return box
end

local function getRootPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
end

local function worldToViewportPoint(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function updateESP()
    for player, boxes in pairs(espBoxes) do
        if isAlive(player) and isEnemy(player) and espEnabled then
            local root = getRootPart(player.Character)
            if root then
                local rootPos, onScreen = worldToViewportPoint(root.Position)
                if onScreen then
                    local size = 1000 / rootPos.Z
                    for _, box in pairs(boxes) do
                        box.Visible = true
                        box.Size = Vector2.new(size * 0.6, size * 1.4)
                        box.Position = Vector2.new(rootPos.X - box.Size.X / 2, rootPos.Y - box.Size.Y / 2)
                        if rainbowESP then
                            box.Color = Color3.fromHSV(hue, 1, 1)
                        else
                            box.Color = Color3.new(1, 0, 0)
                        end
                    end
                else
                    for _, box in pairs(boxes) do
                        box.Visible = false
                    end
                end
            else
                for _, box in pairs(boxes) do
                    box.Visible = false
                end
            end
        else
            for _, box in pairs(boxes or {}) do
                box.Visible = false
            end
        end
    end
end

local function addESPToPlayer(player)
    if espBoxes[player] then return end
    espBoxes[player] = {createESPBox()}
end

local function removeESPFromPlayer(player)
    if espBoxes[player] then
        for _, box in pairs(espBoxes[player]) do
            box:Remove()
        end
        espBoxes[player] = nil
    end
end

Players.PlayerAdded:Connect(function(player)
    addESPToPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESPFromPlayer(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        addESPToPlayer(player)
    end
end

local rainbowToggle = VisualsTab:CreateToggle({
    Name = "Rainbow ESP",
    CurrentValue = false,
    Flag = "RainbowESPToggle",
    Callback = function(value)
        rainbowESP = value
    end,
})

local espToggle = VisualsTab:CreateToggle({
    Name = "Enemy ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(value)
        espEnabled = value
        if not espEnabled then
            for _, boxes in pairs(espBoxes) do
                for _, box in pairs(boxes) do
                    box.Visible = false
                end
            end
        end
    end,
})

VisualsTab:CreateColorPicker({
    Name = "Crosshair Color",
    Default = Color3.new(1, 1, 1),
    Flag = "CrosshairColorPicker",
    Callback = function(color)
        local crosshair = StarterGui:FindFirstChild("Crosshair")
        if crosshair then
            crosshair.ImageColor3 = color
        end
    end,
})

RunService.Heartbeat:Connect(function(dt)
    if espEnabled then
        updateESP()
    end
    if rainbowESP then
        hue = (hue + dt * 0.5) % 1
    end
end)

--// AIMBOT
local function getClosestEnemyToCursor()
    local closestDist = aimbotFOV
    local closestPlayer = nil
    local mouse = LocalPlayer:GetMouse()

    for _, player in pairs(Players:GetPlayers()) do
        if isAlive(player) and isEnemy(player) then
            local char = player.Character
            local head = char and char:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

local function aimAt(targetPos)
    local mouse = LocalPlayer:GetMouse()
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if onScreen then
        local dx = screenPos.X - mouse.X
        local dy = screenPos.Y - mouse.Y
        local step = 15
        local newX = mouse.X + dx / step
        local newY = mouse.Y + dy / step
        UserInputService:SetMouseLocation(newX, newY)
    end
end

RunService.Heartbeat:Connect(function()
    if aimbotEnabled then
        local target = getClosestEnemyToCursor()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            aimAt(target.Character.Head.Position)
        end
    end
end)

--// MISC TAB
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFKToggle",
    Callback = function(value)
        antiAfkEnabled = value
        if antiAfkEnabled then
            local vu = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                wait(1)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    end,
})

MiscTab:CreateToggle({
    Name = "Chat Spam",
    CurrentValue = false,
    Flag = "ChatSpamToggle",
    Callback = function(value)
        chatSpamEnabled = value
    end,
})

MiscTab:CreateTextBox({
    Name = "Spam Message",
    PlaceholderText = "Enter spam message...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        spamMessage = text
    end,
})

spawn(function()
    while true do
        wait(2)
        if chatSpamEnabled then
            pcall(function()
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(spamMessage, "All")
            end)
        end
    end
end)

MiscTab:CreateToggle({
    Name = "Give BTools",
    CurrentValue = false,
    Flag = "BToolsToggle",
    Callback = function(value)
        local backpack = LocalPlayer:WaitForChild("Backpack")
        if value then
            local toolNames = {"Hammer", "Clone", "Delete"}
            for _, toolName in pairs(toolNames) do
                if not backpack:FindFirstChild(toolName) then
                    local tool = Instance.new("HopperBin")
                    tool.Name = toolName
                    tool.Parent = backpack
                end
            end
        else
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("HopperBin") and (tool.Name == "Hammer" or tool.Name == "Clone" or tool.Name == "Delete") then
                    tool:Destroy()
                end
            end
        end
    end,
})

MiscTab:CreateButton({
    Name = "Auto Rejoin",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

MiscTab:CreateButton({
    Name = "Reload Script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Sparks0911/Scripts/main/SparkHubV1.lua"))()
    end,
})

--// EMERGENCY TAB
local EmergencyTab = Window:CreateTab("🚨Emergency🚨", 4483362458)

EmergencyTab:CreateButton({
    Name = "Self Destruct",
    Callback = function()
        local flashGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
        flashGui.Name = "SelfDestructGui"
        local flashFrame = Instance.new("Frame", flashGui)
        flashFrame.Size = UDim2.new(1,0,1,0)
        flashFrame.BackgroundColor3 = Color3.new(1,0,0)
        flashFrame.BackgroundTransparency = 1

        local sound = Instance.new("Sound", flashGui)
        sound.SoundId = "rbxassetid://138186576" -- Siren sound
        sound.Looped = true
        sound.Volume = 5
        sound:Play()

        local flashCount = 0
        local flashConnection
        flashConnection = RunService.Heartbeat:Connect(function(dt)
            flashCount = flashCount + dt * 10
            flashFrame.BackgroundTransparency = math.abs(math.sin(flashCount))
            if flashCount > 30 then
                flashConnection:Disconnect()
                sound:Stop()
                flashGui:Destroy()
                StarterGui:SetCore("SendNotification", {
                    Title = "⚡SparkHub⚡";
                    Text = "You have been TERMINATED and IP BANNED!";
                    Duration = 5;
                })
                wait(0.5)
                LocalPlayer:Kick("You have been TERMINATED and IP BANNED! ⚡SparkHub⚡")
            end
        end)
    end,
})

--// TROLL TAB
local TrollTab = Window:CreateTab("Troll", 4483362458)

-- Player selector dropdown
local playersList = {}
local function updatePlayersList()
    playersList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playersList, player.Name)
        end
    end
end
updatePlayersList()
Players.PlayerAdded:Connect(updatePlayersList)
Players.PlayerRemoving:Connect(updatePlayersList)

local targetDropdown = TrollTab:CreateDropdown({
    Name = "Select Target",
    Options
