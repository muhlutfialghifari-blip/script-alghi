-- =========================================================
-- ALGHI HUB (CHLOE X STYLE REMAKE)
-- UI Library: Fluent (Sama seperti yang dipakai Chloe X)
-- =========================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- 1. MEMBUAT JENDELA UTAMA (WINDOW)
-- Ini yang bikin tampilannya kotak hitam elegan kayak Chloe
local Window = Fluent:CreateWindow({
    Title = "Chloe X | Remake by Alghi",
    SubTitle = "Version 1.0.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460), -- Ukuran standar Chloe
    Acrylic = false, -- PENTING: False biar HP gak nge-lag/hitam
    Theme = "Dark", -- Tema gelap
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- 2. MEMBUAT DAFTAR TAB (MENU SAMPING)
-- Saya susun persis sesuai urutan di Chloe X
local Tabs = {
    -- Tab Fishing (Logo Ikan)
    Fishing = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    
    -- Tab Automatically (Logo Play/Segitiga)
    Auto = Window:AddTab({ Title = "Automatically", Icon = "play" }),
    
    -- Tab Trading (Logo Uang/Kartu)
    Trading = Window:AddTab({ Title = "Trading", Icon = "dollar-sign" }),
    
    -- Tab Menu/Shop (Logo Tas)
    Menu = Window:AddTab({ Title = "Menu", Icon = "shopping-bag" }),
    
    -- Tab Quest (Logo Kertas)
    Quest = Window:AddTab({ Title = "Quest", Icon = "clipboard" }),
    
    -- Tab Teleport (Logo Jangkar/Map)
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    
    -- Tab Settings (Wajib ada)
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- =========================================================
-- ISI DARI SETIAP TAB (CONTOH FITUR)
-- =========================================================

-- [[ TAB 1: FISHING ]]
Tabs.Fishing:AddParagraph({
    Title = "Fishing Support",
    Content = "Fitur utama untuk memancing otomatis."
})

-- Fitur Auto Cast (Kita masukkan logika pancingan disini)
local ToggleCast = Tabs.Fishing:AddToggle("AutoCast", {Title = "Auto Cast (Lempar)", Default = false })
ToggleCast:OnChanged(function()
    -- Masukkan kode Auto Cast (Remote Event) di sini
    print("Auto Cast:", Options.AutoCast.Value)
end)

local ToggleCatch = Tabs.Fishing:AddToggle("AutoCatch", {Title = "Instant Catch", Default = false })
ToggleCatch:OnChanged(function()
    -- Masukkan kode Instant Catch di sini
    print("Auto Catch:", Options.AutoCatch.Value)
end)

-- [[ TAB 2: AUTOMATICALLY ]]
Tabs.Auto:AddSection("Farming Features")

Tabs.Auto:AddToggle("AutoSell", {Title = "Auto Sell All (Jual Semua)", Default = false })
Tabs.Auto:AddToggle("AutoAppraise", {Title = "Auto Appraise", Default = false })

-- [[ TAB 3: TRADING ]]
Tabs.Trading:AddInput("TargetPlayer", {
    Title = "Nama Player Target",
    Default = "",
    Placeholder = "Masukkan nama...",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        print("Target:", Value)
    end
})
Tabs.Trading:AddButton({
    Title = "Trade Player",
    Callback = function()
        print("Mengirim trade...")
    end
})

-- [[ TAB 6: TELEPORT ]]
Tabs.Teleport:AddDropdown("Lokasi", {
    Title = "Pilih Lokasi",
    Values = {"Spawn", "Trading Hub", "Deep Ocean", "Volcano"},
    Multi = false,
    Default = 1,
})

Tabs.Teleport:AddButton({
    Title = "Teleport Sekarang",
    Callback = function()
        print("Teleporting...")
    end
})


-- =========================================================
-- TOMBOL DARURAT HP (Biar Menu Bisa Dibuka Tutup)
-- =========================================================
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
    Btn.Size = UDim2.new(0, 50, 0, 50)
    Btn.Position = UDim2.new(0, 30, 0.4, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    Btn.Text = "MENU"
    Btn.TextColor3 = Color3.new(1,1,1)
    
    -- Bikin Bulat
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
    
    -- Fitur Geser Tombol (Draggable)
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

-- FINAL SETUP
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
Window:SelectTab(1)

Fluent:Notify({
    Title = "Script Loaded",
    Content = "Tampilan sudah mirip Chloe X!",
    Duration = 5
})