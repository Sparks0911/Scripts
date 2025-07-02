local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚡SparkHub 2.0⚡",
   LoadingTitle = "⚡SparkHub 2.0⚡",
   LoadingSubtitle = "by Sparks",
   Theme = "Default",
   ToggleUIKeybind = "K",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SparkHub2",
      FileName = "PlayerConfig"
   }
})

local PlayerTab = Window:CreateTab("Player", 4483362458)

-- Fly
local flyEnabled = false
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local flySpeed = 50
local flyConnection

local function enableFly()
   local char = game.Players.LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end

   local bv = Instance.new("BodyVelocity")
   bv.Name = "FlyVelocity"
   bv.Velocity = Vector3.zero
   bv.MaxForce = Vector3.new(1e9,1e9,1e9)
   bv.Parent = char.HumanoidRootPart

   flyConnection = RunService.RenderStepped:Connect(function()
      local vel = Vector3.zero
      if UIS:IsKeyDown(Enum.KeyCode.W) then vel += workspace.CurrentCamera.CFrame.LookVector end
      if UIS:IsKeyDown(Enum.KeyCode.S) then vel -= workspace.CurrentCamera.CFrame.LookVector end
      if UIS:IsKeyDown(Enum.KeyCode.A) then vel -= workspace.CurrentCamera.CFrame.RightVector end
      if UIS:IsKeyDown(Enum.KeyCode.D) then vel += workspace.CurrentCamera.CFrame.RightVector end
      bv.Velocity = vel * flySpeed
   end)
end

local function disableFly()
   flyEnabled = false
   local char = game.Players.LocalPlayer.Character
   if char and char:FindFirstChild("HumanoidRootPart") then
      local bv = char.HumanoidRootPart:FindFirstChild("FlyVelocity")
      if bv then bv:Destroy() end
   end
   if flyConnection then flyConnection:Disconnect() end
end

PlayerTab:CreateToggle({
   Name = "Fly (WASD)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      flyEnabled = Value
      if Value then enableFly() else disableFly() end
   end
})

-- WalkSpeed Slider
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      local char = game.Players.LocalPlayer.Character
      if char and char:FindFirstChild("Humanoid") then
         char.Humanoid.WalkSpeed = Value
      end
   end
})

-- JumpPower Slider
PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 200},
   Increment = 5,
   Suffix = "Jump",
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      local char = game.Players.LocalPlayer.Character
      if char and char:FindFirstChild("Humanoid") then
         char.Humanoid.JumpPower = Value
      end
   end
})

-- Noclip
local noclip = false
RunService.Stepped:Connect(function()
   if noclip then
      for _, part in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
         end
      end
   end
end)

PlayerTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      noclip = Value
   end
})

-- Infinite Jump
local infJump = false
game:GetService("UserInputService").JumpRequest:Connect(function()
   if infJump then
      local player = game.Players.LocalPlayer
      if player and player.Character and player.Character:FindFirstChild("Humanoid") then
         player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
      end
   end
end)

PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJumpToggle",
   Callback = function(Value)
      infJump = Value
   end
})

-- Simple ESP (name tags above heads)
local function toggleESP(state)
   for _, player in ipairs(game.Players:GetPlayers()) do
      if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
         if state then
            if not player.Character:FindFirstChild("ESPBillboard") then
               local bb = Instance.new("BillboardGui", player.Character)
               bb.Name = "ESPBillboard"
               bb.Adornee = player.Character.Head
               bb.Size = UDim2.new(0, 100, 0, 40)
               bb.StudsOffset = Vector3.new(0, 3, 0)
               bb.AlwaysOnTop = true

               local label = Instance.new("TextLabel", bb)
               label.Size = UDim2.new(1, 0, 1, 0)
               label.Text = player.Name
               label.TextColor3 = Color3.fromRGB(255, 0, 0)
               label.BackgroundTransparency = 1
               label.TextScaled = true
            end
         else
            local bb = player.Character:FindFirstChild("ESPBillboard")
            if bb then bb:Destroy() end
         end
      end
   end
end

PlayerTab:CreateToggle({
   Name = "ESP (Name Tags)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      toggleESP(Value)
   end
})
