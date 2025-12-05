-- Memuat Library Kavo (Lebih Ringan dari Orion)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fish It Script - By Alghi", "DarkTheme")

-- ==============================
-- TAB 1: FISHING (Fitur Utama)
-- ==============================
local TabFish = Window:NewTab("Fishing")
local SectionFish = TabFish:NewSection("Fitur Memancing")

SectionFish:NewToggle("Auto Cast (Lempar Otomatis)", "Otomatis melempar kail", function(state)
    if state then
        print("Auto Cast: ON")
        -- Di sini biasanya dimasukkan kode 'RemoteEvent' asli game-nya
        -- Contoh simulasi klik mouse:
        -- mouse1click()
    else
        print("Auto Cast: OFF")
    end
end)

SectionFish:NewToggle("Auto Reel (Tarik Otomatis)", "Otomatis menarik ikan", function(state)
    if state then
        print("Auto Reel: ON")
    else
        print("Auto Reel: OFF")
    end
end)

SectionFish:NewButton("Jual Semua Ikan (Sell All)", "Teleport ke tempat jual", function()
    print("Menjual Ikan...")
    -- Kode teleport ke NPC Jual
end)

-- ==============================
-- TAB 2: AUTOMATICALLY (Farming)
-- ==============================
local TabAuto = Window:NewTab("Automatically")
local SectionFarm = TabAuto:NewSection("Auto Farming")

SectionFarm:NewToggle("Auto Farm Money", "Mencari uang otomatis", function(state)
    -- Logika auto farm
end)

-- ==============================
-- TAB 3: TELEPORT (Pindah Tempat)
-- ==============================
local TabTeleport = Window:NewTab("Teleport")
local SectionMap = TabTeleport:NewSection("Lokasi Map")

SectionMap:NewButton("Teleport ke Spawn", "Kembali ke awal", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0) -- Koordinat contoh
end)

SectionMap:NewButton("Teleport ke Toko (Shop)", "Beli alat pancing", function()
    -- Masukkan koordinat toko di sini
end)

-- ==============================
-- TAB 4: PLAYER (Cheat Karakter)
-- ==============================
local TabPlayer = Window:NewTab("Player")
local SectionMove = TabPlayer:NewSection("Gerakan")

SectionMove:NewSlider("Kecepatan Lari (Speed)", "Atur seberapa ngebut", 500, 16, function(s)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

SectionMove:NewSlider("Lompat Tinggi (Jump)", "Atur tinggi lompatan", 500, 50, function(s)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = s
end)

SectionMove:NewButton("Anti AFK", "Biar gak ditendang server", function()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
    print("Anti AFK Aktif")
end)

