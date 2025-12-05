-- =========================================================
-- ALGHI HUB - ULTIMATE GITHUB EDITION
-- Gabungan kode dari berbagai sumber GitHub (STREE, OP)
-- Fitur: Auto Fish (Charge+Cast), Appraise, Sell, Anti-AFK
-- =========================================================

-- 1. LOAD LIBRARY (VERSI LITE BIAR RINGAN DI HP)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fish Hub | Ultimate",
    SubTitle = "GitHub Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350), -- Ukuran pas HP
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Farm = Window:AddTab({ Title = "Auto Farm", Icon = "dollar-sign" }),
    Teleport = Window:AddTab({ Title = "Maps", Icon = "map-pin" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "System", Icon = "settings" })
}

local Options = Fluent.Options

-- 2. SMART REMOTE FINDER (PENCARI JALUR OTOMATIS)
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
-- TAB 1: FISHING (DENGAN KODE GITHUB)
-- ==============================
Tabs.Main:AddParagraph({Title = "Status", Content = "Fitur Fishing dengan Charge Rod"})

-- Auto Cast (Charge + Cast)
local ToggleCast = Tabs.Main:AddToggle("AutoCast", {Title = "Auto Cast (Lempar)", Default = false })

ToggleCast:OnChanged(function()
    task.spawn(function()
        while Options.AutoCast.Value do
            local folder = getNet()
            if folder then
                -- [KODE GITHUB 1] Charge Rod (Isi Tenaga dulu biar aman)
                local charge = folder:FindFirstChild("RF/ChargeFishingRod")
                if charge then charge:InvokeServer() end
                
                task.wait(0.5) -- Tunggu animasi charge

                -- [KODE GITHUB 2] Lempar dengan sudut presisi -1.233
                local cast = folder:FindFirstChild("RF/RequestFishingMinigameStarted")
                if cast then
                    -- Argumen: Sudut, Akurasi, Waktu
                    cast:InvokeServer(unpack({-1.233, 1.0, tick()}))
                end
            end
            task.wait(3.5) -- Jeda lempar normal
        end
    end)
end)

-- Instant Catch
local ToggleCatch = Tabs.Main:AddToggle("AutoCatch", {Title = "Instant Catch (Tangkap)", Default = false })

ToggleCatch:OnChanged(function()
    task.spawn(function()
        while Options.AutoCatch.Value do
            local folder = getNet()
            if folder then
                -- [KODE GITHUB 3] Selesaikan Minigame
                local finish = folder:FindFirstChild("RE/FishingCompleted")
                if finish then finish:FireServer() end
            end
            task.wait(1.5)
        end
    end)
end)

-- ==============================
-- TAB 2: AUTO FARM (JUAL & APPRAISE)
-- ==============================

-- Auto Appraise (Cek Harga)
local ToggleAppraise = Tabs.Farm:AddToggle("AutoAppraise", {Title = "Auto Appraise (Cek Harga)", Default = false })

ToggleAppraise:OnChanged(function()
    task.spawn(function()
        while Options.AutoAppraise.Value do
            local folder = getNet()
            if folder then
                -- [KODE GITHUB 4] Appraise Semua Item
                local appraise = folder:FindFirstChild("RF/AppraiseAllItems")
                if appraise then 
                    appraise:InvokeServer() 
                    print("Items Appraised!")
                end
            end
            task.wait(5)
        end
    end)
end)

-- Auto Sell (Jual)
local ToggleSell = Tabs.Farm:AddToggle("AutoSell", {Title = "Auto Sell (Jual Ikan)", Default = false })

ToggleSell:OnChanged(function()
    task.spawn(function()
        while Options.AutoSell.Value do
            -- 1. Teleport ke Toko
            if game.Players.LocalPlayer.Character then
                -- Koordinat Toko Umum
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(20, 15, 20)
            end
            task.wait(1)

            -- 2. Jual Semua
            local folder = getNet()
            if folder then
                -- [KODE GITHUB 5] Jual Semua Item
                local sell = folder:FindFirstChild("RF/SellAllItems")
                if sell then 
                    sell:InvokeServer() 
                    Fluent:Notify({Title = "Auto Sell", Content = "Ikan Terjual!", Duration = 2})
                end
            end
            task.wait(6) -- Jual setiap 6 detik
        end
    end)
end)

-- ==============================
-- TAB 3: TELEPORT LOCATIONS
-- ==============================
local Locations = {
    ["Spawn"] = CFrame.new(0, 50, 0),
    ["Shop (Toko)"] = CFrame.new(20, 15, 20),
    ["Beach (Pantai)"] = CFrame.new(125, 12, -180),
    ["Deep Ocean"] = CFrame.new(-250, 5, 400)
}

local DropdownTeleport = Tabs.Teleport:AddDropdown("Loc", {
    Title = "Pilih Lokasi",
    Values = {"Spawn", "Shop (Toko)", "Beach (Pantai)", "Deep Ocean"},
    Multi = false, Default = 1,
})

Tabs.Teleport:AddButton({
    Title = "Teleport Sekarang",
    Callback = function()
        local dest = Locations[Options.Loc.Value]
        if dest and game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = dest
        end
    end
})

-- ==============================
-- TAB 4: PLAYER & ANTI-AFK
-- ==============================
-- Fly Mobile
local flySpeed = 50
Tabs.Player:AddSlider("FlySpeed", {Title = "Fly Speed", Default = 50, Min = 10, Max = 150, Rounding = 1, Callback = function(v) flySpeed = v end})
local ToggleFly = Tabs.Player:AddToggle("FlyMode", {Title = "Aktifkan Fly", Default = false })

ToggleFly:OnChanged(function()
    local state = Options.FlyMode.Value
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    if state then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVel"; bv.Parent = hrp; bv.MaxForce = Vector3.new(Math.huge, Math.huge, Math.huge); bv.Velocity = Vector3.new(0,0,0)
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

-- Anti AFK Code
Tabs.Player:AddToggle("AntiAFK", {Title = "Anti-AFK (Biar gak dikick)", Default = true, Callback = function(Val)
    if Val then
        local bb = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            bb:CaptureController()
            bb:ClickButton2(Vector2.new())
            Fluent:Notify({Title = "Anti-AFK", Content = "Mencegah Kick...", Duration = 2})
        end)
    end
end})

-- ==============================
-- SYSTEM & TOMBOL HP
-- ==============================
Tabs.Settings:AddButton({
    Title = "❌ Tutup Script",
    Callback = function()
        Window:Destroy()
        if game.Players.LocalPlayer.PlayerGui:FindFirstChild("AlghiButton") then 
            game.Players.LocalPlayer.PlayerGui.AlghiButton:Destroy() 
        end
    end
})

-- Tombol Biru "M"
spawn(function()
    if game.Players.LocalPlayer.PlayerGui:FindFirstChild("AlghiButton") then game.Players.LocalPlayer.PlayerGui.AlghiButton:Destroy() end
    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "AlghiButton"; ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
    local Btn = Instance.new("TextButton"); Btn.Parent = ScreenGui; Btn.Size = UDim2.new(0, 45, 0, 45); Btn.Position = UDim2.new(0, 30, 0.4, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); Btn.Text = "M"; Btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
    
    local dragging, dragInput, dragStart, startPos
    local function update(input) local delta = input.Position - dragStart; Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end
    Btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = Btn.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
    Btn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
    
    Btn.MouseButton1Click:Connect(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait()
        vim:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
    end)
end)

Window:SelectTab(1)
Fluent:Notify({Title = "Script Loaded", Content = "Fitur GitHub Berhasil Ditambahkan!", Duration = 5})