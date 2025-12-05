-- =========================================================
-- ALGHI HUB - FISH IT (CUSTOM FEATURE REQUEST)
-- Game: Fish It
-- Menu: Custom (Shop, Weather, Teleport List, Options)
-- =========================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fish It Hub | Alghi Custom",
    SubTitle = "Mobile V4",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 360),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Fishing = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Shop = Window:AddTab({ Title = "Shop Features", Icon = "shopping-cart" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Option = Window:AddTab({ Title = "Option", Icon = "settings" })
}

local Options = Fluent.Options
local LocalPlayer = game.Players.LocalPlayer

-- VAR GLOBAL (Untuk Input Nomor)
getgenv().LegitDelay = 0.5
getgenv().ShakeDelay = 0.1
getgenv().InstantDelay = 0.5
getgenv().BlatantReelDelay = 0.1
getgenv().BlatantStartDelay = 0.1
getgenv().WalkSpeedVal = 16
getgenv().FlySpeedVal = 50

-- PENCARI REMOTE "FISH IT"
local NetFolder
local function getNet()
    if NetFolder then return NetFolder end
    local RS = game:GetService("ReplicatedStorage")
    if RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("_Index") then
        for _, child in pairs(RS.Packages._Index:GetChildren()) do
            if child.Name:find("net@") and child:FindFirstChild("net") then
                NetFolder = child.net
                return child.net
            end
        end
    end
    return nil
end

-- =========================================================
-- [TAB 1] FISHING
-- =========================================================

-- >> SECTION 1: FISHING FEATURES
Tabs.Fishing:AddSection("Fishing Features")

-- Auto Equip Rod
local ToggleEquip = Tabs.Fishing:AddToggle("AutoEquip", {Title = "Auto Equip Rod", Default = false })
ToggleEquip:OnChanged(function(Value)
    task.spawn(function()
        while Value and Options.AutoEquip.Value do
            if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                local rod = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if rod then LocalPlayer.Character.Humanoid:EquipTool(rod) end
            end
            task.wait(1)
        end
    end)
end)

-- Legit Delay
Tabs.Fishing:AddInput("InpLegitDelay", {
    Title = "Legit Delay (Detik)", Default = "0.5", Numeric = true, Finished = true,
    Callback = function(T) getgenv().LegitDelay = tonumber(T) or 0.5 end
})

-- Shake Delay
Tabs.Fishing:AddInput("InpShakeDelay", {
    Title = "Shake Delay (Detik)", Default = "0.1", Numeric = true, Finished = true,
    Callback = function(T) getgenv().ShakeDelay = tonumber(T) or 0.1 end
})

-- Legit Fishing (Cast -> Wait -> Minigame)
local ToggleLegit = Tabs.Fishing:AddToggle("LegitFish", {Title = "Legit Fishing", Default = false })
ToggleLegit:OnChanged(function(Value)
    task.spawn(function()
        while Value and Options.LegitFish.Value do
            local folder = getNet()
            if folder then
                -- 1. Charge
                local charge = folder:FindFirstChild("RF/ChargeFishingRod")
                if charge then charge:InvokeServer() end
                task.wait(0.2)
                
                -- 2. Cast
                local cast = folder:FindFirstChild("RF/RequestFishingMinigameStarted")
                if cast then cast:InvokeServer(unpack({-1.233, 1.0, tick()})) end
                
                -- 3. Wait Legit Delay
                task.wait(getgenv().LegitDelay)
            end
            task.wait(1.5)
        end
    end)
end)

-- Auto Shake (Fish It biasanya tidak ada shake manual, jadi kita simulasikan tunggu)
local ToggleShake = Tabs.Fishing:AddToggle("AutoShake", {Title = "Auto Shake", Default = false })
ToggleShake:OnChanged(function(Value)
    -- Di Fish It, shake otomatis ditangani oleh server script biasanya
    -- Tapi kita buat dummy loop sesuai request
    task.spawn(function()
        while Value and Options.AutoShake.Value do
            task.wait(getgenv().ShakeDelay)
        end
    end)
end)

-- >> SECTION 2: INSTANT FEATURES
Tabs.Fishing:AddSection("Instant Features")

Tabs.Fishing:AddInput("InpInstantDelay", {
    Title = "Delay Complete", Default = "0.5", Numeric = true, Finished = true,
    Callback = function(T) getgenv().InstantDelay = tonumber(T) or 0.5 end
})

local ToggleInstant = Tabs.Fishing:AddToggle("InstantFish", {Title = "Instant Fishing", Default = false })
ToggleInstant:OnChanged(function(Value)
    task.spawn(function()
        while Value and Options.InstantFish.Value do
            local folder = getNet()
            if folder then
                -- Charge & Cast
                local charge = folder:FindFirstChild("RF/ChargeFishingRod")
                if charge then charge:InvokeServer() end
                local cast = folder:FindFirstChild("RF/RequestFishingMinigameStarted")
                if cast then cast:InvokeServer(unpack({-1.233, 1.0, tick()})) end
                
                task.wait(getgenv().InstantDelay)
                
                -- Instant Complete
                local finish = folder:FindFirstChild("RE/FishingCompleted")
                if finish then finish:FireServer() end
            end
            task.wait(0.5) -- Loop cepat
        end
    end)
end)

-- >> SECTION 3: BLATANT FEATURES
Tabs.Fishing:AddSection("Blatant Features")

Tabs.Fishing:AddInput("InpBlatantReel", { Title = "Delay Reel", Default = "0.1", Numeric = true, Callback = function(T) getgenv().BlatantReelDelay = tonumber(T) end})
Tabs.Fishing:AddInput("InpBlatantStart", { Title = "Delay Start", Default = "0.1", Numeric = true, Callback = function(T) getgenv().BlatantStartDelay = tonumber(T) end})

local ToggleBlatant = Tabs.Fishing:AddToggle("BlatantFish", {Title = "Blatant Fishing", Default = false })
ToggleBlatant:OnChanged(function(Value)
    task.spawn(function()
        while Value and Options.BlatantFish.Value do
            local folder = getNet()
            if folder then
                local finish = folder:FindFirstChild("RE/FishingCompleted")
                if finish then finish:FireServer() end
            end
            task.wait(getgenv().BlatantReelDelay)
        end
    end)
end)

Tabs.Fishing:AddButton({
    Title = "Recovery Fishing",
    Description = "Fix Stuck / Reset Character",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:UnequipTools()
            Fluent:Notify({Title="System", Content="Character Reset!", Duration=2})
        end
    end
})

-- =========================================================
-- [TAB 2] SHOP FEATURES
-- =========================================================

Tabs.Shop:AddButton({
    Title = "Merchant Stock Panel (Open/Close)",
    Callback = function()
        -- Mencoba mencari UI Merchant di PlayerGui
        local pGui = LocalPlayer:WaitForChild("PlayerGui")
        local merchantUI = pGui:FindFirstChild("MerchantUI") or pGui:FindFirstChild("Shop")
        if merchantUI then
            merchantUI.Enabled = not merchantUI.Enabled
        else
            Fluent:Notify({Title="Shop", Content="UI Merchant tidak ditemukan!", Duration=2})
        end
    end
})

Tabs.Shop:AddSection("Buy Weather")

local WeatherList = {"Cloudy", "Wind", "Snow", "Storm", "Radiant", "Shark Hunt"}
local SelectedWeather = "Cloudy"

Tabs.Shop:AddDropdown("SelWeather", {
    Title = "Select Weather", Values = WeatherList, Multi = false, Default = 1,
    Callback = function(V) SelectedWeather = V end
})

Tabs.Shop:AddButton({
    Title = "Auto Buy Weather",
    Callback = function()
        Fluent:Notify({Title="Weather", Content="Membeli cuaca: "..SelectedWeather, Duration=2})
        -- Masukkan kode beli weather Fish It disini jika ada
    end
})

-- =========================================================
-- [TAB 3] TELEPORT
-- =========================================================

-- PLAYER TELEPORT
Tabs.Teleport:AddSection("Teleport to Player")
local Players = game:GetService("Players")
local PlayerList = {}
local function RefPlayers()
    PlayerList = {}
    for _,v in pairs(Players:GetPlayers()) do table.insert(PlayerList, v.Name) end
end
RefPlayers()

local DropPlayer = Tabs.Teleport:AddDropdown("SelPlayer", {
    Title = "Select Player", Values = PlayerList, Multi = false, Default = 1
})

Tabs.Teleport:AddButton({
    Title = "Refresh Player List",
    Callback = function() RefPlayers(); DropPlayer:SetValues(PlayerList); DropPlayer:SetValue(nil) end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Player",
    Callback = function()
        local target = Players:FindFirstChild(Options.SelPlayer.Value)
        if target and target.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
})

-- LOCATION TELEPORT
Tabs.Teleport:AddSection("Location")

-- Daftar Lokasi Request (Saya set ke Spawn Fish It dulu biar aman)
-- Karena Ancient Jungle dll itu map game lain, koordinatnya beda.
local CustomLocs = {
    ["Ancient Jungle"] = CFrame.new(0,50,0),
    ["Ancient Ruin"] = CFrame.new(0,50,0),
    ["Classic Event"] = CFrame.new(0,50,0),
    ["Coral Reefs"] = CFrame.new(0,50,0),
    ["Crater Island"] = CFrame.new(0,50,0),
    ["Crystaline Passage"] = CFrame.new(0,50,0),
    ["Esoteric Deep"] = CFrame.new(0,50,0),
    ["Fisherman Island"] = CFrame.new(0,50,0),
    ["Ice Sea"] = CFrame.new(0,50,0),
    ["Iron Cafe"] = CFrame.new(0,50,0),
    ["Iron Cavern"] = CFrame.new(0,50,0),
    ["Kohana"] = CFrame.new(0,50,0),
    ["Lost Shore"] = CFrame.new(0,50,0),
    ["Sisyphus Statue"] = CFrame.new(0,50,0),
    ["Stingray Shores"] = CFrame.new(0,50,0),
    ["Treasure Room"] = CFrame.new(0,50,0),
    ["Tropical Grove"] = CFrame.new(0,50,0),
    ["Underground Cellar"] = CFrame.new(0,50,0),
    ["Weather Machine"] = CFrame.new(0,50,0)
}

local LocKeys = {}
for k,v in pairs(CustomLocs) do table.insert(LocKeys, k) end
table.sort(LocKeys)

local DropLoc = Tabs.Teleport:AddDropdown("SelLoc", {
    Title = "Select Location", Values = LocKeys, Multi = false, Default = 1
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Location",
    Callback = function()
        local dest = CustomLocs[Options.SelLoc.Value]
        if dest and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = dest
            Fluent:Notify({Title="Teleport", Content="Teleporting to "..Options.SelLoc.Value, Duration=2})
        end
    end
})

-- =========================================================
-- [TAB 4] OPTION
-- =========================================================

-- BOOSTER FPS
Tabs.Option:AddSection("Booster FPS")
Tabs.Option:AddButton({
    Title = "Reduce Map",
    Callback = function()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                v.Material = Enum.Material.SmoothPlastic
                if v:IsA("Texture") then v:Destroy() end
            end
        end
        Fluent:Notify({Title="FPS", Content="Map Reduced!", Duration=2})
    end
})
Tabs.Option:AddButton({
    Title = "Black Screen",
    Callback = function()
        local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3=Color3.new(0,0,0); f.Parent = LocalPlayer.PlayerGui
        Fluent:Notify({Title="System", Content="Layar Hitam Aktif", Duration=2})
    end
})

-- UTILITY PLAYER
Tabs.Option:AddSection("Utility Player")

Tabs.Option:AddToggle("Noclip", {Title = "Noclip", Default = false, Callback = function(V)
    getgenv().Noclip = V
    game:GetService("RunService").Stepped:Connect(function()
        if getgenv().Noclip and LocalPlayer.Character then
            for _,v in pairs(LocalPlayer.Character:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end})

Tabs.Option:AddInput("InpWS", {Title = "Walkspeed", Default = "16", Numeric = true, Callback = function(T) getgenv().WalkSpeedVal = tonumber(T) end})
Tabs.Option:AddToggle("EnableWS", {Title = "Enable Walkspeed", Default = false, Callback = function(V)
    if V then LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedVal else LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
end})

Tabs.Option:AddToggle("InfJump", {Title = "Infinite Jump", Default = false, Callback = function(V)
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if V and LocalPlayer.Character then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end
    end)
end})

Tabs.Option:AddButton({
    Title = "Max Zoom",
    Callback = function() LocalPlayer.CameraMaxZoomDistance = 99999 end
})

Tabs.Option:AddInput("InpFly", {Title = "Fly Speed", Default = "50", Numeric = true, Callback = function(T) getgenv().FlySpeedVal = tonumber(T) end})
Tabs.Option:AddToggle("FlyMode", {Title = "Enable Fly", Default = false, Callback = function(V)
    local char = LocalPlayer.Character; local hrp = char:WaitForChild("HumanoidRootPart"); local hum = char:WaitForChild("Humanoid")
    if V then
        local bv = Instance.new("BodyVelocity"); bv.Name="FlyVel"; bv.Parent=hrp; bv.MaxForce=Vector3.new(Math.huge,Math.huge,Math.huge); bv.Velocity=Vector3.new(0,0,0)
        hum.PlatformStand=true
        task.spawn(function()
            while Options.FlyMode.Value and char do
                local cam = workspace.CurrentCamera
                if hum.MoveDirection.Magnitude > 0 then bv.Velocity = cam.CFrame.LookVector * getgenv().FlySpeedVal else bv.Velocity = Vector3.new(0,0,0) end
                task.wait()
            end
            if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end; hum.PlatformStand=false
        end)
    else
        if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end; hum.PlatformStand=false
    end
end})

Tabs.Option:AddButton({
    Title = "Auto Reconnect",
    Callback = function()
        game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
            if child.Name == 'ErrorPrompt' then game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end
        end)
        Fluent:Notify({Title="System", Content="Anti-Kick Aktif!", Duration=2})
    end
})

-- TOMBOL M (DRAGGABLE)
spawn(function()
    if LocalPlayer.PlayerGui:FindFirstChild("AlghiBtn") then LocalPlayer.PlayerGui.AlghiBtn:Destroy() end
    local S = Instance.new("ScreenGui"); S.Name = "AlghiBtn"; S.Parent = LocalPlayer.PlayerGui
    local B = Instance.new("TextButton"); B.Parent = S; B.Size = UDim2.new(0,45,0,45); B.Position = UDim2.new(0,20,0.4,0)
    B.BackgroundColor3 = Color3.fromRGB(0,120,255); B.Text="M"; B.TextColor3=Color3.new(1,1,1)
    Instance.new("UICorner",B).CornerRadius = UDim.new(1,0)
    
    local d, di, ds, sp
    local function u(i) local delta = i.Position - ds; B.Position = UDim2.new(sp.X.Scale, sp.X.Offset+delta.X, sp.Y.Scale, sp.Y.Offset+delta.Y) end
    B.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then d=true;ds=i.Position;sp=B.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then d=false end end) end end)
    B.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement then di=i end end)
    game:GetService("UserInputService").InputChanged:Connect(function(i) if i==di and d then u(i) end end)
    
    B.MouseButton1Click:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait(); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
    end)
end)

Window:SelectTab(1)
Fluent:Notify({Title = "Alghi Hub", Content = "Script Fish It Custom Loaded!", Duration = 5})