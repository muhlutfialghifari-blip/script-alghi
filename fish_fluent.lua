-- =========================================================
-- ALGHI HUB - FISHING FIX VERSION
-- Fitur: Smart Remote Finder + Debug Status
-- =========================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fish Hub | Fix Version",
    SubTitle = "Mobile",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Fishing = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Settings = Window:AddTab({ Title = "System", Icon = "settings" })
}

local Options = Fluent.Options

-- [[ 1. FUNGSI PENCARI REMOTE CERDAS ]]
-- Ini akan mengaduk-aduk folder game untuk mencari jalur yang benar
local function FindRemoteFolder()
    local RS = game:GetService("ReplicatedStorage")
    
    -- Coba Jalur 1 (Jalur Umum)
    if RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("_Index") then
        for _, child in pairs(RS.Packages._Index:GetChildren()) do
            if child.Name:find("net@") and child:FindFirstChild("net") then
                return child.net
            end
        end
    end
    
    -- Coba Jalur 2 (Langsung folder Events)
    if RS:FindFirstChild("Events") then return RS.Events end
    
    return nil
end

-- Cari folder sekarang
local NetFolder = FindRemoteFolder()

-- [[ TAB FISHING ]]

-- STATUS LABEL (Biar kamu tau scriptnya lagi ngapain)
local StatusPar = Tabs.Fishing:AddParagraph({
    Title = "Status Script",
    Content = "Menunggu..."
})

-- Update Status
local function UpdateStatus(text)
    StatusPar:SetDesc(text)
end

-- Cek apakah Remote ketemu?
if NetFolder then
    UpdateStatus("✅ Remote Folder Ditemukan!\nNama: " .. NetFolder.Parent.Name)
else
    UpdateStatus("❌ Remote Folder TIDAK KETEMU!\nFitur Fishing mungkin gagal.")
end

-- AUTO CAST
local ToggleCast = Tabs.Fishing:AddToggle("AutoCast", {Title = "Auto Cast (Lempar)", Default = false })

ToggleCast:OnChanged(function()
    task.spawn(function()
        while Options.AutoCast.Value do
            if NetFolder then
                -- Cari event Lempar
                local event = NetFolder:FindFirstChild("RF/RequestFishingMinigameStarted")
                
                if event then
                    UpdateStatus("🎣 Melempar Kail...")
                    -- Argumen standar game ini
                    local args = {
                        [1] = 100, -- Kekuatan Lempar
                        [2] = 1,   -- Akurasi
                        [3] = tick() -- Waktu
                    }
                    event:InvokeServer(unpack(args))
                    UpdateStatus("✅ Berhasil Lempar!")
                else
                    UpdateStatus("❌ Event 'RequestFishing' hilang!")
                end
            else
                UpdateStatus("❌ Folder Remote Error!")
            end
            task.wait(3.5) -- Jeda lempar
        end
        if not Options.AutoCast.Value then UpdateStatus("⏹️ Auto Cast Berhenti.") end
    end)
end)

-- INSTANT CATCH
local ToggleCatch = Tabs.Fishing:AddToggle("AutoCatch", {Title = "Auto Catch (Tangkap)", Default = false })

ToggleCatch:OnChanged(function()
    task.spawn(function()
        while Options.AutoCatch.Value do
            if NetFolder then
                local event = NetFolder:FindFirstChild("RE/FishingCompleted")
                if event then
                    event:FireServer()
                    -- Gak usah update status biar gak spam
                end
            end
            task.wait(1.5)
        end
    end)
end)

-- [[ TAB SYSTEM ]]
Tabs.Settings:AddButton({
    Title = "Reload Script",
    Callback = function()
        Window:Destroy()
        UpdateStatus("Reloading...")
    end
})

-- [[ TOMBOL HP ]]
spawn(function()
    if game.Players.LocalPlayer.PlayerGui:FindFirstChild("AlghiButton") then 
        game.Players.LocalPlayer.PlayerGui.AlghiButton:Destroy() 
    end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AlghiButton"
    ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
    
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 45, 0, 45)
    Btn.Position = UDim2.new(0, 30, 0.4, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    Btn.Text = "M"
    Btn.TextColor3 = Color3.new(1,1,1)
    
    local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(1,0); Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait()
        vim:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
    end)
end)

Window:SelectTab(1)