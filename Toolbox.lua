-- 🔥 TOOLBOX FIXED VERSION (API BARU + SPAWN)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("ToolboxGUI") then
    playerGui.ToolboxGUI:Destroy()
end

local isOpen = false
local activeTab = "Models"

-- GUI
local ScreenGui = Instance.new("ScreenGui", playerGui)
ScreenGui.Name = "ToolboxGUI"

local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0,50,0,50)
ToggleButton.Position = UDim2.new(0,10,0.5,-25)
ToggleButton.Text = "🔨"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0,400,0,500)
MainFrame.Position = UDim2.new(0,70,0.5,-250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,35)
MainFrame.Visible = false

-- SEARCH
local SearchBox = Instance.new("TextBox", MainFrame)
SearchBox.Size = UDim2.new(1,-20,0,30)
SearchBox.Position = UDim2.new(0,10,0,10)
SearchBox.PlaceholderText = "Search..."

local SearchBtn = Instance.new("TextButton", MainFrame)
SearchBtn.Size = UDim2.new(0,60,0,30)
SearchBtn.Position = UDim2.new(1,-70,0,10)
SearchBtn.Text = "Go"

-- SCROLL
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1,-20,1,-60)
Scroll.Position = UDim2.new(0,10,0,50)
Scroll.CanvasSize = UDim2.new(0,0,0,0)

local Grid = Instance.new("UIGridLayout", Scroll)
Grid.CellSize = UDim2.new(0,120,0,150)

-- CLEAN FUNCTION
local function clean(model)
    for _,v in pairs(model:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            v:Destroy()
        end
    end
end

-- SPAWN FUNCTION
local function spawnAsset(id)
    local ok, asset = pcall(function()
        return InsertService:LoadAsset(id)
    end)

    if ok and asset then
        asset.Parent = workspace
        clean(asset)

        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            asset:PivotTo(char.HumanoidRootPart.CFrame * CFrame.new(0,0,-10))
        end
    end
end

-- CLEAR
local function clear()
    for _,v in pairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
end

-- CREATE CARD
local function createCard(item)
    local frame = Instance.new("Frame", Scroll)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,50)

    local img = Instance.new("ImageLabel", frame)
    img.Size = UDim2.new(1,0,0,80)
    img.Image = "https://www.roblox.com/asset-thumbnail/image?assetId="..item.id.."&width=150&height=150"

    local name = Instance.new("TextLabel", frame)
    name.Size = UDim2.new(1,0,0,30)
    name.Position = UDim2.new(0,0,0,80)
    name.Text = item.name
    name.TextScaled = true
    name.BackgroundTransparency = 1

    local spawnBtn = Instance.new("TextButton", frame)
    spawnBtn.Size = UDim2.new(1,0,0,30)
    spawnBtn.Position = UDim2.new(0,0,1,-30)
    spawnBtn.Text = "Spawn"

    spawnBtn.MouseButton1Click:Connect(function()
        spawnAsset(item.id)
    end)
end

-- LOAD ITEMS (FIX API)
local function loadItems(keyword)
    clear()

    local url = "https://catalog.roblox.com/v1/search/items/details?Keyword="..keyword.."&Limit=30"

    local ok, res = pcall(game.HttpGet, game, url)

    if ok then
        local data = HttpService:JSONDecode(res)

        if data and data.data then
            for _,item in pairs(data.data) do
                createCard(item)
            end
        end
    end
end

-- EVENTS
SearchBtn.MouseButton1Click:Connect(function()
    loadItems(SearchBox.Text)
end)

ToggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    MainFrame.Visible = isOpen
end)

print("✅ Toolbox FIXED & READY")
