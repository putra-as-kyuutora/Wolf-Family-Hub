-- Wolf Family Cheat Base with Orion UI

-- Place ID Lock
local TARGET_PLACE_ID = 93978595733734 -- Place ID Violence District
if game.PlaceId ~= TARGET_PLACE_ID and TARGET_PLACE_ID ~= 93978595733734 then
    -- Jika bukan 123456789 dan bukan Place ID target, batalkan eksekusi
    warn("Wolf Family Hub: Incorrect Place ID. Script stopped.")
    return
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

if game.PlaceId ~= TARGET_PLACE_ID then
    OrionLib:MakeNotification({
        Name = "Peringatan Place ID",
        Content = "Script dijalankan di luar Violence District! (Place ID belum diatur)",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end

local Window = OrionLib:MakeWindow({Name = "Wolf Family Hub - Violence District", HidePremium = false, SaveConfig = true, ConfigFolder = "WolfFamilyHub"})

-- Cheat Status Tracking
local activeCheats = {}

-- Tabs
local CombatTab = Window:MakeTab({
	Name = "Combat",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local MovementTab = Window:MakeTab({
	Name = "Movement",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local DevTab = Window:MakeTab({
	Name = "Developer",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- ================== COMBAT TAB ==================
CombatTab:AddToggle({
	Name = "God Mode",
	Default = false,
	Callback = function(Value)
		activeCheats["God Mode"] = Value
        if Value then
            spawn(function()
                while activeCheats["God Mode"] do
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        if char.Humanoid.Health <= 1 then
                            char.Humanoid.Health = 100
                        end
                    end
                    wait(0.1)
                end
            end)
        end
	end    
})

CombatTab:AddToggle({
	Name = "Infinite Ammo",
	Default = false,
	Callback = function(Value)
		activeCheats["Infinite Ammo"] = Value
        if Value then
            spawn(function()
                while activeCheats["Infinite Ammo"] do
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Backpack") then
                        for _, weapon in ipairs(char.Backpack:GetChildren()) do
                            if weapon:IsA("Tool") and weapon:FindFirstChild("Ammo") then
                                weapon.Ammo.Value = 999
                            end
                        end
                        -- Check equipped weapon
                        for _, weapon in ipairs(char:GetChildren()) do
                            if weapon:IsA("Tool") and weapon:FindFirstChild("Ammo") then
                                weapon.Ammo.Value = 999
                            end
                        end
                    end
                    wait(0.5)
                end
            end)
        end
	end    
})

CombatTab:AddToggle({
	Name = "Damage Boost",
	Default = false,
	Callback = function(Value)
		activeCheats["Damage Boost"] = Value
        if Value then
            spawn(function()
                while activeCheats["Damage Boost"] do
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Backpack") then
                        for _, weapon in ipairs(char.Backpack:GetChildren()) do
                            if weapon:IsA("Tool") and weapon:FindFirstChild("Damage") then
                                weapon.Damage.Value = weapon.Damage.Value * 2
                            end
                        end
                        for _, weapon in ipairs(char:GetChildren()) do
                            if weapon:IsA("Tool") and weapon:FindFirstChild("Damage") then
                                weapon.Damage.Value = weapon.Damage.Value * 2
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
	end    
})

-- ================== MOVEMENT TAB ==================
MovementTab:AddToggle({
	Name = "Speed Hack",
	Default = false,
	Callback = function(Value)
		activeCheats["Speed Hack"] = Value
        if Value then
            spawn(function()
                while activeCheats["Speed Hack"] do
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.WalkSpeed = 50
                        char.Humanoid.JumpPower = 50
                    end
                    wait(0.1)
                end
            end)
        else
            -- Reset to default when turned off
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
                char.Humanoid.JumpPower = 50
            end
        end
	end    
})

MovementTab:AddToggle({
	Name = "No Clip",
	Default = false,
	Callback = function(Value)
		activeCheats["No Clip"] = Value
        if Value then
            spawn(function()
                while activeCheats["No Clip"] do
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        if char:FindFirstChild("Animate") then
                            char.Animate.Disabled = true
                        end
                        if char:FindFirstChild("Humanoid") then
                            char.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
                        end
                    end
                    wait(0.1)
                end
            end)
        else
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Animate") then
                char.Animate.Disabled = false
            end
        end
	end    
})

-- ================== DEVELOPER TAB ==================
DevTab:AddToggle({
	Name = "Remote Spy",
	Default = false,
	Callback = function(Value)
		shared.RemoteSpyActive = Value
        if Value then
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
})

DevTab:AddButton({
	Name = "Reset All Cheats (Off)",
	Callback = function()
      	for key, _ in pairs(activeCheats) do
            activeCheats[key] = false
        end
        shared.RemoteSpyActive = false
        
        -- Reset some states
        local char = game.Players.LocalPlayer.Character
        if char then
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
            end
            if char:FindFirstChild("Animate") then
                char.Animate.Disabled = false
            end
        end
  	end    
})

-- Initialize Orion
OrionLib:Init()
