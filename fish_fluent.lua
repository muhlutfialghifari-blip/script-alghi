-- Memuat Library Fluent (Desain Modern)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Membuat Jendela (Window)
local Window = Fluent:CreateWindow({
    Title = "Fish It Hub " .. Fluent.Version,
    SubTitle = "by Alghi",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460), -- Ukuran pas buat HP
    Acrylic = false, -- SAYA MATIKAN BIAR GAK NGE-LAG DI HP
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Membuat Tab (Menu Samping)
local Tabs = {
    Main = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Farm = Window:AddTab({ Title = "Auto Farm", Icon = "dollar-sign" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ==============================
-- TAB 1: FISHING
-- ==============================
Tabs.Main:AddParagraph({
    Title = "Status Memancing",
    Content = "Gunakan fitur ini saat berada di dekat air."
})

-- Toggle Auto Cast
local ToggleCast = Tabs.Main:AddToggle("AutoCast", {Title = "Auto Cast (Lempar)", Default = false })
ToggleCast:OnChanged(function()
    print("Auto Cast:", Options.AutoCast.Value)
    -- Logika auto cast di sini
end)

-- Toggle Auto Reel
local ToggleReel = Tabs.Main:AddToggle("AutoReel", {Title = "Auto Reel (Tarik)", Default = false })
ToggleReel:OnChanged(function()
    print("Auto Reel:", Options.AutoReel.Value)
end)

-- Toggle Instant Catch
local ToggleInstant = Tabs.Main:AddToggle("InstantCatch", {Title = "Instant Catch (Langsung Dapat)", Default = false })

-- ==============================
-- TAB 2: AUTO FARM
-- ==============================
Tabs.Farm:AddToggle("AutoSell", {Title = "Auto Sell (Jual Ikan)", Default = false })
Tabs.Farm:AddToggle("AutoAppraise", {Title = "Auto Appraise (Cek Harga)", Default = false })

Tabs.Farm:AddDropdown("DropdownArea", {
    Title = "Pilih Lokasi Teleport",
    Values = {"Spawn", "Toko (Shop)", "Pulau Hiu", "Zona Dalam"},
    Multi = false,
    Default = 1,
})

Tabs.Farm:AddButton({
    Title = "Teleport Sekarang",
    Description = "Pindah ke lokasi yang dipilih",
    Callback = function()
        Window:Dialog({
            Title = "Teleport",
            Content = "Sedang memindahkan karakter...",
            Buttons = {
                {
                    Title = "Oke",
                    Callback = function()
                        print("Teleporting...")
                    end
                }
            }
        })
    end
})

-- ==============================
-- TAB 3: PLAYER
-- ==============================
local SliderSpeed = Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Kecepatan Lari",
    Description = "Atur kecepatan jalan kamu",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

local SliderJump = Tabs.Player:AddSlider("JumpPower", {
    Title = "Kekuatan Lompat",
    Description = "Atur tinggi lompatan",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end
})

-- ==============================
-- SETUP AKHIR (Wajib Ada)
-- ==============================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

-- Notifikasi kalau script sudah siap
Fluent:Notify({
    Title = "Script Alghi Siap",
    Content = "Selamat menggunakan Fluent UI!",
    Duration = 5
})

