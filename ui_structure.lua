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
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.Parent = frame

-- Toggle Container
local toggleContainer = Instance.new("Frame")
toggleContainer.Size = UDim2.new(1, 0, 0, 270)
toggleContainer.BackgroundTransparency = 1
toggleContainer.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = toggleContainer

local toggleCount = 0

-- Function to create toggle buttons
function createToggle(text, description)
    toggleCount = toggleCount + 1
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, 0, 0, 40)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggle.BorderSizePixel = 0
    toggle.LayoutOrder = toggleCount
    
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

-- Cheat Toggles
local godModeToggle = createToggle("God Mode", "Enables invincibility")
local infiniteAmmoToggle = createToggle("Infinite Ammo", "Removes ammo limits")
local speedHackToggle = createToggle("Speed Hack", "Increases movement speed")
local damageBoostToggle = createToggle("Damage Boost", "Multiplies weapon damage")
local noClipToggle = createToggle("No Clip", "Allows flying through walls")
local remoteSpyToggle = createToggle("Remote Spy", "Monitors remote events and functions")

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
    elseif name == "Remote Spy" then
        shared.RemoteSpyActive = enabled
        if enabled then
            spawn(function()
                print("[Remote Spy] Initializing monitoring...")
                local filename = "remotespy_log.txt"
                
                -- Helper to append logs to local file in executor workspace
                local function appendToLog(text)
                    local timeStr = os.date("%Y-%m-%d %H:%M:%S")
                    local logLine = string.format("[%s] %s", timeStr, text)
                    if appendfile then
                        pcall(appendfile, filename, logLine .. "\n")
                    elseif writefile and readfile then
                        local current = ""
                        pcall(function() current = readfile(filename) or "" end)
                        pcall(writefile, filename, current .. logLine .. "\n")
                    end
                end
                
                -- Log startup session
                appendToLog("--- REMOTE SPY SESSION STARTED ---")
                
                -- Only hook once globally to prevent performance lag or crashes
                if not shared.RemoteSpyHooked then
                    local success, err = pcall(function()
                        if not hookmetamethod then
                            error("Executor does not support hookmetamethod API.")
                        end
                        
                        local __namecall
                        __namecall = hookmetamethod(game, "__namecall", function(self, ...)
                            local method = getnamecallmethod()
                            local args = {...}
                            
                            -- Only log when Remote Spy is enabled
                            if shared.RemoteSpyActive then
                                if method == "FireServer" and self.ClassName == "RemoteEvent" then
                                    local eventName = self.Name
                                    local argsStr = ""
                                    for i, arg in ipairs(args) do
                                        argsStr = argsStr .. string.format("\n  Arg %d: %s (%s)", i, tostring(arg), typeof(arg))
                                    end
                                    local msg = string.format("RemoteEvent Fired: %s%s", eventName, argsStr)
                                    print("[Remote Spy]", msg)
                                    appendToLog(msg)
                                elseif method == "InvokeServer" and self.ClassName == "RemoteFunction" then
                                    local funcName = self.Name
                                    local argsStr = ""
                                    for i, arg in ipairs(args) do
                                        argsStr = argsStr .. string.format("\n  Arg %d: %s (%s)", i, tostring(arg), typeof(arg))
                                    end
                                    local msg = string.format("RemoteFunction Invoked: %s%s", funcName, argsStr)
                                    print("[Remote Spy]", msg)
                                    appendToLog(msg)
                                end
                            end
                            
                            return __namecall(self, ...)
                        end)
                        
                        shared.RemoteSpyHooked = true
                        print("[Remote Spy] Native hook established successfully.")
                        appendToLog("Native hook established successfully.")
                    end)
                    
                    if not success then
                        local errMsg = "Failed to establish native hook: " .. tostring(err)
                        warn("[Remote Spy]", errMsg)
                        appendToLog(errMsg)
                    end
                else
                    print("[Remote Spy] Remote Spy reactivated.")
                    appendToLog("Remote Spy reactivated.")
                end
            end)
        else
            print("[Remote Spy] Remote Spy deactivated.")
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
