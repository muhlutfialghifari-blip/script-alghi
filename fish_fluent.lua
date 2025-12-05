-- =========================================================
-- SCRIPT FISH IT - MINIMALIST MOBILE VERSION
-- Fitur: Draggable Button, Auto-Stop on Close, Compact UI
-- =========================================================

-- 1. GLOBAL KILL SWITCH (Untuk mematikan fitur total)
getgenv().ScriptActive = true 

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- 2. TAMPILAN LEBIH KECIL (MINIMALIS)
local Window = Fluent:CreateWindow({
    Title = "Fish Hub", -- Judul pendek biar rapi
    SubTitle = "Mobile",
    TabWidth = 120, -- Lebar tab diperkecil
    Size = UDim2.fromOffset(420, 320), -- UKURAN DI PERKECIL (Pas buat HP)
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Fish", Icon = "fish" }),
    Farm = Window:AddTab({ Title = "Maps", Icon = "map" }),
    Player = Window:AddTab({ Title = "Fly", Icon = "plane" }),
    Settings = Window:AddTab({ Title = "System", Icon = "settings" })
}

local Options = Fluent.Options
local NetFolder -- Variabel untuk remote events

-- Fungsi mencari Remote Event otomatis
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
-- TAB 1: FISHING (AUTO STOP INTEGRATED)
-- ==============================

local CastStrength = Tabs.Main:AddSlider("CastStrength", {
    Title = "Power Lempar",
    Default = 100, Min = 10, Max = 100, Rounding = 1
})

local ToggleCast = Tabs.Main:AddToggle("AutoCast", {Title = "Auto Cast (Lempar)", Default = false })

ToggleCast:OnChanged(function()
    task.spawn(function()
        -- Loop Cek: Apakah tombol nyala DAN Script masih aktif?
        while Options.AutoCast.Value and getgenv().ScriptActive do
            local folder = getNet()
            if folder then
                local event = folder:FindFirstChild("RF/RequestFishingMinigameStarted")
                if event then
                    event:InvokeServer(unpack({Options.CastStrength.Value, 1.0, tick()}))
                end
            end
            task.wait(3.5)
        end
    end)
end)

local ToggleCatch = Tabs.Main:AddToggle("InstantCatch", {Title = "Auto Catch (Tangkap)", Default = false })

ToggleCatch:OnChanged(function()
    task.spawn(function()
        while Options.InstantCatch.Value and getgenv().ScriptActive do
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
end)

-- ==============================
-- TAB 2: TELEPORT
-- ==============================
Tabs.Farm:AddButton({
    Title = "Teleport Spawn",
    Callback = function()
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end
    end
})

-- ==============================
-- TAB 3: FLY (JOYSTICK)
-- ==============================
local flySpeed = 50
Tabs.Player:AddSlider("FlySpeed", {
    Title = "Kecepatan Fly", Default = 50, Min = 10, Max = 150, Rounding = 1,
    Callback = function(v) flySpeed = v end
})

local ToggleFly = Tabs.Player:AddToggle("FlyMode", {Title = "Fitur Terbang", Default = false })

ToggleFly:OnChanged(function()
    local state = Options.FlyMode.Value
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")

    if state and getgenv().ScriptActive then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVel"
        bv.Parent = hrp
        bv.MaxForce = Vector3.new(Math.huge, Math.huge, Math.huge)
        bv.Velocity = Vector3.new(0,0,0)
        humanoid.PlatformStand = true 
        
        task.spawn(function()
            -- Loop akan mati otomatis jika ScriptActive jadi false
            while Options.FlyMode.Value and char and getgenv().ScriptActive do
                local cam = workspace.CurrentCamera
                if humanoid.MoveDirection.Magnitude > 0 then
                    bv.Velocity = cam.CFrame.LookVector * flySpeed
                else
                    bv.Velocity = Vector3.new(0,0,0)
                end
                task.wait()
            end
            -- Bersihkan jika loop berhenti
            if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
            humanoid.PlatformStand = false
        end)
    else
        if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
        humanoid.PlatformStand = false
    end
end)

-- ==============================
-- TAB 4: SYSTEM (MATIKAN TOTAL)
-- ==============================
Tabs.Settings:AddButton({
    Title = "❌ Matikan Script & Tutup",
    Description = "Klik ini untuk mematikan semua fitur & menutup menu",
    Callback = function()
        -- 1. Matikan Global Switch
        getgenv().ScriptActive = false 
        
        -- 2. Matikan semua toggle visual
        Options.AutoCast:SetValue(false)
        Options.InstantCatch:SetValue(false)
        Options.FlyMode:SetValue(false)
        
        -- 3. Hapus UI
        Fluent:Destroy()
        
        -- 4. Hapus Tombol HP
        if game.Players.LocalPlayer.PlayerGui:FindFirstChild("TombolMenuAlghi") then
            game.Players.LocalPlayer.PlayerGui.TombolMenuAlghi:Destroy()
        end
        
        print("Script dimatikan total.")
    end
})

-- ==============================
-- TOMBOL HP: DRAGGABLE (BISA DIGESER)
-- ==============================
spawn(function()
    -- Hapus tombol lama jika ada
    if game.Players.LocalPlayer.PlayerGui:FindFirstChild("TombolMenuAlghi") then
        game.Players.LocalPlayer.PlayerGui.TombolMenuAlghi:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TombolMenuAlghi"
    ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false
    
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 45, 0, 45) -- Lebih kecil dikit
    Btn.Position = UDim2.new(0, 20, 0.4, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    Btn.Text = "M"
    Btn.TextSize = 20
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.FredokaOne
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1,0)
    Corner.Parent = Btn
    
    -- LOGIKA DRAG (BISA DIGESER)
    local UserInputService = game:GetService("UserInputService")
    local dragging
    local dragInput
    local dragStart
    local startPos

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
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- FUNGSI KLIK: Buka/Tutup Menu
    Btn.MouseButton1Click:Connect(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait()
        game:GetService("Virtual