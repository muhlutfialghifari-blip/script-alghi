-- =========================================================
-- SCRIPT FISH IT - ORION MOBILE VERSION (FIXED)
-- Fitur: Ringan, Draggable Button, Kill Switch, Auto-Fish
-- =========================================================

-- Kill Switch Global
getgenv().ScriptActive = true

-- Memuat Library Orion (Lebih Ringan & Stabil di HP)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Fish Hub Mobile", 
    HidePremium = false, 
    SaveConfig = false, 
    ConfigFolder = "FishHubMobile",
    IntroEnabled = false -- Matikan intro biar cepat
})

-- Variabel Remote
local NetFolder
local function getNet()
    if NetFolder then return NetFolder end
    local RS = game:GetService("ReplicatedStorage")
    local packages = RS:FindFirstChild("Packages")
    if packages then
        local index = packages:FindFirstChild("_Index")
        if index then
            for _, child in pairs(index:GetChildren()) do
                if child.Name:find("net@") and child:FindFirstChild("net") then
                    NetFolder = child.net
                    return child.net
                end
            end
        end
    end
    return nil
end

-- ==============================
-- TAB 1: FISHING
-- ==============================
local TabFish = Window:MakeTab({Name = "Fishing", Icon = "rbxassetid://4483345998", PremiumOnly = false})

TabFish:AddSection({Name = "Fitur Utama"})

TabFish:AddToggle({
    Name = "Auto Cast (Lempar Otomatis)",
    Default = false,
    Callback = function(Value)
        getgenv().AutoCast = Value
        task.spawn(function()
            while getgenv().AutoCast and getgenv().ScriptActive do
                local folder = getNet()
                if folder then
                    local event = folder:FindFirstChild("RF/RequestFishingMinigameStarted")
                    if event then
                        -- Kekuatan lempar max (100)
                        event:InvokeServer(unpack({100, 1.0, tick()}))
                    end
                end
                task.wait(3.5)
            end
        end)
    end
})

TabFish:AddToggle({
    Name = "Instant Catch (Langsung Dapat)",
    Default = false,
    Callback = function(Value)
        getgenv().AutoCatch = Value
        task.spawn(function()
            while getgenv().AutoCatch and getgenv().ScriptActive do
                local folder = getNet()
                if folder then
                    local event = folder:FindFirstChild("RE/FishingCompleted")
                    if event then
                        event:FireServer()
                    end
                end
                task.wait(1.5)
            end
        end)
    end
})

-- ==============================
-- TAB 2: PLAYER & FLY
-- ==============================
local TabPlayer = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local flySpeed = 50
TabPlayer:AddSlider({
    Name = "Kecepatan Terbang",
    Min = 10, Max = 150, Default = 50, Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        flySpeed = Value
    end
})

TabPlayer:AddToggle({
    Name = "Aktifkan Terbang (Joystick)",
    Default = false,
    Callback = function(Value)
        getgenv().FlyMode = Value
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local humanoid = char:WaitForChild("Humanoid")

        if Value then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyVel"
            bv.Parent = hrp
            bv.MaxForce = Vector3.new(Math.huge, Math.huge, Math.huge)
            bv.Velocity = Vector3.new(0,0,0)
            humanoid.PlatformStand = true
            
            task.spawn(function()
                while getgenv().FlyMode and char and getgenv().ScriptActive do
                    local cam = workspace.CurrentCamera
                    if humanoid.MoveDirection.Magnitude > 0 then
                        bv.Velocity = cam.CFrame.LookVector * flySpeed
                    else
                        bv.Velocity = Vector3.new(0,0,0)
                    end
                    task.wait()
                end
                if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
                humanoid.PlatformStand = false
            end)
        else
            if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
            humanoid.PlatformStand = false
        end
    end
})

-- ==============================
-- TAB 3: SYSTEM (KILL SWITCH)
-- ==============================
local TabSys = Window:MakeTab({Name = "System", Icon = "rbxassetid://4483345998", PremiumOnly = false})

TabSys:AddButton({
    Name = "❌ MATIKAN SCRIPT (Tutup Total)",
    Callback = function()
        -- 1. Matikan Loop
        getgenv().ScriptActive = false
        getgenv().AutoCast = false
        getgenv().AutoCatch = false
        getgenv().FlyMode = false
        
        -- 2. Hapus UI
        OrionLib:Destroy()
        
        -- 3. Hapus Tombol HP
        if game.Players.LocalPlayer.PlayerGui:FindFirstChild("TombolMenuAlghi") then
            game.Players.LocalPlayer.PlayerGui.TombolMenuAlghi:Destroy()
        end
    end
})

-- ==============================
-- TOMBOL HP: DRAGGABLE (BISA DIGESER)
-- ==============================
spawn(function()
    if game.Players.LocalPlayer.PlayerGui:FindFirstChild("TombolMenuAlghi") then
        game.Players.LocalPlayer.PlayerGui.TombolMenuAlghi:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TombolMenuAlghi"
    ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false
    
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 45, 0, 45)
    Btn.Position = UDim2.new(0, 20, 0.4, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    Btn.Text = "M"
    Btn.TextColor3 = Color3.new(1,1,1)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1,0)
    Corner.Parent = Btn
    
    -- LOGIKA DRAG (BISA DIGESER)
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Btn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    Btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
    
    -- Fungsi Klik: Buka/Tutup Orion
    Btn.MouseButton1Click:Connect(function()
        -- Orion default keybind is RightControl, but we simulate standard toggle
        local ui = game:GetService("CoreGui"):FindFirstChild("Orion")
        if ui then
            ui.Enabled = not ui.Enabled
        end
    end)
end)

OrionLib:Init()