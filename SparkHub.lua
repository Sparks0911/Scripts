-- ⚡ SparkHub 2.0 - Enhanced GUI ⚡
-- Fully custom GUI without Rayfield branding

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚡SparkHub⚡",
   LoadingTitle = "⚡SparkHub⚡",
   LoadingSubtitle = "Loading...",
   ShowText = "",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SparkHub2",
      FileName = "PlayerConfig"
   }
})

local PlayerTab = Window:CreateTab("Player", 4483362458)

-- Fly, WalkSpeed, JumpPower, Noclip, Infinite Jump defined here (same as before)...
-- NEW: Aimbot (locks camera to nearest enemy's head)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local aimbotEnabled = false

function getClosestEnemyToCursor()
   local closest = nil
   local shortest = math.huge
   for _, p in pairs(Players:GetPlayers()) do
      if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Head") then
         local pos, visible = Camera:WorldToViewportPoint(p.Character.Head.Position)
         if visible then
            local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
            if dist < shortest then
               shortest = dist
               closest = p
            end
         end
      end
   end
   return closest
end

RunService.RenderStepped:Connect(function()
   if aimbotEnabled then
      local target = getClosestEnemyToCursor()
      if target and target.Character and target.Character:FindFirstChild("Head") then
         Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
      end
   end
end)

PlayerTab:CreateToggle({
   Name = "Aimbot (Head Lock)",
   CurrentValue = false,
   Flag = "Aimbot",
   Callback = function(Value)
      aimbotEnabled = Value
   end
})

-- ESP (Body Outline Boxes)
local espEnabled = false
function createBodyESP(char)
   for _, part in ipairs(char:GetDescendants()) do
      if part:IsA("BasePart") and not part:FindFirstChild("BodyESP") then
         local adorn = Instance.new("BoxHandleAdornment")
         adorn.Name = "BodyESP"
         adorn.Adornee = part
         adorn.AlwaysOnTop = true
         adorn.ZIndex = 10
         adorn.Size = part.Size + Vector3.new(0.1,0.1,0.1)
         adorn.Transparency = 0.5
         adorn.Color3 = Color3.fromRGB(255, 0, 0)
         adorn.Parent = part
      end
   end
end

function clearBodyESP(char)
   for _, part in ipairs(char:GetDescendants()) do
      if part:IsA("BasePart") then
         local adorn = part:FindFirstChild("BodyESP")
         if adorn then adorn:Destroy() end
      end
   end
end

function toggleESP(state)
   for _, p in pairs(Players:GetPlayers()) do
      if p ~= LocalPlayer and p.Character then
         if state then
            createBodyESP(p.Character)
         else
            clearBodyESP(p.Character)
         end
      end
   end
end

PlayerTab:CreateToggle({
   Name = "ESP (Body Boxes)",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
      espEnabled = Value
      toggleESP(Value)
   end
})
