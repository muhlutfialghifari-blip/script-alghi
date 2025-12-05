-- =========================================================
-- SCRIPT FISH IT - FULL SETTINGS GUI (SLIDERS ADDED)
-- Author: Alghi
-- =========================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fish It Hub " .. Fluent.Version,
    SubTitle = "by Alghi",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Farm = Window:AddTab({ Title = "Auto Farm", Icon = "dollar-sign" }),
    Player = Window:AddTab({ Title = "Player & Fly", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ==============================
-- TAB 1: FISHING (DENGAN PENGATURAN)
-- ==============================

Tabs.Main:AddParagraph({
    Title = "Pengaturan Pancing",
    Content = "Atur slider di bawah ini sesuai selera sebelum mengaktifkan Auto."
})

-- 1. PENGATURAN LEMPAR (CAST)
local CastStrength = Tabs.Main:AddSlider("CastStrength", {
    Title = "Kekuatan Lempar",
    Description = "1 = Normal, 100 = Sangat Jauh",
    Default = 1.0,
    Min = 0.5,
    Max = 100.0,
    Rounding = 1,
})

local CastDelay = Tabs.Main:AddSlider("CastDelay", {
    Title = "Jeda Lempar (Detik)",
    Description = "Waktu tunggu sebelum melempar lagi",
    Default = 4.0,
    Min = 2.0,
    Max = 10.0,
    Rounding = 1,
})

local ToggleCast = Tabs.Main:AddToggle("AutoCast", {Title = "Auto Cast (Lempar Otomatis)", Default = false })

ToggleCast:OnChanged(function()
    task.spawn(function()
        while Options.AutoCast.Value do
            -- Mengambil nilai dari Slider di atas
            local strength = Options.CastStrength.Value
            
            local argsCast = {
                [1] = strength, -- Pakai nilai slider
                [2] = 1.0, 
                [3] = tick()
            }
            
            local event = game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_net@0.2.0").net:FindFirstChild("RF/RequestFishingMinigameStarted")
            if event then
                event:InvokeServer(unpack(argsCast))
                print("🎣 Melempar dengan kekuatan:", strength)
            end

            -- Tunggu sesuai slider delay
            task.wait(Options.CastDelay.Value)
        end
    end)
end)

-- 2. PENGATURAN TANGKAP (REEL)
Tabs.Main:AddParagraph({
    Title = "Pengaturan Tangkap",
    Content = "Hati-hati! Jika terlalu cepat bisa disconnect."
})

local CatchDelay = Tabs.Main:AddSlider("CatchDelay", {
    Title = "Jeda Instant Catch",
    Description = "Semakin kecil semakin cepat (Bahaya Kick)",
    Default = 0.5,
    Min = 0.1,
    Max = 2.0,
    Rounding = 2,
})

local ToggleReel = Tabs.Main:AddToggle("AutoReel", {Title = "Instant Catch (Langsung Dapat)", Default = false })

ToggleReel:OnChanged(function()
    task.spawn(function()
        while Options.AutoReel.Value do
            local eventFinish = game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_net@0.2.0").net:FindFirstChild("RE/FishingCompleted")
            
            if eventFinish then
                eventFinish:FireServer()
                print("🐟 Ikan Ditangkap!")
            end
            
            -- Tunggu sesuai slider delay
            task.wait(Options.CatchDelay.Value) 
        end
    end)
end)


-- ==============================
-- TAB 2: AUTO FARM (TELEPORT)
-- ==============================
Tabs.Farm:AddButton({
    Title = "Teleport ke Spawn",
    Callback = function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
})

-- ==============================
-- TAB 3: PLAYER & FLY
-- ==============================
Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Kecepatan Lari",
    Default = 16, Min = 16, Max = 200, Rounding = 1,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

Tabs.Player:AddSlider("JumpPower", {
    Title = "Kekuatan Lompat",
    Default = 50, Min = 50, Max = 300, Rounding = 1,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

local ToggleFly = Tabs.Player:AddToggle("FlyMode", {Title = "Aktifkan Terbang (Fly)", Default = false })
local flySpeed = 50
Tabs.Player:AddSlider("FlySpeed", {
    Title = "Kecepatan Terbang", Default = 50, Min = 10, Max = 200, Rounding = 1,
    Callback = function(Value) flySpeed = Value end
})

ToggleFly:OnChanged(function()
    local flying = Options.FlyMode.Value
    if flying then
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local humanoid = char:WaitForChild("Humanoid")
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Velocity = Vector3.new(0,0,0)
        bv.MaxForce = Vector3.new(Math.huge, Math.huge, Math.huge)
        bv.Name = "FlyVelocity"
        humanoid.PlatformStand = true
        spawn(function()
            while flying and char and hrp do
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.new(0,0,0)
                if humanoid.MoveDirection.Magnitude > 0 then
                    moveDir = cam.CFrame.LookVector * flySpeed
                end
                bv.Velocity = moveDir
                task.wait()
            end
            if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
            humanoid.PlatformStand = false
        end)
    else
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local bv = char.HumanoidRootPart:FindFirstChild("FlyVelocity")
            if bv then bv:Destroy() end
            char.Humanoid.PlatformStand = false
        end
    end
end)

-- ==============================
-- SETUP & TOMBOL HP
-- ==============================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

-- Tombol Biru Darurat (HP)
spawn(function()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TombolMenuAlghi"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    local Tombol = Instance.new("TextButton")
    Tombol.Parent = ScreenGui
    Tombol.Size = UDim2.new(0, 50, 0, 50)
    Tombol.Position = UDim2.new(0, 20, 0.4, 0)
    Tombol.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    Tombol.Text = "MENU"
    Tombol.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tombol.BackgroundTransparency = 0.2
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Tombol
    Tombol.MouseButton1Click:Connect(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait()
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
    end)
end)

Fluent:Notify({
    Title = "Script Updated!",
    Content = "Sekarang kamu bisa atur kekuatan lempar di menu!",
    Duration = 5
})

