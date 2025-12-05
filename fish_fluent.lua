-- =========================================================
-- ALGHI HUB (CHLOE X STYLE - FULL FEATURE)
-- UI: Fluent | Fitur: Auto Fish, Fly Mobile, Teleport
-- =========================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Chloe X | Remake by Alghi",
    SubTitle = "Mobile V2",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Fishing = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Auto = Window:AddTab({ Title = "Automatically", Icon = "play" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Player = Window:AddTab({ Title = "Player & Fly", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- FUNGSI PENCARI REMOTE OTOMATIS (JANTUNG SCRIPT)
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

-- [[ TAB 1: FISHING ]]
Tabs.Fishing:AddParagraph({
    Title = "Status",
    Content = "Pastikan kamu memegang pancingan!"
})

-- SLIDER KEKUATAN
local CastStrength = Tabs.Fishing:AddSlider("CastStrength", {
    Title = "Cast Power (Kekuatan Lempar)",
    Default = 100,
    Min = 50,
    Max = 100,
    Rounding = 1,
    Description = "100 = Lempar ke tengah laut"
})

-- AUTO CAST (LEMPAR)
local ToggleCast = Tabs.Fishing:AddToggle("AutoCast", {Title = "Auto Cast (Lempar)", Default = false })
ToggleCast:OnChanged(function()
    task.spawn(function()
        while Options.AutoCast.Value do
            local folder = getNet()
            if folder then
                local event = folder:FindFirstChild("RF/RequestFishingMinigameStarted")
                if event then
                    -- Kode Rahasia yang kamu temukan kemarin
                    local args = {
                        [1] = Options.CastStrength.Value, -- Kekuatan dari slider
                        [2] = 1.0, 
                        [3] = tick() -- Waktu sekarang
                    }
                    event:InvokeServer(unpack(args))
                end
            end
            task.wait(3.5) -- Jeda waktu lempar
        end
    end)
end)

-- INSTANT CATCH (TANGKAP)
local ToggleCatch = Tabs.Fishing:AddToggle("AutoCatch", {Title = "Instant Catch (Tangkap)", Default = false })
ToggleCatch:OnChanged(function()
    task.spawn(function()
        while Options.AutoCatch.Value do
            local folder = getNet()
            if folder then
                local event = folder:FindFirstChild("RE/FishingCompleted")
                if event then
                    event:FireServer() -- Langsung lapor "Dapat Ikan!"
                end
            end
            task.wait(1.5) -- Jangan terlalu cepat biar aman
        end
    end)
end)


-- [[ TAB 2: AUTOMATICALLY (AUTO SELL) ]]
Tabs.Auto:AddSection("Sell & Appraise")

Tabs.Auto:AddButton({
    Title = "Jual Semua Ikan (Sell All)",
    Description = "Teleport ke NPC Jual lalu Jual Ikan",
    Callback = function()
        -- 1. Teleport ke NPC Jual (Ganti angka ini kalau tahu posisi pasnya)
        local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            -- Contoh Koordinat Toko (Biasanya dekat spawn)
            rootPart.CFrame = CFrame.new(20, 15, 20) 
        end
        
        task.wait(1)
        
        -- 2. Kirim Sinyal Jual
        -- (Kalau kamu nemu remote 'SellAll' pakai SimpleSpy, ganti ini nanti)
        local folder = getNet()
        if folder then
            local sellEvent = folder:FindFirstChild("RF/SellAllFish") 
            if sellEvent then sellEvent:InvokeServer() end
        end
        
        Fluent:Notify({Title = "Info", Content = "Mencoba menjual ikan...", Duration = 3})
    end
})


-- [[ TAB 3: TELEPORT ]]
local Lokasi = {
    ["Spawn Awal"] = CFrame.new(0, 50, 0),
    ["Pantai (Beach)"] = CFrame.new(150, 10, -100), -- Contoh koordinat
    ["Zona Dalam (Deep)"] = CFrame.new(-200, 5, 300) -- Contoh koordinat
}

local DropdownTeleport = Tabs.Teleport:AddDropdown("Lokasi", {
    Title = "Pilih Lokasi",
    Values = {"Spawn Awal", "Pantai (Beach)", "Zona Dalam (Deep)"},
    Multi = false,
    Default = 1,
})

Tabs.Teleport:AddButton({
    Title = "Teleport Sekarang",
    Callback = function()
        local tujuannya = Lokasi[Options.Lokasi.Value]
        if tujuannya and game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = tujuannya
        end
    end
})


-- [[ TAB 4: PLAYER & FLY ]]
local flySpeed = 50
Tabs.Player:AddSlider("FlySpeed", {
    Title = "Kecepatan Terbang", Default = 50, Min = 10, Max = 150, Rounding = 1,
    Callback = function(v) flySpeed = v end
})

local ToggleFly = Tabs.Player:AddToggle("FlyMode", {Title = "Aktifkan Terbang (Joystick)", Default = false })

ToggleFly:OnChanged(function()
    local state = Options.FlyMode.Value
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")

    if state then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVel"
        bv.Parent = hrp
        bv.MaxForce = Vector3.new(Math.huge, Math.huge, Math.huge)
        bv.Velocity = Vector3.new(0,0,0)
        humanoid.PlatformStand = true 
        
        task.spawn(function()
            while Options.FlyMode.Value and char do
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
end)


-- [[ TOMBOL DARURAT HP (DRAGGABLE) ]]
spawn(function()
    if game.Players.LocalPlayer.PlayerGui:FindFirstChild("AlghiButton") then 
        game.Players.LocalPlayer.PlayerGui.AlghiButton:Destroy() 
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AlghiButton"
    ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false
    
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 45, 0, 45)
    Btn.Position = UDim2.new(0, 30, 0.4, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    Btn.Text = "M"
    Btn.TextColor3 = Color3.new(1,1,1)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1,0)
    Corner.Parent = Btn
    
    -- Fungsi Klik Tombol
    Btn.MouseButton1Click:Connect(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait()
        vim:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
    end)
    
    -- Draggable Logic
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
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
Window:SelectTab(1)

Fluent:Notify({
    Title = "Script Loaded",
    Content = "Fitur Fishing & Fly Siap Digunakan!",
    Duration = 5
})