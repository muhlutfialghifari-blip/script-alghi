-- =========================================================
-- SCRIPT FISH IT - FULL VERSION (FLY + MOBILE BUTTON)
-- Author: Alghi
-- UI Library: Fluent (Windows 11 Style)
-- =========================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Membuat Jendela (Window)
local Window = Fluent:CreateWindow({
    Title = "Fish It Hub " .. Fluent.Version,
    SubTitle = "by Alghi",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- Dimatikan biar HP gak panas
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Tombol keyboard PC (kita ganti tombol HP nanti)
})

-- Membuat Tab Menu
local Tabs = {
    Main = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Farm = Window:AddTab({ Title = "Auto Farm", Icon = "dollar-sign" }),
    Player = Window:AddTab({ Title = "Player & Fly", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ==============================
-- TAB 1: FISHING
-- ==============================
Tabs.Main:AddParagraph({
    Title = "Fishing Tools",
    Content = "Aktifkan fitur ini saat memegang pancingan."
})

local ToggleCast = Tabs.Main:AddToggle("AutoCast", {Title = "Auto Cast (Lempar)", Default = false })
ToggleCast:OnChanged(function()
    print("Auto Cast:", Options.AutoCast.Value)
    -- Logika auto cast di sini (butuh RemoteEvent game)
end)

local ToggleReel = Tabs.Main:AddToggle("AutoReel", {Title = "Auto Reel (Tarik)", Default = false })

-- ==============================
-- TAB 2: AUTO FARM
-- ==============================
Tabs.Farm:AddButton({
    Title = "Teleport ke Spawn",
    Description = "Balik ke tempat awal",
    Callback = function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
})

Tabs.Farm:AddButton({
    Title = "Jual Semua Ikan",
    Description = "Teleport ke NPC Jual",
    Callback = function()
        Fluent:Notify({Title = "Info", Content = "Fitur sedang dibuat...", Duration = 3})
    end
})

-- ==============================
-- TAB 3: PLAYER & FLY (TERBARU)
-- ==============================

-- 1. Slider Kecepatan & Lompat
Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Kecepatan Lari",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

Tabs.Player:AddSlider("JumpPower", {
    Title = "Kekuatan Lompat",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 1,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

-- 2. FITUR FLY (TERBANG)
local flySpeed = 50
local flying = false
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local ToggleFly = Tabs.Player:AddToggle("FlyMode", {Title = "Aktifkan Terbang (Fly)", Default = false })

-- Slider Kecepatan Terbang
Tabs.Player:AddSlider("FlySpeed", {
    Title = "Kecepatan Terbang",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        flySpeed = Value
    end
})

-- Logika Terbang
ToggleFly:OnChanged(function()
    flying = Options.FlyMode.Value
    
    if flying then
        -- Mulai Terbang
        local plr = Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local humanoid = char:WaitForChild("Humanoid")
        
        -- Bikin karakter melayang (BodyVelocity)
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Velocity = Vector3.new(0,0,0)
        bv.MaxForce = Vector3.new(Math.huge, Math.huge, Math.huge)
        bv.Name = "FlyVelocity"
        
        -- Matikan gravitasi jatuh
        humanoid.PlatformStand = true
        
        -- Loop Gerakan Terbang (Mengikuti Kamera)
        spawn(function()
            while flying and char and hrp do
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.new(0,0,0)
                
                -- Maju mengikuti arah kamera lihat
                -- Di HP: Arahkan joystick maju untuk terbang ke arah kamera
                if humanoid.MoveDirection.Magnitude > 0 then
                    moveDir = cam.CFrame.LookVector * flySpeed
                else
                    moveDir = Vector3.new(0,0,0)
                end
                
                bv.Velocity = moveDir
                RunService.Heartbeat:Wait()
            end
            
            -- Hapus efek terbang kalau dimatikan
            if hrp:FindFirstChild("FlyVelocity") then
                hrp.FlyVelocity:Destroy()
            end
            humanoid.PlatformStand = false
        end)
    else
        -- Matikan Terbang
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local bv = char.HumanoidRootPart:FindFirstChild("FlyVelocity")
            if bv then bv:Destroy() end
            char.Humanoid.PlatformStand = false
        end
    end
end)

-- ==============================
-- SETUP AKHIR (SAVE & INTERFACE)
-- ==============================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

-- =========================================
-- !!! PENTING: TOMBOL DARURAT HP !!!
-- =========================================
-- Kode ini membuat tombol bulat biru di layar
-- Gunanya: Membuka menu jika tertutup/hilang
spawn(function()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TombolMenuAlghi"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    local Tombol = Instance.new("TextButton")
    Tombol.Parent = ScreenGui
    Tombol.Size = UDim2.new(0, 50, 0, 50) -- Ukuran 50x50
    Tombol.Position = UDim2.new(0, 20, 0.4, 0) -- Di kiri tengah
    Tombol.BackgroundColor3 = Color3.fromRGB(0, 120, 255) -- Warna Biru
    Tombol.Text = "MENU"
    Tombol.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tombol.BackgroundTransparency = 0.2
    
    -- Membulatkan Tombol
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Tombol

    -- Saat tombol ditekan: Pura-pura tekan Ctrl Kiri
    Tombol.MouseButton1Click:Connect(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait()
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
    end)
end)

Fluent:Notify({
    Title = "Script Alghi Loaded",
    Content = "Fly ditambahkan! Tekan tombol Biru untuk buka/tutup menu.",
    Duration = 5
})

