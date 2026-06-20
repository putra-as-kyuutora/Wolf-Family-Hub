-- Violence District Cheat Base with UI
local cheatHub = Instance.new("ScreenGui")
cheatHub.Name = "ViolenceDistrictCheatHub"
cheatHub.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main Container
local frame = Instance.new("Frame")
frame.Name = "MainContainer"
frame.Size = UDim2.new(0, 250, 0, 400)
frame.Position = UDim2.new(0.5, -125, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = cheatHub

-- Header
local header = Instance.new("TextLabel")
header.Text = "Violence District Cheats"
header.Size = UDim2.new(1, 0, 0, 40)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.FontSize = Enum.FontSize.Size18
header.TextScaled = true
header.Parent = frame

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Text = "X"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.FontSize = Enum.FontSize.Size18
closeButton.MouseButton1Click:Connect(function()
    cheatHub.Enabled = false
end)
closeButton.Parent = header

-- Scroll Frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -45)
scrollFrame.Position = UDim2.new(0, 0, 0, 45)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.Parent = frame

-- Toggle Container
local toggleContainer = Instance.new("Frame")
toggleContainer.Size = UDim2.new(1, 0, 0, 200)
toggleContainer.BackgroundTransparency = 1
toggleContainer.Parent = scrollFrame

-- Cheat Toggles
local godModeToggle = createToggle("God Mode", "Enables invincibility")
local infiniteAmmoToggle = createToggle("Infinite Ammo", "Removes ammo limits")
local speedHackToggle = createToggle("Speed Hack", "Increases movement speed")
local damageBoostToggle = createToggle("Damage Boost", "Multiplies weapon damage")
local noClipToggle = createToggle("No Clip", "Allows flying through walls")

-- Function to create toggle buttons
function createToggle(text, description)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, 0, 0, 40)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggle.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0, 150, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = toggle
    
    local status = Instance.new("TextButton")
    status.Text = "OFF"
    status.Size = UDim2.new(0, 60, 1, 0)
    status.Position = UDim2.new(1, -70, 0, 0)
    status.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.MouseButton1Click:Connect(function()
        if status.Text == "ON" then
            status.Text = "OFF"
            status.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        else
            status.Text = "ON"
            status.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        end
        updateCheatStatus(text, status.Text == "ON")
    end)
    status.Parent = toggle
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Text = description
    descLabel.Size = UDim2.new(1, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 1, -20)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.FontSize = Enum.FontSize.Size12
    descLabel.Parent = toggle
    
    toggle.Parent = toggleContainer
    return toggle
end

-- Cheat Status Tracking
local activeCheats = {}

-- Update cheat status
function updateCheatStatus(name, enabled)
    activeCheats[name] = enabled
    applyCheat(name, enabled)
end

-- Apply cheat effect
function applyCheat(name, enabled)
    if name == "God Mode" then
        if enabled then
            spawn(function()
                while true do
                    local health = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health
                    if health <= 1 then
                        game.Players.LocalPlayer.Character.Humanoid.Health = 100
                    end
                    wait(0.1)
                end
            end)
        end
    elseif name == "Infinite Ammo" then
        if enabled then
            spawn(function()
                while true do
                    for _, weapon in ipairs(game.Players.LocalPlayer.Character:WaitForChild("Backpack"):GetChildren()) do
                        if weapon:IsA("Tool") then
                            weapon.Ammo.Value = 999
                        end
                    end
                    wait(0.5)
                end
            end)
        end
    elseif name == "Speed Hack" then
        if enabled then
            spawn(function()
                while true do
                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
                    game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
                    wait(0.1)
                end
            end)
        end
    elseif name == "Damage Boost" then
        if enabled then
            spawn(function()
                while true do
                    for _, weapon in ipairs(game.Players.LocalPlayer.Character:WaitForChild("Backpack"):GetChildren()) do
                        if weapon:IsA("Tool") then
                            weapon.Damage.Value = weapon.Damage.Value * 2
                        end
                    end
                    wait(1)
                end
            end)
        end
    elseif name == "No Clip" then
        if enabled then
            spawn(function()
                while true do
                    game.Players.LocalPlayer.Character.Animate.Disabled = true
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
                    wait(0.1)
                end
            end)
        end
    end
end

-- Reset All Cheats
local resetButton = Instance.new("TextButton")
resetButton.Text = "Reset All"
resetButton.Size = UDim2.new(1, 0, 0, 40)
resetButton.Position = UDim2.new(0, 0, 1, -45)
resetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.MouseButton1Click:Connect(function()
    for _, toggle in pairs(toggleContainer:GetChildren()) do
        if toggle:IsA("Frame") then
            toggle:FindFirstChild("TextButton").Text = "OFF"
            toggle:FindFirstChild("TextButton").BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
    end
    for name, _ in pairs(activeCheats) do
        activeCheats[name] = false
    end
end)
resetButton.Parent = frame