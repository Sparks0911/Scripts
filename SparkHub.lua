-- SparkHub v1.0 — polished UI, rainbow title, toggles, ESP, slider
-- Paste this into SparkHub.lua on your GitHub and load with:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Sparks0911/Scripts/main/SparkHub.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

if getgenv().SparkHubLoaded then
    warn("SparkHub already loaded!")
    return
end
getgenv().SparkHubLoaded = true

-- Create GUI
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "SparkHubGUI"
screenGui.ResetOnSpawn = false

-- Splash Screen
local loadLbl = Instance.new("TextLabel", screenGui)
loadLbl.Size, loadLbl.Position = UDim2.new(0,280,0,50), UDim2.new(0.5,-140,0.5,-25)
loadLbl.BackgroundColor3 = Color3.fromRGB(18,18,18)
loadLbl.TextColor3 = Color3.new(1,1,1)
loadLbl.Font, loadLbl.TextSize = Enum.Font.GothamBold, 26
loadLbl.Text, loadLbl.TextWrapped = "SparkHub is loading...", true
loadLbl.TextXAlignment, loadLbl.TextYAlignment = Enum.TextXAlignment.Center, Enum.TextYAlignment.Center
Instance.new("UICorner", loadLbl).CornerRadius = UDim.new(0,12)

task.wait(2)
loadLbl:Destroy()

-- Main Frame
local main = Instance.new("Frame", screenGui)
main.Size, main.Position = UDim2.new(0,320,0,400), UDim2.new(0.5,-160,0.5,-200)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- Rainbow Title
local title = Instance.new("TextLabel", main)
title.Size, title.Position = UDim2.new(1,0,0,40), UDim2.new(0,0,0,8)
title.BackgroundTransparency, title.Text = 1, "⚡SparkHub⚡"
title.Font, title.TextSize = Enum.Font.GothamBold, 28
title.TextColor3 = Color3.fromRGB(255,0,0)
title.TextStrokeTransparency = 0.6
title.TextXAlignment = Enum.TextXAlignment.Center

-- Rainbow Title Animation
spawn(function()
    while task.wait(0.05) do
        local t = tick() * 25
        title.TextColor3 = Color3.fromHSV((t%360)/360, 1, 1)
    end
end)

-- Content Layout
local content = Instance.new("Frame", main)
content.Size, content.Position = UDim2.new(1,-32,1,-100), UDim2.new(0,16,0,56)
content.BackgroundTransparency = 1
local list = Instance.new("UIListLayout", content)
list.SortOrder, list.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0,14)

-- Toggle Helper
local function newToggle(text, callback)
    local f = Instance.new("Frame", content)
    f.Size = UDim2.new(1,0,0,30)
    local l = Instance.new("TextLabel", f)
    l.Size, l.Position, l.BackgroundTransparency = UDim2.new(1,-40,1,0), UDim2.new(0,8,0,0), 1
    l.Text, l.Font, l.TextSize, l.TextColor3 = text, Enum.Font.GothamSemibold, 20, Color3.fromRGB(230,230,230)
    l.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", f)
    btn.Size, btn.Position, btn.BackgroundColor3 = UDim2.new(0,28,0,28), UDim2.new(1,-28,0.5,-14), Color3.fromRGB(38,38,38)
    btn.AutoButtonColor, btn.Text = false, ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    local tickImg = Instance.new("ImageLabel", btn)
    tickImg.Size, tickImg.Position = UDim2.new(0.7), UDim2.new(0.15)
    tickImg.Image, tickImg.ImageColor3 = "rbxassetid://3926307971", Color3.new(0,1,0)
    tickImg.BackgroundTransparency = 1
    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        tickImg.Visible = toggled
        callback(toggled)
    end)
    return f
end

-- Features
newToggle("Fly", function(on)
    if on then
        Humanoid:ChangeState(Enum.HumanoidStateType.Flying) -- placeholder
    end
end)

newToggle("Noclip", function(on)
    if on then
        -- Simple noclip
        game:GetService("RunService").Stepped:Connect(function()
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not on
                end
            end
        end)
    end
end)

newToggle("ESP", function(on)
    if on then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local box = Drawing.new("Quad")
                RunService.RenderStepped:Connect(function()
                    local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local corners = {
                            Vector3.new(-2, 3, 0),
                            Vector3.new(2, 3, 0),
                            Vector3.new(2, -1, 0),
                            Vector3.new(-2, -1, 0),
                        }
                        for i,v in ipairs(corners) do
                            local pos = Camera:WorldToViewportPoint(root.Position + Vector3.new(v.X, v.Y, v.Z))
                            box.Points[i] = Vector2.new(pos.X, pos.Y)
                        end
                        box.Visible, box.Color = true, Color3.new(1,0,0)
                    else
                        box.Visible = false
                    end
                end)
            end
        end
    end
end)

newToggle("Infinite Jump", function(on)
    local conn
    if on then
        conn = UserInputService.JumpRequest:Connect(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
        getgenv().infJumpConn = conn
    else
        if getgenv().infJumpConn then
            getgenv().infJumpConn:Disconnect()
        end
    end
end)

-- WalkSpeed Slider
local sliderF = Instance.new("Frame", main)
sliderF.Size, sliderF.Position, sliderF.BackgroundTransparency = UDim2.new(1,-32,0,60), UDim2.new(0,16,1,-70), 1
local slLbl = Instance.new("TextLabel", sliderF)
slLbl.Size, slLbl.BackgroundTransparency, slLbl.TextXAlignment = UDim2.new(1,0,0,24), 1, Enum.TextXAlignment.Left
slLbl.Position, slLbl.Font, slLbl.TextSize = UDim2.new(0,0,0,0), Enum.Font.GothamSemibold, 20
slLbl.TextColor3 = Color3.fromRGB(230,230,230)

local bar = Instance.new("Frame", sliderF)
bar.Size, bar.Position, bar.BackgroundColor3 = UDim2.new(1,0,0,12), UDim2.new(0,0,0,34), Color3.fromRGB(38,38,38)
Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)
local fill = Instance.new("Frame", bar)
fill.Size, fill.BackgroundColor3 = UDim2.new(0,0,1,0), Color3.fromRGB(0,255,0)
Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)
local handle = Instance.new("ImageButton", bar)
handle.Size, handle.BackgroundColor3 = UDim2.new(0,20,0,20), Color3.fromRGB(255,255,255)
handle.Name, handle.AutoButtonColor = "Handle", false
Instance.new("UICorner", handle).CornerRadius = UDim.new(1,0)

local dragging = false
local minS, maxS = 1, 250
local curS = 16

local function upd(x)
    local rel = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
    local pct = rel/bar.AbsoluteSize.X
    fill.Size = UDim2.new(pct,0,1,0)
    handle.Position = UDim2.new(pct, -10, 0.5, -10)
    curS = math.floor(minS + (maxS-minS)*pct)
    slLbl.Text = "WalkSpeed: "..curS
    Humanoid.WalkSpeed = curS
end

handle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
handle.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then upd(i.Position.X); dragging=true end end)
bar.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)

task.spawn(function()
    task.wait(0.1)
    upd(bar.AbsolutePosition.X + bar.AbsoluteSize.X * ((curS-minS)/(maxS-minS)))
end)
