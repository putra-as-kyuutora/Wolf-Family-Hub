-- Wolf Family Cheat Base V0.0.0.3 - FORKT-HUB Integrated Logic

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Place ID Lock
local TARGET_PLACE_ID = 93978595733734 -- Place ID Violence District
if game.PlaceId ~= TARGET_PLACE_ID and TARGET_PLACE_ID ~= 93978595733734 then
    warn("Wolf Family Hub: Incorrect Place ID. Script stopped.")
    return
end

if game.PlaceId ~= TARGET_PLACE_ID then
    warn("Peringatan Place ID: Script dijalankan di luar Violence District!")
end

local function notify(title, content, duration)
    if getgenv().OctoNotify then
        getgenv().OctoNotify(title, content, duration)
    else
        print("["..title.."] " .. content)
    end
end

-- Configuration & States
local activeCheats = {}
local Config = {
    ESP = {
        Chams = {
            Killer = false,
            Survivor = false,
            Generator = false,
            Gate = false,
            Hook = false,
            Pallet = false,
            Window = false
        },
        Text = {
            Killer = false,
            Survivor = false,
            Generator = false,
            Gate = false,
            Hook = false,
            Pallet = false,
            Window = false
        },
        Colors = {
            Killer = Color3.fromRGB(255, 0, 0),
            Survivor = Color3.fromRGB(0, 255, 0),
            Generator = Color3.fromRGB(255, 128, 0),
            Gate = Color3.fromRGB(255, 255, 255),
            Hook = Color3.fromRGB(255, 0, 0),
            Pallet = Color3.fromRGB(255, 255, 0),
            Window = Color3.fromRGB(0, 0, 255)
        },
        ShowDistance = true,
        MaxDistance = 500
    },
    Aimbot = {
        Enabled = false,
        Target = "Killer",
        Part = "Torso",
        ShowFOV = false,
        Radius = 150,
        Smoothness = 0.5,
        MaxDistance = 500
    },
    Combat = {
        AutoParry = false,
        ParryDelay = 0.1,
        Moonwalk = false,
        BoostPower = 50
    },
    Movement = {
        Speed = 50
    },
    AutoFeatures = {
        AutoGenerator = false,
        AutoAttack = false,
        AutoHeal = false,
        AutoSkillCheck = false,
        AttackRange = 10
    },
    Performance = {
        UpdateRate = 0.5,
        MaxESPObjects = 100
    }
}

getgenv().Config = Config -- Expose to UI
getgenv().activeCheats = activeCheats -- Expose to UI

local Highlights = {}
local BillboardGuis = {}
local LastUpdate = 0
local UpdateConnection = nil
local AutoAttackConnection = nil
local AimbotConnection = nil
local FOVCircle = nil

-- ================== HELPER FUNCTIONS ==================
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then return nil end
    return result
end

local function validateInstance(instance)
    return instance and typeof(instance) == "Instance" and instance.Parent ~= nil
end

local function isKiller()
    return LocalPlayer.Team and LocalPlayer.Team.Name == "Killer"
end

local function isSurvivor()
    return LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors"
end

local function getCharacterRootPart()
    if not LocalPlayer.Character then return nil end
    return LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- ================== ESP SYSTEM ==================
local function createHighlight(obj, color)
    if not validateInstance(obj) then return end
    if obj:FindFirstChild("WolfHighlight") then return end
    
    safeCall(function()
        local h = Instance.new("Highlight")
        h.Name = "WolfHighlight"
        h.Adornee = obj
        h.FillColor = color
        h.OutlineColor = color
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.Parent = obj
        Highlights[obj] = h
    end)
end

local function removeHighlight(obj)
    if Highlights[obj] then
        safeCall(function()
            if validateInstance(Highlights[obj]) then
                Highlights[obj]:Destroy()
            end
        end)
        Highlights[obj] = nil
    end
    local existingH = obj:FindFirstChild("WolfHighlight")
    if existingH then existingH:Destroy() end
end

local function createLabel(obj, text, color)
    if not validateInstance(obj) then return end
    local hrp = getCharacterRootPart()
    if not hrp then return end
    
    local rootPart = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or (obj:IsA("BasePart") and obj or nil)
    if not rootPart then return end
    
    local distance = (hrp.Position - rootPart.Position).Magnitude
    
    if distance > Config.ESP.MaxDistance then
        if BillboardGuis[obj] then
            safeCall(function() if validateInstance(BillboardGuis[obj]) then BillboardGuis[obj]:Destroy() end end)
            BillboardGuis[obj] = nil
        end
        return
    end
    
    if BillboardGuis[obj] and validateInstance(BillboardGuis[obj]) then
        local textLabel = BillboardGuis[obj]:FindFirstChild("TextLabel")
        if textLabel then
            textLabel.Text = Config.ESP.ShowDistance and string.format("%s\n%.0fm", text, distance) or text
        end
        return
    end
    
    safeCall(function()
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "WolfLabel"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = rootPart
        billboard.Parent = obj
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TextLabel"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = color
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextScaled = false
        textLabel.TextSize = 12
        textLabel.Text = Config.ESP.ShowDistance and string.format("%s\n%.0fm", text, distance) or text
        textLabel.Parent = billboard
        
        BillboardGuis[obj] = billboard
    end)
end

local function removeLabel(obj)
    if BillboardGuis[obj] then
        safeCall(function() if validateInstance(BillboardGuis[obj]) then BillboardGuis[obj]:Destroy() end end)
        BillboardGuis[obj] = nil
    end
end

local function clearAllESP()
    for obj, _ in pairs(Highlights) do removeHighlight(obj) end
    for obj, _ in pairs(BillboardGuis) do removeLabel(obj) end
    Highlights = {}
    BillboardGuis = {}
end

local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team then
            local teamName = player.Team.Name
            local displayName = player.Name
            
            -- FORKT-HUB SPECIFIC KILLER NAMES
            local knownKillers = {"ABYSSWALKER", "CURE", "HIDDEN", "PALA AYAM", "STALKER", "VEIL"}
            for _, kn in ipairs(knownKillers) do
                if string.upper(player.Name):find(kn) then displayName = kn break end
            end
            
            local chamsEnabled = false
            local textEnabled = false
            local color = Color3.fromRGB(255, 255, 255)
            local label = displayName
            
            if teamName == "Killer" then
                chamsEnabled = Config.ESP.Chams.Killer
                textEnabled = Config.ESP.Text.Killer
                color = Config.ESP.Colors.Killer
                label = displayName .. "\n[KILLER]"
            elseif teamName == "Survivors" then
                chamsEnabled = Config.ESP.Chams.Survivor
                textEnabled = Config.ESP.Text.Survivor
                color = Config.ESP.Colors.Survivor
                label = displayName .. "\n[SURVIVOR]"
            end
            
            if chamsEnabled then createHighlight(player.Character, color) else removeHighlight(player.Character) end
            if textEnabled then createLabel(player.Character, label, color) else removeLabel(player.Character) end
        end
    end
end

local function updateObjectESP(itemName, configFlag, labelText)
    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:find(itemName) then
                local finalLabel = labelText
                if itemName == "Generator" then
                    -- Detect Progress
                    local prog = obj:FindFirstChild("Progress") or obj:FindFirstChild("Repairs")
                    if prog and prog:IsA("IntValue") or prog:IsA("NumberValue") then
                        finalLabel = finalLabel .. string.format(" [%d%%]", prog.Value)
                    end
                end
                
                local objColor = Config.ESP.Colors[configFlag] or Color3.fromRGB(255, 255, 255)
                if Config.ESP.Chams[configFlag] then createHighlight(obj, objColor) else removeHighlight(obj) end
                if Config.ESP.Text[configFlag] then createLabel(obj, finalLabel, objColor) else removeLabel(obj) end
            end
        end
    end)
end

local function updateAllESP()
    local currentTime = tick()
    if currentTime - LastUpdate < Config.Performance.UpdateRate then return end
    LastUpdate = currentTime
    
    local espCount = 0
    for obj, h in pairs(Highlights) do
        if not validateInstance(obj) or not validateInstance(h) then Highlights[obj] = nil else espCount = espCount + 1 end
    end
    for obj, gui in pairs(BillboardGuis) do
        if not validateInstance(obj) or not validateInstance(gui) then BillboardGuis[obj] = nil end
    end
    if espCount >= Config.Performance.MaxESPObjects then return end
    
    updatePlayerESP()
    updateObjectESP("Generator", "Generator", "[GENERATOR]")
    updateObjectESP("Gate", "Gate", "[EXIT GATE]")
    updateObjectESP("Hook", "Hook", "[HOOK]")
    updateObjectESP("Pallet", "Pallet", "[PALLET]")
    updateObjectESP("Window", "Window", "[WINDOW]")
end

getgenv().startESP = function()
    if UpdateConnection then return end
    UpdateConnection = RunService.Heartbeat:Connect(updateAllESP)
    notify("ESP Started", "System ESP diaktifkan", 2)
end

getgenv().stopESP = function()
    if UpdateConnection then UpdateConnection:Disconnect() UpdateConnection = nil end
    clearAllESP()
    notify("ESP Stopped", "Semua ESP dimatikan", 2)
end

-- ================== AIMBOT ENGINE (FORKT-HUB PORT) ==================
local function setupFOVCircle()
    if not FOVCircle and Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        FOVCircle.Thickness = 1.5
    end
end

local function getAimbotTarget()
    local targetDist = math.huge
    local targetObj = nil
    
    local teamFilter = Config.Aimbot.Target == "Killer" and "Killer" or "Survivors"
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team and player.Team.Name == teamFilter and player.Character then
            local part = player.Character:FindFirstChild(Config.Aimbot.Part)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distToCenter = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if distToCenter < Config.Aimbot.Radius then
                        local realDist = (Camera.CFrame.Position - part.Position).Magnitude
                        if realDist <= Config.Aimbot.MaxDistance and distToCenter < targetDist then
                            targetDist = distToCenter
                            targetObj = part
                        end
                    end
                end
            end
        end
    end
    return targetObj
end

getgenv().startAimbotEngine = function()
    if AimbotConnection then return end
    setupFOVCircle()
    AimbotConnection = RunService.RenderStepped:Connect(function()
        if FOVCircle then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Radius = Config.Aimbot.Radius
            FOVCircle.Visible = Config.Aimbot.ShowFOV
        end
        
        if Config.Aimbot.Enabled then
            local closest = getAimbotTarget()
            if closest then
                local targetPos = closest.Position
                local currentCamPos = Camera.CFrame.Position
                local newCFrame = CFrame.new(currentCamPos, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Config.Aimbot.Smoothness)
            end
        end
    end)
end

getgenv().stopAimbotEngine = function()
    if AimbotConnection then AimbotConnection:Disconnect() AimbotConnection = nil end
    if FOVCircle then FOVCircle.Visible = false end
end

-- ================== AUTO PARRY & MOONWALK ==================
getgenv().startAutoParry = function()
    spawn(function()
        while Config.Combat.AutoParry do
            local hrp = getCharacterRootPart()
            if hrp then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Team and player.Team.Name == "Killer" and player.Character then
                        local khrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if khrp then
                            local dist = (khrp.Position - hrp.Position).Magnitude
                            if dist < 12 then -- Attack range estimation
                                if keypress then
                                    task.wait(Config.Combat.ParryDelay)
                                    keypress(0x45) -- 'E' key
                                    task.wait(0.05)
                                    keyrelease(0x45)
                                    task.wait(1) -- Cooldown
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

getgenv().startMoonwalk = function()
    spawn(function()
        while Config.Combat.Moonwalk do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                if char.Humanoid.MoveDirection.Magnitude > 0 then
                    local bv = char.HumanoidRootPart:FindFirstChild("WolfMoonwalk")
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "WolfMoonwalk"
                        bv.MaxForce = Vector3.new(100000, 0, 100000)
                        bv.Parent = char.HumanoidRootPart
                    end
                    local backwards = -char.HumanoidRootPart.CFrame.LookVector
                    bv.Velocity = Vector3.new(backwards.X * Config.Combat.BoostPower, char.HumanoidRootPart.Velocity.Y, backwards.Z * Config.Combat.BoostPower)
                else
                    local bv = char.HumanoidRootPart:FindFirstChild("WolfMoonwalk")
                    if bv then bv:Destroy() end
                end
            end
            RunService.RenderStepped:Wait()
        end
        -- Cleanup
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local bv = char.HumanoidRootPart:FindFirstChild("WolfMoonwalk")
            if bv then bv:Destroy() end
        end
    end)
end

-- ================== AUTO FARM ==================
getgenv().startAutoFarmGen = function()
    spawn(function()
        while Config.AutoFeatures.AutoGenerator do
            local map = Workspace:FindFirstChild("Map")
            if map then
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("Generator") then
                    local repairEvent = remotes.Generator:FindFirstChild("RepairEvent")
                    local skillCheckEvent = remotes.Generator:FindFirstChild("SkillCheckResultEvent")
                    
                    if repairEvent and skillCheckEvent then
                        for _, obj in ipairs(map:GetDescendants()) do
                            if obj:IsA("Model") and obj.Name == "Generator" and Config.AutoFeatures.AutoGenerator then
                                for _, point in ipairs(obj:GetChildren()) do
                                    if point.Name:find("GeneratorPoint") then
                                        pcall(function()
                                            repairEvent:FireServer(point, true)
                                            skillCheckEvent:FireServer("success", 1, obj, point)
                                        end)
                                    end
                                end
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end

getgenv().startAutoHeal = function()
    spawn(function()
        while Config.AutoFeatures.AutoHeal do
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes and remotes:FindFirstChild("Healing") then
                local healEvent = remotes.Healing:FindFirstChild("HealEvent")
                if healEvent then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Team and player.Team.Name == "Survivors" and player.Character then
                            local hum = player.Character:FindFirstChild("Humanoid")
                            if hum and hum.Health < hum.MaxHealth then
                                pcall(function() healEvent:FireServer(player.Character) end)
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end

getgenv().startAutoSkillCheck = function()
    spawn(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")
        while Config.AutoFeatures.AutoSkillCheck do
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    -- Detect SkillCheck prompt
                    local prompt = playerGui:FindFirstChild("SkillCheckPromptGui", true) or playerGui:FindFirstChild("CheckGui", true)
                    if prompt and prompt.Visible then
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("Generator") then
                            local skillCheckEvent = remotes.Generator:FindFirstChild("SkillCheckResultEvent")
                            if skillCheckEvent then
                                skillCheckEvent:FireServer("success", 1)
                                prompt.Visible = false -- Prevent spam firing multiple times for the same check
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end)
            task.wait(0.02) -- Fast check
        end
    end)
end

-- Auto Start Engine Services
getgenv().startAimbotEngine()


local Fun = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/nightmares.fun-UI-Library/main/source.lua"))()

getgenv().OctoNotify = function(title, content, duration)
    print("["..title.."] " .. content)
end

local window = Fun.Create("Wolf Family Hub V0.0.0.3")

-- Mobile Optimization (Centering UI, Lock, Minimize, Close)
spawn(function()
    local sg = game:GetService("CoreGui"):WaitForChild("nightmarefun", 5)
    if sg then
        local shadow = sg:FindFirstChild("Shadow")
        if shadow then
            shadow.AnchorPoint = Vector2.new(0.5, 0.5)
            shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            local uiScale = Instance.new("UIScale")
            uiScale.Parent = shadow
            uiScale.Scale = 0.75
            
            local minIcon = Instance.new("ImageButton")
            minIcon.Name = "WolfHubIcon"
            minIcon.Size = UDim2.new(0, 50, 0, 50)
            minIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
            minIcon.Image = "rbxassetid://4483345998"
            minIcon.BackgroundTransparency = 1
            minIcon.Visible = false
            minIcon.Parent = sg
            
            local minDragging, minDragInput, minMousePos, minFramePos
            minIcon.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    minDragging = true
                    minMousePos = input.Position
                    minFramePos = minIcon.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then minDragging = false end
                    end)
                end
            end)
            minIcon.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then minDragInput = input end
            end)
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input == minDragInput and minDragging then
                    local delta = input.Position - minMousePos
                    minIcon.Position = UDim2.new(minFramePos.X.Scale, minFramePos.X.Offset + delta.X, minFramePos.Y.Scale, minFramePos.Y.Offset + delta.Y)
                end
            end)
            
            minIcon.MouseButton1Click:Connect(function()
                shadow.Visible = true
                minIcon.Visible = false
            end)

            -- Buttons Container Setup
            local locked = false

            local lockBtn = Instance.new("TextButton")
            lockBtn.Size = UDim2.new(0, 30, 0, 30)
            lockBtn.Position = UDim2.new(1, -105, 0, 5)
            lockBtn.Text = "🔓"
            lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            lockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            lockBtn.BorderSizePixel = 0
            lockBtn.Font = Enum.Font.GothamBold
            lockBtn.TextSize = 14
            lockBtn.ZIndex = 999
            lockBtn.Parent = shadow
            local lockCorner = Instance.new("UICorner")
            lockCorner.CornerRadius = UDim.new(0, 5)
            lockCorner.Parent = lockBtn

            lockBtn.MouseButton1Click:Connect(function()
                locked = not locked
                if locked then
                    lockBtn.Text = "🔒"
                else
                    lockBtn.Text = "🔓"
                end
            end)

            local minimizeBtn = Instance.new("TextButton")
            minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
            minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
            minimizeBtn.Text = "-"
            minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            minimizeBtn.BorderSizePixel = 0
            minimizeBtn.Font = Enum.Font.GothamBold
            minimizeBtn.TextSize = 18
            minimizeBtn.ZIndex = 999
            minimizeBtn.Parent = shadow
            local minCorner = Instance.new("UICorner")
            minCorner.CornerRadius = UDim.new(0, 5)
            minCorner.Parent = minimizeBtn
            
            minimizeBtn.MouseButton1Click:Connect(function()
                shadow.Visible = false
                minIcon.Visible = true
            end)

            local closeBtn = Instance.new("TextButton")
            closeBtn.Size = UDim2.new(0, 30, 0, 30)
            closeBtn.Position = UDim2.new(1, -35, 0, 5)
            closeBtn.Text = "X"
            closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
            closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            closeBtn.BorderSizePixel = 0
            closeBtn.Font = Enum.Font.GothamBold
            closeBtn.TextSize = 18
            closeBtn.ZIndex = 999
            closeBtn.Parent = shadow
            local closeCorner = Instance.new("UICorner")
            closeCorner.CornerRadius = UDim.new(0, 5)
            closeCorner.Parent = closeBtn
            
            closeBtn.MouseButton1Click:Connect(function()
                sg:Destroy()
            end)

            -- Custom Drag Logic (Restricted to Top Bar)
            local dragBar = Instance.new("Frame")
            dragBar.Size = UDim2.new(1, -120, 0, 30)
            dragBar.Position = UDim2.new(0, 0, 0, 0)
            dragBar.BackgroundTransparency = 1
            dragBar.Parent = shadow
            
            local uiDragging, uiDragInput, uiMousePos, uiFramePos
            
            dragBar.InputBegan:Connect(function(input)
                if locked then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    uiDragging = true
                    uiMousePos = input.Position
                    uiFramePos = shadow.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then uiDragging = false end
                    end)
                end
            end)
            
            dragBar.InputChanged:Connect(function(input)
                if locked then return end
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then uiDragInput = input end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input == uiDragInput and uiDragging and not locked then
                    local delta = input.Position - uiMousePos
                    shadow.Position = UDim2.new(uiFramePos.X.Scale, uiFramePos.X.Offset + delta.X, uiFramePos.Y.Scale, uiFramePos.Y.Offset + delta.Y)
                end
            end)
        end
    end
end)

local Config = getgenv().Config
local activeCheats = getgenv().activeCheats

-- ================== ESP TAB ==================
local ESPTab = window:Tab("ESP")
local ESPChamsSection = ESPTab:Section("ESP Highlights (Chams)")

ESPChamsSection:Toggle("Killer (Red)", function(Value) Config.ESP.Chams.Killer = Value if Value then getgenv().startESP() end end)
ESPChamsSection:Toggle("Survivor (Green)", function(Value) Config.ESP.Chams.Survivor = Value if Value then getgenv().startESP() end end)
ESPChamsSection:Toggle("Generator (Orange)", function(Value) Config.ESP.Chams.Generator = Value if Value then getgenv().startESP() end end)
ESPChamsSection:Toggle("Gate (White)", function(Value) Config.ESP.Chams.Gate = Value if Value then getgenv().startESP() end end)
ESPChamsSection:Toggle("Hook (Red)", function(Value) Config.ESP.Chams.Hook = Value if Value then getgenv().startESP() end end)
ESPChamsSection:Toggle("Pallet (Yellow)", function(Value) Config.ESP.Chams.Pallet = Value if Value then getgenv().startESP() end end)
ESPChamsSection:Toggle("Window (Blue)", function(Value) Config.ESP.Chams.Window = Value if Value then getgenv().startESP() end end)

local ESPColorSection = ESPTab:Section("ESP Colors (R,G,B)")
local function updateColor(target, text)
    local r,g,b = text:match("(%d+),(%d+),(%d+)")
    if r and g and b then Config.ESP.Colors[target] = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)) getgenv().startESP() end
end

ESPColorSection:TextBox("Killer Color", function(text) updateColor("Killer", text) end)
ESPColorSection:TextBox("Survivor Color", function(text) updateColor("Survivor", text) end)
ESPColorSection:TextBox("Generator Color", function(text) updateColor("Generator", text) end)
ESPColorSection:TextBox("Gate Color", function(text) updateColor("Gate", text) end)
ESPColorSection:TextBox("Hook Color", function(text) updateColor("Hook", text) end)
ESPColorSection:TextBox("Pallet Color", function(text) updateColor("Pallet", text) end)
ESPColorSection:TextBox("Window Color", function(text) updateColor("Window", text) end)

local ESPTextSection = ESPTab:Section("ESP Text (Names)")

ESPTextSection:Toggle("Killer Text", function(Value) Config.ESP.Text.Killer = Value if Value then getgenv().startESP() end end)
ESPTextSection:Toggle("Survivor Text", function(Value) Config.ESP.Text.Survivor = Value if Value then getgenv().startESP() end end)
ESPTextSection:Toggle("Generator Text", function(Value) Config.ESP.Text.Generator = Value if Value then getgenv().startESP() end end)
ESPTextSection:Toggle("Gate Text", function(Value) Config.ESP.Text.Gate = Value if Value then getgenv().startESP() end end)
ESPTextSection:Toggle("Hook Text", function(Value) Config.ESP.Text.Hook = Value if Value then getgenv().startESP() end end)
ESPTextSection:Toggle("Pallet Text", function(Value) Config.ESP.Text.Pallet = Value if Value then getgenv().startESP() end end)
ESPTextSection:Toggle("Window Text", function(Value) Config.ESP.Text.Window = Value if Value then getgenv().startESP() end end)

local ESPMiscSection = ESPTab:Section("Misc ESP")
ESPMiscSection:Toggle("Show Distance", function(Value) Config.ESP.ShowDistance = Value end)
ESPMiscSection:Slider("Max Distance", 100, 1000, function(Value) Config.ESP.MaxDistance = Value end)
ESPMiscSection:Button("Clear All ESP", function() getgenv().stopESP() end)

-- ================== AIMBOT TAB ==================
local AimbotTab = window:Tab("Aimbot")
local AimbotSection = AimbotTab:Section("Aimbot Settings")

AimbotSection:Toggle("Enable Aimbot (Hold RM / Touch)", function(Value) Config.Aimbot.Enabled = Value end)
AimbotSection:Toggle("Show FOV Circle", function(Value) Config.Aimbot.ShowFOV = Value end)

local teamOpts = {"Killer", "Survivors"}
local teamIdx = 1
AimbotSection:Button("Cycle Target Team (Current: Killer)", function()
    teamIdx = teamIdx + 1
    if teamIdx > #teamOpts then teamIdx = 1 end
    Config.Aimbot.Target = teamOpts[teamIdx]
    getgenv().OctoNotify("Aimbot", "Target Team set to: " .. Config.Aimbot.Target, 2)
end)

local partOpts = {"Torso", "Head", "HumanoidRootPart"}
local partIdx = 1
AimbotSection:Button("Cycle Target Part (Current: Torso)", function()
    partIdx = partIdx + 1
    if partIdx > #partOpts then partIdx = 1 end
    Config.Aimbot.Part = partOpts[partIdx]
    getgenv().OctoNotify("Aimbot", "Target Part set to: " .. Config.Aimbot.Part, 2)
end)

AimbotSection:Slider("FOV Radius", 50, 500, function(Value) Config.Aimbot.Radius = Value end)
AimbotSection:Slider("Smoothness", 0, 1, function(Value) Config.Aimbot.Smoothness = Value end)

-- ================== COMBAT TAB ==================
local CombatTab = window:Tab("Combat")
local CombatSection = CombatTab:Section("Modifications")

CombatSection:Toggle("Auto Parry (E)", function(Value) 
    Config.Combat.AutoParry = Value 
    if Value then getgenv().startAutoParry() end
end)
CombatSection:Slider("Parry Delay", 0, 1, function(Value) Config.Combat.ParryDelay = Value end)

CombatSection:Toggle("God Mode", function(Value)
    activeCheats["God Mode"] = Value
    if Value then
        spawn(function()
            while activeCheats["God Mode"] do
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    if char.Humanoid.Health <= 1 then char.Humanoid.Health = 100 end
                end
                wait(0.1)
            end
        end)
    end
end)

CombatSection:Toggle("Infinite Ammo", function(Value)
    activeCheats["Infinite Ammo"] = Value
    if Value then
        spawn(function()
            while activeCheats["Infinite Ammo"] do
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Backpack") then
                    for _, weapon in ipairs(char.Backpack:GetChildren()) do if weapon:IsA("Tool") and weapon:FindFirstChild("Ammo") then weapon.Ammo.Value = 999 end end
                    for _, weapon in ipairs(char:GetChildren()) do if weapon:IsA("Tool") and weapon:FindFirstChild("Ammo") then weapon.Ammo.Value = 999 end end
                end
                wait(0.5)
            end
        end)
    end
end)

CombatSection:Toggle("Damage Boost", function(Value)
    activeCheats["Damage Boost"] = Value
    if Value then
        spawn(function()
            while activeCheats["Damage Boost"] do
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Backpack") then
                    for _, weapon in ipairs(char.Backpack:GetChildren()) do if weapon:IsA("Tool") and weapon:FindFirstChild("Damage") then weapon.Damage.Value = weapon.Damage.Value * 2 end end
                    for _, weapon in ipairs(char:GetChildren()) do if weapon:IsA("Tool") and weapon:FindFirstChild("Damage") then weapon.Damage.Value = weapon.Damage.Value * 2 end end
                end
                wait(1)
            end
        end)
    end
end)

-- ================== MOVEMENT TAB ==================
local MovementTab = window:Tab("Movement")
local MoveSection = MovementTab:Section("Main")

MoveSection:Slider("Speed Hack Value", 16, 150, function(Value) Config.Movement.Speed = Value end)

MoveSection:Toggle("Speed Hack", function(Value)
    activeCheats["Speed Hack"] = Value
    if Value then
        spawn(function()
            while activeCheats["Speed Hack"] do
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then 
                    char.Humanoid.WalkSpeed = Config.Movement.Speed 
                    char.Humanoid.JumpPower = 50 
                end
                wait(0.1)
            end
        end)
    else
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 16 char.Humanoid.JumpPower = 50 end
    end
end)

MoveSection:Toggle("Moonwalk Boost", function(Value)
    Config.Combat.Moonwalk = Value
    if Value then getgenv().startMoonwalk() end
end)
MoveSection:Slider("Moonwalk Power", 10, 200, function(Value) Config.Combat.BoostPower = Value end)

MoveSection:Toggle("No Clip", function(Value)
    activeCheats["No Clip"] = Value
    if Value then
        spawn(function()
            while activeCheats["No Clip"] do
                local char = game.Players.LocalPlayer.Character
                if char then
                    if char:FindFirstChild("Animate") then char.Animate.Disabled = true end
                    if char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown) end
                end
                wait(0.1)
            end
        end)
    else
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Animate") then char.Animate.Disabled = false end
    end
end)

-- ================== ADVANCED TAB ==================
local AdvancedTab = window:Tab("Advanced")
local GameSection = AdvancedTab:Section("Gameplay Loops")

GameSection:Toggle("Auto Perfect Skill Check", function(Value)
    Config.AutoFeatures.AutoSkillCheck = Value
    if Value then getgenv().startAutoSkillCheck() end
end)

GameSection:Toggle("Auto Farm Generator Loop", function(Value)
    Config.AutoFeatures.AutoGenerator = Value
    if Value then getgenv().startAutoFarmGen() end
end)

GameSection:Toggle("Auto Heal All Survivors", function(Value)
    Config.AutoFeatures.AutoHeal = Value
    if Value then getgenv().startAutoHeal() end
end)

GameSection:Toggle("Auto Attack Nearby Survivors", function(Value)
    Config.AutoFeatures.AutoAttack = Value
end)

GameSection:Slider("Auto Attack Range", 5, 20, function(Value)
    Config.AutoFeatures.AttackRange = Value
end)

local OptSection = AdvancedTab:Section("Optimization")
OptSection:Button("Optimize Graphics", function()
    pcall(function()
        game.Lighting.GlobalShadows = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj.Enabled = false end
        end
        getgenv().OctoNotify("Performance", "Graphics Optimized for Mobile/Low End PC", 3)
    end)
end)

-- ================== DEVELOPER TAB ==================
local DevTab = window:Tab("Developer")
local DevSection = DevTab:Section("Tools")

DevSection:Button("Reset All Cheats (Off)", function()
    for key, _ in pairs(activeCheats) do activeCheats[key] = false end
    getgenv().stopESP()
    getgenv().stopAimbotEngine()
    Config.Combat.AutoParry = false
    Config.Combat.Moonwalk = false
    Config.AutoFeatures.AutoGenerator = false
    Config.AutoFeatures.AutoHeal = false
    local char = game.Players.LocalPlayer.Character
    if char then
        if char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 16 end
        if char:FindFirstChild("Animate") then char.Animate.Disabled = false end
    end
end)

