-- CARRY GUI SYSTEM
-- LocalScript di StarterPlayerScripts

local ADMIN_NAME = "dockgo_rewin" -- Ganti username kamu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if LocalPlayer.Name ~= ADMIN_NAME then return end

-- ================================
-- BUAT GUI
-- ================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CarryGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 320)
mainFrame.Position = UDim2.new(0, 20, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "🎮 Carry System"
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Text = "Pilih player di bawah"
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Scroll untuk list player
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 0, 160)
scrollFrame.Position = UDim2.new(0, 5, 0, 75)
scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 100, 255)
scrollFrame.Parent = mainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = scrollFrame

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 4)
listPadding.PaddingLeft = UDim.new(0, 4)
listPadding.PaddingRight = UDim.new(0, 4)
listPadding.Parent = scrollFrame

-- Tombol Carry
local carryBtn = Instance.new("TextButton")
carryBtn.Size = UDim2.new(1, -10, 0, 40)
carryBtn.Position = UDim2.new(0, 5, 0, 245)
carryBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
carryBtn.TextColor3 = Color3.new(1, 1, 1)
carryBtn.Text = "▶ Mulai Carry"
carryBtn.TextSize = 14
carryBtn.Font = Enum.Font.GothamBold
carryBtn.BorderSizePixel = 0
carryBtn.Parent = mainFrame

local carryBtnCorner = Instance.new("UICorner")
carryBtnCorner.CornerRadius = UDim.new(0, 8)
carryBtnCorner.Parent = carryBtn

-- Tombol Stop
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(1, -10, 0, 40)
stopBtn.Position = UDim2.new(0, 5, 0, 290)
stopBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.Text = "⏹ Stop Carry"
stopBtn.TextSize = 14
stopBtn.Font = Enum.Font.GothamBold
stopBtn.BorderSizePixel = 0
stopBtn.Parent = mainFrame

local stopBtnCorner = Instance.new("UICorner")
stopBtnCorner.CornerRadius = UDim.new(0, 8)
stopBtnCorner.Parent = stopBtn

-- ================================
-- LOGIC
-- ================================

local selectedPlayer = nil
local followConnection = nil
local isCarrying = false
local playerButtons = {}

local function updateStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color or Color3.fromRGB(180, 180, 180)
end

-- Update list player
local function refreshPlayerList()
	for _, btn in pairs(playerButtons) do
		btn:Destroy()
	end
	playerButtons = {}

	for _, player in pairs(Players:GetPlayers()) do
		if player.Name == ADMIN_NAME then continue end

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Text = "👤 " .. player.Name
		btn.TextSize = 13
		btn.Font = Enum.Font.Gotham
		btn.BorderSizePixel = 0
		btn.Parent = scrollFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btn

		btn.MouseButton1Click:Connect(function()
			-- Reset semua tombol
			for _, b in pairs(playerButtons) do
				b.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
			end
			-- Highlight yang dipilih
			btn.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
			selectedPlayer = player
			updateStatus("Dipilih: " .. player.Name, Color3.fromRGB(100, 200, 255))
		end)

		table.insert(playerButtons, btn)
	end

	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
end

-- Mulai carry
carryBtn.MouseButton1Click:Connect(function()
	if not selectedPlayer then
		updateStatus("⚠ Pilih player dulu!", Color3.fromRGB(255, 200, 50))
		return
	end
	if isCarrying then
		updateStatus("⚠ Sudah carrying!", Color3.fromRGB(255, 200, 50))
		return
	end

	isCarrying = true
	updateStatus("✅ Carrying: " .. selectedPlayer.Name, Color3.fromRGB(100, 255, 150))
	carryBtn.BackgroundColor3 = Color3.fromRGB(30, 140, 70)

	followConnection = RunService.Heartbeat:Connect(function()
		local adminChar = LocalPlayer.Character
		local targetChar = selectedPlayer and selectedPlayer.Character

		if not adminChar or not targetChar then return end

		local adminRoot = adminChar:FindFirstChild("HumanoidRootPart")
		local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
		local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

		if not adminRoot or not targetRoot or not targetHum then return end

		local targetPos = adminRoot.CFrame * CFrame.new(3, 0, 0)
		targetHum:MoveTo(targetPos.Position)
	end)
end)

-- Stop carry
stopBtn.MouseButton1Click:Connect(function()
	if followConnection then
		followConnection:Disconnect()
		followConnection = nil
	end
	isCarrying = false
	carryBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
	updateStatus("⏹ Carry dihentikan", Color3.fromRGB(255, 100, 100))
end)

-- Auto refresh list setiap 3 detik
while true do
	refreshPlayerList()
	task.wait(3)
end
