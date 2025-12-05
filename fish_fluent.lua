-- // SETTINGAN AWAL // --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // MENCARI REMOTE OTOMATIS (Supaya tidak Error) // --
local NetPath = nil
pcall(function()
    local Packages = ReplicatedStorage:FindFirstChild("Packages")
    if Packages then
        local Index = Packages:FindFirstChild("_Index")
        if Index then
            for _, child in pairs(Index:GetChildren()) do
                if string.find(child.Name, "sleitnick_net") then
                    NetPath = child:FindFirstChild("net")
                    break
                end
            end
        end
    end
end)

if not NetPath then
    warn("Gagal menemukan Remote Path 'sleitnick_net'. Coba cek nama folder di Dex Explorer.")
    -- Kita coba path default user jika auto-detect gagal
    pcall(function()
        NetPath = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
    end)
end

-- // MEMBUAT GUI MANUAL (TANPA LIBRARY) // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItCustomGUI"
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = game:GetService("CoreGui") -- Atau LocalPlayer.PlayerGui jika CoreGui error

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true -- Bisa digeser

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.Size = UDim2.new(1, 0, 0, 30)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Fish It - Fixed Version"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- TOMBOL X (CLOSE TOTAL)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

-- TOMBOL MINIMIZE (-)
local MiniButton = Instance.new("TextButton")
MiniButton.Name = "MiniButton"
MiniButton.Parent = TitleBar
MiniButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
MiniButton.Position = UDim2.new(1, -60, 0, 0)
MiniButton.Size = UDim2.new(0, 30, 0, 30)
MiniButton.Font = Enum.Font.GothamBold
MiniButton.Text = "-"
MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniButton.TextSize = 14

-- TOMBOL TOGGLE (Kecil saat minimize)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "OpenGUI"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, 0)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "OPEN"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Visible = false
ToggleBtn.LayerCollector.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- CONTAINER FITUR --
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 10, 0, 40)
ScrollingFrame.Size = UDim2.new(1, -20, 1, -50)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 3, 0) -- Scroll panjang

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- // FUNGSI HELPER TOMBOL // --
local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScrollingFrame
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.Font = Enum.Font.Gotham
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 14
    
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local function CreateLabel(text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Parent = ScrollingFrame
    Lbl.BackgroundTransparency = 1
    Lbl.Size = UDim2.new(1, 0, 0, 25)
    Lbl.Font = Enum.Font.GothamBold
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(255, 200, 50)
    Lbl.TextSize = 14
    return Lbl
end

-- // VARIABEL LOGIKA // --
local isFlying = false
local isAutoFishing = false
local FlyConnection
local FishLoop

-- // 1. FITUR FLY (FIXED SMOOTH) // --
CreateLabel("--- MOVEMENT ---")
local FlyBtn = CreateButton("Toggle Fly: OFF", function() end)

local function StopFly()
    isFlying = false
    FlyBtn.Text = "Toggle Fly: OFF"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    local Char = LocalPlayer.Character
    if Char then
        local HRP = Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char:FindFirstChild("Humanoid")
        if HRP then
            if HRP:FindFirstChild("BodyGyro") then HRP.BodyGyro:Destroy() end
            if HRP:FindFirstChild("BodyVelocity") then HRP.BodyVelocity:Destroy() end
        end
        if Hum then Hum.PlatformStand = false end
    end
    if FlyConnection then FlyConnection:Disconnect() end
end

local function StartFly()
    isFlying = true
    FlyBtn.Text = "Toggle Fly: ON"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    
    local Speed = 50
    local Char = LocalPlayer.Character
    if not Char then return end
    local HRP = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChild("Humanoid")
    
    local BG = Instance.new("BodyGyro", HRP)
    BG.P = 9e4
    BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.CFrame = HRP.CFrame
    
    local BV = Instance.new("BodyVelocity", HRP)
    BV.velocity = Vector3.new(0, 0, 0)
    BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    Hum.PlatformStand = true
    
    FlyConnection = RunService.RenderStepped:Connect(function()
        if not isFlying or not Char or not HRP then return end
        local Cam = workspace.CurrentCamera
        local Move = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Move = Move + Cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Move = Move - Cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then Move = Move - Cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then Move = Move + Cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Move = Move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then Move = Move - Vector3.new(0, 1, 0) end
        
        BG.CFrame = Cam.CFrame
        BV.Velocity = Move * Speed
    end)
end

FlyBtn.MouseButton1Click:Connect(function()
    if isFlying then StopFly() else StartFly() end
end)


-- // 2. FITUR FISHING // --
CreateLabel("--- FISHING ---")
local FishBtn = CreateButton("Auto Fish Loop: OFF", function() end)

FishBtn.MouseButton1Click:Connect(function()
    isAutoFishing = not isAutoFishing
    if isAutoFishing then
        FishBtn.Text = "Auto Fish Loop: ON"
        FishBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        FishLoop = task.spawn(function()
            while isAutoFishing do
                wait(0.5)
                pcall(function()
                     if not NetPath then return end
                     -- 1. Equip
                     NetPath:FindFirstChild("RE/EquipToolFromHotbar"):FireServer(1)
                     wait(1.2)
                     -- 2. Charge
                     NetPath:FindFirstChild("RF/ChargeFishingRod"):InvokeServer(1764955984.076017)
                     wait(0.5)
                     -- 3. Throw
                     NetPath:FindFirstChild("RF/RequestFishingMinigameStarted"):InvokeServer(-1.23, 0.56, 1764956036.28)
                     wait(2) -- Waktu tunggu ikan
                     -- 4. Catch
                     NetPath:FindFirstChild("RE/FishingCompleted"):FireServer()
                end)
            end
        end)
    else
        FishBtn.Text = "Auto Fish Loop: OFF"
        FishBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        -- Stop
        pcall(function()
            NetPath:FindFirstChild("RF/CancelFishingInputs"):InvokeServer()
            NetPath:FindFirstChild("RE/UnequipToolFromHotbar"):FireServer()
        end)
    end
end)

CreateButton("Stop/Cancel Fishing Manual", function()
    pcall(function()
        NetPath:FindFirstChild("RF/CancelFishingInputs"):InvokeServer()
        NetPath:FindFirstChild("RE/UnequipToolFromHotbar"):FireServer()
    end)
end)

-- // 3. UTILITY // --
CreateLabel("--- UTILITY ---")
CreateButton("Aktifkan Radar", function()
    if NetPath then NetPath:FindFirstChild("RF/UpdateFishingRadar"):InvokeServer(true) end
end)
CreateButton("Equip Oksigen", function()
    if NetPath then NetPath:FindFirstChild("RF/EquipOxygenTank"):InvokeServer(105) end
end)

-- // 4. WEATHER // --
CreateLabel("--- WEATHER ---")
local weathers = {"Wind", "Storm", "Cloudy", "Snow", "Radiant", "Shark Hunt"}
for _, w in pairs(weathers) do
    CreateButton("Cuaca: " .. w, function()
        if NetPath then NetPath:FindFirstChild("RF/PurchaseWeatherEvent"):InvokeServer(w) end
    end)
end

-- // 5. TELEPORT PLAYER // --
CreateLabel("--- TELEPORT PLAYER ---")
local TBoxPlayer = Instance.new("TextBox")
TBoxPlayer.Parent = ScrollingFrame
TBoxPlayer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TBoxPlayer.Size = UDim2.new(1, 0, 0, 35)
TBoxPlayer.Font = Enum.Font.Gotham
TBoxPlayer.Text = ""
TBoxPlayer.PlaceholderText = "Ketik Nama Player (Singkat bisa)"
TBoxPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
TBoxPlayer.TextSize = 14

CreateButton("Teleport ke Player di atas", function()
    local targetName = TBoxPlayer.Text
    local target = nil
    for _, v in pairs(Players:GetPlayers()) do
        if string.sub(string.lower(v.Name), 1, #targetName) == string.lower(targetName) then
            target = v
            break
        end
    end
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    end
end)

-- // 6. TELEPORT MAPS // --
CreateLabel("--- TELEPORT MAPS ---")
local locs = {
    ["Ancient Jungle"] = Vector3.new(1490, 7, -428),
    ["Ancient Ruin"] = Vector3.new(6045, -589, 4608),
    ["Coral Reefs"] = Vector3.new(-3022, 2, 2261),
    ["Iron Cafe"] = Vector3.new(-8642, -548, 162),
    ["Treasure Room"] = Vector3.new(-3599, -267, -1567),
    -- Tambahkan lokasi lain sesuai request di sini
}

for name, vec in pairs(locs) do
    CreateButton("TP: " .. name, function()
        if LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(vec)
        end
    end)
end


-- // LOGIKA TOMBOL GUI (X & -) // --

-- Fungsi Minimize (-)
MiniButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleBtn.Visible = true
end)

-- Fungsi Toggle Button (Open)
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleBtn.Visible = false
end)

-- Fungsi Close (X) - MATI TOTAL
CloseButton.MouseButton1Click:Connect(function()
    -- 1. Matikan Fly
    StopFly()
    -- 2. Matikan Fish Loop
    isAutoFishing = false
    -- 3. Hapus GUI
    ScreenGui:Destroy()
end)

print("Script Loaded - Fish It Custom GUI")