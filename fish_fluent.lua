-- Memuat Library UI (Orion Library - Stabil & Modern)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Fish It Hub - Fixed Version", HidePremium = false, SaveConfig = true, ConfigFolder = "FishItConfig", IntroText = "Loading Script..."})

-- // SERVICES & VARIABLES // --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Mengambil Path Remote yang kamu berikan agar tidak kepanjangan
local NetPath = ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0").net

-- // TABS // --
local TabFishing = Window:MakeTab({Name = "Fishing (Main)", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabWeather = Window:MakeTab({Name = "Weather", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabTeleport = Window:MakeTab({Name = "Teleport", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabPlayer = Window:MakeTab({Name = "Player & Utility", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabSettings = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- // NOTIFIKASI // --
function Notify(title, text)
    OrionLib:MakeNotification({Name = title, Content = text, Image = "rbxassetid://4483345998", Time = 5})
end

-- // FITUR FISHING // --

local AutoFish = false

TabFishing:AddToggle({
    Name = "Auto Fish (Loop)",
    Default = false,
    Callback = function(Value)
        AutoFish = Value
        task.spawn(function()
            while AutoFish do
                wait(0.5)
                pcall(function()
                    -- 1. Equip Rod
                    local argsEquip = {[1] = 1}
                    NetPath:FindFirstChild("RE/EquipToolFromHotbar"):FireServer(unpack(argsEquip))
                    wait(1)
                    
                    -- 2. Charge Rod (Tap)
                    local argsCharge = {[4] = 1764955984.076017} -- Perhatikan ID ini mungkin dinamis
                    NetPath:FindFirstChild("RF/ChargeFishingRod"):InvokeServer(unpack(argsCharge))
                    wait(0.5)
                    
                    -- 3. Lempar (Minigame Start)
                    local argsThrow = {
                        [1] = -1.233184814453125,
                        [2] = 0.5664744646758307,
                        [3] = 1764956036.282111
                    }
                    NetPath:FindFirstChild("RF/RequestFishingMinigameStarted"):InvokeServer(unpack(argsThrow))
                    wait(1.5) -- Tunggu sebentar seolah-olah sedang mancing
                    
                    -- 4. Selesaikan Fishing (Auto Catch)
                    NetPath:FindFirstChild("RE/FishingCompleted"):FireServer()
                end)
            end
        end)
    end
})

TabFishing:AddButton({
    Name = "Cancel Fishing (Stop Paksa)",
    Callback = function()
        pcall(function()
            NetPath:FindFirstChild("RF/CancelFishingInputs"):InvokeServer()
            -- Unequip juga biar aman
            NetPath:FindFirstChild("RE/UnequipToolFromHotbar"):FireServer()
        end)
        Notify("Info", "Fishing dibatalkan.")
    end
})

-- // FITUR WEATHER // --

TabWeather:AddParagraph("Info", "Klik tombol di bawah untuk membeli/mengubah cuaca.")

local function ChangeWeather(weatherName)
    local args = {[1] = weatherName}
    NetPath:FindFirstChild("RF/PurchaseWeatherEvent"):InvokeServer(unpack(args))
    Notify("Weather", "Mengubah cuaca ke: " .. weatherName)
end

TabWeather:AddButton({Name = "Angin (Wind)", Callback = function() ChangeWeather("Wind") end})
TabWeather:AddButton({Name = "Badai (Storm)", Callback = function() ChangeWeather("Storm") end})
TabWeather:AddButton({Name = "Berawan (Cloudy)", Callback = function() ChangeWeather("Cloudy") end})
TabWeather:AddButton({Name = "Salju (Snow)", Callback = function() ChangeWeather("Snow") end})
TabWeather:AddButton({Name = "Cerah (Radiant)", Callback = function() ChangeWeather("Radiant") end})
TabWeather:AddButton({Name = "Shark Hunt", Callback = function() ChangeWeather("Shark Hunt") end})

-- // FITUR TELEPORT MAPS // --

local Locations = {
    ["Ancient Jungle"] = Vector3.new(1490, 7, -428),
    ["Ancient Ruin"] = Vector3.new(6045, -589, 4608),
    ["Classic Event"] = Vector3.new(1234, 9, 2842),
    ["Coral Reefs"] = Vector3.new(-3022, 2, 2261),
    ["Crater Island"] = Vector3.new(1014, 22, 5077),
    ["Esoteric"] = Vector3.new(3201, -1303, 1416),
    ["Fisherman Island"] = Vector3.new(90, 17, 2836),
    ["Iron Cafe"] = Vector3.new(-8642, -548, 162),
    ["Iron Cavern"] = Vector3.new(-8873, -582, 156),
    ["Kohana"] = Vector3.new(-637, 16, 599),
    ["Kohana Volcano"] = Vector3.new(-552, 21, 144),
    ["Sacred Temple"] = Vector3.new(1475, -22, -632),
    ["Sisyphus Statue"] = Vector3.new(-3733, -136, -1014),
    ["Treasure Room"] = Vector3.new(-3599, -267, -1567),
    ["Tropical Grove"] = Vector3.new(-2046, 6, 3664),
    ["Underground Cellar"] = Vector3.new(2136, -92, -699),
    ["Weather Machine"] = Vector3.new(-1525, 2, 1915)
}

TabTeleport:AddDropdown({
    Name = "Pilih Lokasi Map",
    Default = "",
    Options = {
        "Ancient Jungle", "Ancient Ruin", "Classic Event", "Coral Reefs", 
        "Crater Island", "Esoteric", "Fisherman Island", "Iron Cafe", 
        "Iron Cavern", "Kohana", "Kohana Volcano", "Sacred Temple", 
        "Sisyphus Statue", "Treasure Room", "Tropical Grove", 
        "Underground Cellar", "Weather Machine"
    },
    Callback = function(Value)
        if Locations[Value] then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Locations[Value])
        end
    end
})

-- // TELEPORT PLAYER (FIXED) // --

local SelectedPlayer = nil
local PlayerList = {}

local function UpdatePlayerList()
    PlayerList = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            table.insert(PlayerList, v.Name)
        end
    end
end

local PlayerDropdown = TabTeleport:AddDropdown({
    Name = "Pilih Player",
    Default = "",
    Options = PlayerList,
    Callback = function(Value)
        SelectedPlayer = Players:FindFirstChild(Value)
    end
})

TabTeleport:AddButton({
    Name = "Refresh Player List",
    Callback = function()
        UpdatePlayerList()
        PlayerDropdown:Refresh(PlayerList, true)
    end
})

TabTeleport:AddButton({
    Name = "Teleport ke Player",
    Callback = function()
        if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame
        else
            Notify("Error", "Player tidak ditemukan atau tidak memiliki karakter.")
        end
    end
})

-- // UTILITY & FLY (FIXED - SMOOTH) // --

-- Radar & Oxygen
TabPlayer:AddToggle({
    Name = "Aktifkan Radar",
    Default = false,
    Callback = function(Value)
        local args = {[1] = Value}
        NetPath:FindFirstChild("RF/UpdateFishingRadar"):InvokeServer(unpack(args))
    end
})

TabPlayer:AddButton({
    Name = "Equip Oxygen Tank",
    Callback = function()
        local args = {[1] = 105}
        NetPath:FindFirstChild("RF/EquipOxygenTank"):InvokeServer(unpack(args))
        Notify("Success", "Oksigen terpasang.")
    end
})

-- FLY SCRIPT BARU (BodyVelocity - Smooth)
local FlyActive = false
local FlySpeed = 50
local BodyGyro, BodyVelocity = nil, nil

TabPlayer:AddToggle({
    Name = "Fly (Terbang Halus)",
    Default = false,
    Callback = function(Value)
        FlyActive = Value
        local HRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not HRP then return end
        
        if FlyActive then
            -- Mulai Terbang
            BodyGyro = Instance.new("BodyGyro", HRP)
            BodyGyro.P = 9e4
            BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            BodyGyro.cframe = HRP.CFrame

            BodyVelocity = Instance.new("BodyVelocity", HRP)
            BodyVelocity.velocity = Vector3.new(0, 0.1, 0)
            BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

            task.spawn(function()
                while FlyActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") do
                    RunService.RenderStepped:Wait()
                    if not FlyActive then break end
                    
                    local Cam = workspace.CurrentCamera
                    local MoveDir = Vector3.new()
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then MoveDir = MoveDir + Cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then MoveDir = MoveDir - Cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then MoveDir = MoveDir - Cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then MoveDir = MoveDir + Cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then MoveDir = MoveDir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then MoveDir = MoveDir - Vector3.new(0, 1, 0) end
                    
                    BodyGyro.cframe = Cam.CFrame
                    BodyVelocity.velocity = (MoveDir * FlySpeed)
                end
            end)
        else
            -- Matikan Terbang
            if BodyGyro then BodyGyro:Destroy() end
            if BodyVelocity then BodyVelocity:Destroy() end
            LocalPlayer.Character.Humanoid.PlatformStand = false
        end
    end
})

TabPlayer:AddSlider({
    Name = "Kecepatan Terbang",
    Min = 10,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        FlySpeed = Value
    end
})

-- // SETTINGS & UNLOAD (FIXED X BUTTON) // --

-- Orion sudah memiliki Tab Settings bawaan untuk Theme, tapi kita bisa tambahkan instruksi
TabSettings:AddLabel("Theme & Keybind")
TabSettings:AddParagraph("Cara Mengganti Tema", "Pilih tema di bagian bawah script ini (Orion Built-in).")
TabSettings:AddParagraph("Cara Hide GUI", "Tekan Right Control (Ctrl Kanan) pada Keyboard.")

-- Fitur UNLOAD SCRIPT (Mematikan total script)
TabSettings:AddButton({
    Name = "MATIKAN SCRIPT (UNLOAD)",
    Callback = function()
        AutoFish = false
        FlyActive = false
        if BodyGyro then BodyGyro:Destroy() end
        if BodyVelocity then BodyVelocity:Destroy() end
        OrionLib:Destroy()
        Notify("System", "Script telah dimatikan total.")
    end
})

-- Init Library
OrionLib:Init()