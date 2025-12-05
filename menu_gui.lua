-- Memuat Library Orion (Agar tampilan menu jadi keren otomatis)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- 1. Membuat Jendela Utama (Window)
local Window = OrionLib:MakeWindow({
    Name = "Script Alghi V1", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "ScriptAlghi"
})

-- 2. Membuat Tab (Halaman Menu)
local TabUtama = Window:MakeTab({
	Name = "Menu Utama",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- 3. Membuat Tombol Lari Cepat
TabUtama:AddButton({
	Name = "Lari Cepat (Speed 100)",
	Callback = function()
        -- Kode yang jalan saat tombol dipencet
      	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
        OrionLib:MakeNotification({
            Name = "Sukses!",
            Content = "Kecepatan diubah jadi 100",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
  	end    
})

-- 4. Membuat Tombol Lompat Tinggi
TabUtama:AddButton({
	Name = "Lompat Tinggi (High Jump)",
	Callback = function()
      	game.Players.LocalPlayer.Character.Humanoid.JumpPower = 120
  	end    
})

-- 5. Membuat Tombol Reset (Kembali Normal)
TabUtama:AddButton({
	Name = "Reset Normal",
	Callback = function()
      	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
  	end    
})

-- Menutup Library agar menu muncul
OrionLib:Init()

