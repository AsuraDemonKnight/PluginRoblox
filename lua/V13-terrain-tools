-- Creator: BY SYGKMUNII
-- Versi: V13 DELTA EDITION — FULL STUDIO FEATURES
-- Status: Support Delta Executor / Executor lainnya
-- Dilarang jual/beli dengan alasan remake
-- ═══════════════════════════════════════════════════════════
-- TAMBAHAN V13 (dari V12):
-- BATCH A - FITUR INTI:
--  [A1] SEA LEVEL   — isi air sekaligus di bawah Y target
--  [A2] REPLACE MAT — ganti semua material X → Y di terrain
--  [A3] HUD INFO    — overlay mode+ukuran di pojok layar
--  [A4] SPEED BRUSH — slider cooldown brush (1=cepat, 10=lambat)
--  [A5] TAB UI      — panel dibagi 4 tab: ADD/REMOVE/PAINT/TOOL
-- BATCH B - POLISH:
--  [B1] AUTO-SAVE DRAFT — tiap 5 menit simpan _autosave.txt
--  [B2] FILE LIST PANEL — lihat file Terrain*.txt hasil konversi
--  [B3] SCROLL WHEEL    — scroll = resize brush
--  [B4] PANEL MINIMIZE  — klik title = minimize/expand panel
--  [B5] KATEGORI MAT    — material dikelompokkan Alam/Buatan/Air
-- KONVERSI SYNC:
--  Sea Level & Replace Mat masuk generateScriptChunks()
--  sehingga hasil file .txt bisa reproduce terrain 100% akurat
-- ═══════════════════════════════════════════════════════════

local Players      = game:GetService("Players")
local Workspace    = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local player       = Players.LocalPlayer
local mouse        = player:GetMouse()

local PlayerGui = player:WaitForChild("PlayerGui", 15)
local oldGui    = PlayerGui:FindFirstChild("TerrainBuilderDelta")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "TerrainBuilderDelta"
screenGui.ResetOnSpawn    = false
screenGui.IgnoreGuiInset  = true
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder    = 999
screenGui.Parent          = PlayerGui

local pluginFrame = Instance.new("Frame")
pluginFrame.Name   = "MainFrame"
pluginFrame.Parent = screenGui

-- ═══ SHARED STATE TABLE ═══
local _TB = {}

-- clipboard compat
if not setclipboard then
	if rbxsetclipboard then setclipboard = rbxsetclipboard
	elseif syn and syn.clipboard and syn.clipboard.set then setclipboard = syn.clipboard.set
	else setclipboard = function(t) warn("[TB] clipboard N/A") end end
end

local function safeWriteFile(path, content)
	local ok, err = pcall(function() writefile(path, content) end)
	return ok, err
end
local function safeReadFile(path)
	local ok, content = pcall(function() return readfile(path) end)
	return ok and content or nil
end
local function safeMakeFolder(path)
	pcall(function() if not isfolder(path) then makefolder(path) end end)
end
local function safeListFiles(path)
	local ok, files = pcall(function() return listfiles(path) end)
	return ok and files or {}
end

repeat task.wait() until player and player:IsDescendantOf(game)
if not player.Character then player.CharacterAdded:Wait() end
task.wait(0.5)

-- ═══════════════════════════════════════════════════════════
-- KONSTANTA
-- ═══════════════════════════════════════════════════════════
local PANEL_W        = 290
local PANEL_H        = 290
local TERRAIN_LIMIT  = 660
local SCRIPT_CHAR_LIMIT = 200000
local DELTA_WORKSPACE   = "Delta/Workspace"
local HASIL_FOLDER      = DELTA_WORKSPACE .. "/HASIL TERRAIN"
local AUTOSAVE_PATH     = HASIL_FOLDER .. "/_autosave.txt"
local AUTOSAVE_INTERVAL = 300  -- 5 menit

-- ═══════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════
_TB.width=6; _TB.height=6; _TB.depth=6
_TB.currentBlockSize = Vector3.new(6, 6, 6)
_TB.rotationAngle    = 0
_TB.brushStrength    = 5
_TB.brushOpacity     = 0.65
_TB.brushCooldown    = 0.05  -- [A4] adjustable
_TB.brushSpeed       = 5     -- 1=cepat(0.01s) 10=lambat(0.15s)

_TB.placementEnabled     = false
_TB.autoConvertToTerrain = false
_TB.tunnelMode           = false
_TB.brushTerrainOnly     = false
_TB.treeBrushReady       = false
_TB.treeBrushActive      = false
_TB.swipeMode            = false
_TB.swipeModeActive      = false
_TB.isMouseDown          = false
_TB.panelVisible         = true
_TB.panelMinimized       = false  -- [B4]
_TB.limitReached         = false
_TB.lockY                = false
_TB.lockedY              = 0

-- [A1] Sea Level
_TB.seaLevelY    = 0
_TB.seaLevelMode = false
-- [A2] Replace Material
_TB.replaceSrcMat = "Grass"
_TB.replaceDstMat = "Sand"
-- [A5] Tab aktif
_TB.activeTab = "ADD"  -- ADD / REMOVE / PAINT / TOOL

-- Special modes
_TB.flattenMode  = false
_TB.smoothMode   = false
_TB.erodeMode    = false
_TB.growMode     = false
_TB.paintMode    = false
_TB.flattenTargetY = 0

-- timing
_TB.lastBrushTime        = 0
_TB.lastTreeBrushTime    = 0
_TB.treeBrushCooldown    = 0.5
_TB.lastSwipeBrushTime   = 0
_TB.swipeBrushCooldown   = 0.05
_TB.lastSwipePos         = nil
_TB.lastSpecialBrushTime = 0
_TB.specialBrushCooldown = 0.08
_TB.lastAutoSave         = 0

-- undo/redo
_TB.brushUndoStack = {}
_TB.brushRedoStack = {}

-- clear confirm
_TB.clearConfirmPending = false
_TB.clearConfirmTimer   = nil

-- ═══════════════════════════════════════════════════════════
-- DATA MATERIAL
-- ═══════════════════════════════════════════════════════════
local materials = {
	"Grass","Ground","Mud","Sand","Snow","LeafyGrass",
	"Rock","Slate","Basalt","Cobblestone","Granite","Limestone",
	"Pavement","Salt","CrackedLava","Marble",
	"Water","Ice","Glacier",
	"Brick","Concrete","Plastic","Wood","WoodPlanks","Metal","DiamondPlate"
}

-- [B5] Kategori material
local materialCategory = {
	Grass="Alam",LeafyGrass="Alam",Ground="Alam",Mud="Alam",Sand="Alam",
	Snow="Alam",Rock="Alam",Slate="Alam",Basalt="Alam",Cobblestone="Alam",
	Granite="Alam",Limestone="Alam",Pavement="Alam",Salt="Alam",
	CrackedLava="Alam",Marble="Alam",
	Water="Air",Ice="Air",Glacier="Air",
	Brick="Buatan",Concrete="Buatan",Plastic="Buatan",
	Wood="Buatan",WoodPlanks="Buatan",Metal="Buatan",DiamondPlate="Buatan",
}

local materialNames = {
	Grass="Rumput",Ground="Tanah",Mud="Lumpur",Sand="Pasir",Snow="Salju",
	LeafyGrass="Rumput Daun",Rock="Batuan",Slate="Batu Tulis",Basalt="Basalt",
	Cobblestone="Bebatuan",Granite="Granit",Limestone="Batu Kapur",
	Pavement="Perkerasan",Salt="Garam",CrackedLava="Lava Retak",Marble="Marmer",
	Water="Air",Ice="Es",Glacier="Gletser",
	Brick="Batu Bata",Concrete="Beton",Plastic="Plastik",
	Wood="Kayu",WoodPlanks="Papan Kayu",Metal="Logam",DiamondPlate="Berlian"
}
_TB.matIndex      = 1
_TB.currentMaterial = materials[_TB.matIndex]

local grassColors = {
	{name="Hijau Muda",color=Color3.fromRGB(150,220,120)},{name="Hijau Cerah",color=Color3.fromRGB(120,200,100)},
	{name="Hijau Normal",color=Color3.fromRGB(75,151,75)},{name="Hijau Sedang",color=Color3.fromRGB(60,140,70)},
	{name="Hijau Tua",color=Color3.fromRGB(45,120,55)},{name="Hijau Gelap",color=Color3.fromRGB(30,100,40)},
	{name="Hijau Lumut",color=Color3.fromRGB(80,120,60)},{name="Hijau Zamrud",color=Color3.fromRGB(50,180,100)},
	{name="Hijau Mint",color=Color3.fromRGB(170,230,150)},{name="Hijau Daun",color=Color3.fromRGB(70,160,80)},
	{name="Hijau Hutan",color=Color3.fromRGB(40,90,50)},{name="Hijau Zaitun",color=Color3.fromRGB(85,107,47)},
	{name="Hijau Pinus",color=Color3.fromRGB(50,100,60)},{name="Hijau Tropis",color=Color3.fromRGB(90,180,110)},
	{name="Hijau Pastel",color=Color3.fromRGB(140,210,130)},{name="Hijau Neon",color=Color3.fromRGB(100,255,150)},
	{name="Hijau Apel",color=Color3.fromRGB(140,200,100)},{name="Hijau Toska",color=Color3.fromRGB(100,180,140)},
	{name="Hijau Army",color=Color3.fromRGB(70,85,50)},{name="Hijau Botol",color=Color3.fromRGB(40,70,45)}
}
_TB.currentGrassColorIndex = 3
local groundColors = {
	{name="Coklat Muda",color=Color3.fromRGB(160,120,80)},{name="Coklat Normal",color=Color3.fromRGB(120,85,50)},
	{name="Coklat Tanah",color=Color3.fromRGB(102,92,59)},{name="Coklat Tua",color=Color3.fromRGB(75,55,30)},
	{name="Coklat Gelap",color=Color3.fromRGB(50,35,15)}
}
_TB.currentGroundColorIndex = 3

local grassOnlyMaterials   = {Grass=true,LeafyGrass=true}
local groundOnlyMaterials  = {Ground=true,Mud=true}
local colorableMaterials   = {Grass=true,LeafyGrass=true,Ground=true,Mud=true}
local terrainOnlyMaterials = {
	Grass=true,Ground=true,Mud=true,Sand=true,Snow=true,LeafyGrass=true,
	Rock=true,Slate=true,Basalt=true,Cobblestone=true,Granite=true,
	Limestone=true,Pavement=true,Salt=true,CrackedLava=true,Marble=true,
	Water=true,Ice=true,Glacier=true
}
local materialToNumber = {
	Grass=1,Ground=2,Mud=3,Sand=4,Snow=5,LeafyGrass=6,Rock=7,Slate=8,
	Basalt=9,Cobblestone=10,Granite=11,Limestone=12,Pavement=13,Salt=14,
	CrackedLava=15,Marble=16,Water=17,Ice=18,Glacier=19
}
local materialColors = {
	Grass=Color3.fromRGB(75,151,75),Ground=Color3.fromRGB(102,92,59),
	Mud=Color3.fromRGB(92,64,51),Sand=Color3.fromRGB(194,178,128),
	Snow=Color3.fromRGB(239,240,240),LeafyGrass=Color3.fromRGB(106,134,64),
	Rock=Color3.fromRGB(110,110,110),Slate=Color3.fromRGB(85,87,98),
	Basalt=Color3.fromRGB(60,60,60),Cobblestone=Color3.fromRGB(132,126,135),
	Granite=Color3.fromRGB(130,130,130),Limestone=Color3.fromRGB(230,228,220),
	Pavement=Color3.fromRGB(115,115,115),Salt=Color3.fromRGB(230,230,230),
	CrackedLava=Color3.fromRGB(232,88,40),Marble=Color3.fromRGB(220,220,230),
	Water=Color3.fromRGB(0,162,255),Ice=Color3.fromRGB(175,221,255),
	Glacier=Color3.fromRGB(200,230,255),Brick=Color3.fromRGB(138,86,62),
	Concrete=Color3.fromRGB(150,150,150),Plastic=Color3.fromRGB(255,255,255),
	Wood=Color3.fromRGB(139,94,60),WoodPlanks=Color3.fromRGB(160,110,75),
	Metal=Color3.fromRGB(200,200,200),DiamondPlate=Color3.fromRGB(170,170,170)
}
local materialEnum = {
	Grass=Enum.Material.Grass,Ground=Enum.Material.Ground,Mud=Enum.Material.Mud,
	Sand=Enum.Material.Sand,Snow=Enum.Material.Snow,LeafyGrass=Enum.Material.LeafyGrass,
	Rock=Enum.Material.Rock,Slate=Enum.Material.Slate,Basalt=Enum.Material.Basalt,
	Cobblestone=Enum.Material.Cobblestone,Granite=Enum.Material.Granite,
	Limestone=Enum.Material.Limestone,Pavement=Enum.Material.Pavement,
	Salt=Enum.Material.Salt,CrackedLava=Enum.Material.CrackedLava,
	Marble=Enum.Material.Marble,Water=Enum.Material.Water,Ice=Enum.Material.Ice,
	Glacier=Enum.Material.Glacier,Brick=Enum.Material.Brick,
	Concrete=Enum.Material.Concrete,Plastic=Enum.Material.Plastic,
	Wood=Enum.Material.Wood,WoodPlanks=Enum.Material.WoodPlanks,
	Metal=Enum.Material.Metal,DiamondPlate=Enum.Material.DiamondPlate
}

local shapes     = {"Balok","Bola","Baji","Silinder","Sudut"}
_TB.shapeIndex = 1
_TB.currentShape = "Balok"

_TB.terrainDataByMaterial = {}
_TB.lastBrushPos   = nil
_TB.brushTrailParts = {}
_TB.swipeData      = {}

-- [A1] Data sea level untuk konversi
_TB.seaLevelData = {}  -- {y, matName, areaSize, grR, grG, grB}

-- [A2] Data replace untuk konversi
_TB.replaceData  = {}  -- {fromMat, toMat, grR, grG, grB}

-- ═══════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════
local function makeDraggable(frame, handle)
	local h = handle or frame
	local dragging, dragStart, startPos = false, nil, nil
	h.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	h.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
			local d = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
		end
	end)
end

local function colorToRGB(c) return math.floor(c.R*255+0.5),math.floor(c.G*255+0.5),math.floor(c.B*255+0.5) end
local function getActiveColorRGB(matName)
	if grassOnlyMaterials[matName] then return colorToRGB(grassColors[_TB.currentGrassColorIndex].color)
	elseif groundOnlyMaterials[matName] then return colorToRGB(groundColors[_TB.currentGroundColorIndex].color) end
	return 0,0,0
end
local function getFolder(matName)
	local f = Workspace:FindFirstChild(matName)
	if not f then f=Instance.new("Folder");f.Name=matName;f.Parent=Workspace end
	return f
end
local function getTotalTerrainCount()
	local n = 0
	for _,list in pairs(_TB.terrainDataByMaterial) do
		for _,d in ipairs(list) do if not d._undone then n=n+1 end end
	end
	return n
end

local deletedFolder = Workspace:FindFirstChild("DeletedParts") or Instance.new("Folder")
deletedFolder.Name="DeletedParts"; deletedFolder.Parent=Workspace; deletedFolder.Archivable=false

-- ═══════════════════════════════════════════════════════════
-- VOLUME & SIZE ACCURATE
-- ═══════════════════════════════════════════════════════════
local function calcVolume(shape, sx, sy, sz)
	if shape=="Bola" then local r=sx/2; return (4/3)*math.pi*r*r*r
	elseif shape=="Silinder" then local r=math.max(sx,sz)*0.6/2; return math.pi*r*r*sy
	elseif shape=="Baji" or shape=="Sudut" then return sx*sy*sz*0.5
	else return sx*sy*sz end
end
local function getAccurateSize(shape, sx, sy, sz)
	if shape=="Bola" then local r=sx/2; return Vector3.new(r*2,r*2,r*2),r
	elseif shape=="Silinder" then return Vector3.new(sx,sy,sz),math.max(sx,sz)*0.6
	else return Vector3.new(sx,sy,sz),nil end
end

-- ═══════════════════════════════════════════════════════════
-- PERSISTENT CONFIG
-- ═══════════════════════════════════════════════════════════
local function saveColorsPersistent()
	local config = Workspace:FindFirstChild("TerrainBuilderConfig") or Instance.new("Configuration")
	config.Name="TerrainBuilderConfig"; config.Parent=Workspace; config.Archivable=true
	local function sv(name,cls,val)
		local v=config:FindFirstChild(name) or Instance.new(cls)
		v.Name=name;v.Value=val;v.Parent=config;v.Archivable=true
	end
	sv("GrassColorIndex","IntValue",_TB.currentGrassColorIndex)
	sv("GrassR","NumberValue",grassColors[_TB.currentGrassColorIndex].color.R)
	sv("GrassG","NumberValue",grassColors[_TB.currentGrassColorIndex].color.G)
	sv("GrassB","NumberValue",grassColors[_TB.currentGrassColorIndex].color.B)
	sv("GroundColorIndex","IntValue",_TB.currentGroundColorIndex)
	sv("GroundR","NumberValue",groundColors[_TB.currentGroundColorIndex].color.R)
	sv("GroundG","NumberValue",groundColors[_TB.currentGroundColorIndex].color.G)
	sv("GroundB","NumberValue",groundColors[_TB.currentGroundColorIndex].color.B)
	local T=Workspace:FindFirstChild("Terrain")
	if T then
		T:SetMaterialColor(Enum.Material.Grass,grassColors[_TB.currentGrassColorIndex].color)
		T:SetMaterialColor(Enum.Material.LeafyGrass,grassColors[_TB.currentGrassColorIndex].color)
		T:SetMaterialColor(Enum.Material.Ground,groundColors[_TB.currentGroundColorIndex].color)
		T:SetMaterialColor(Enum.Material.Mud,groundColors[_TB.currentGroundColorIndex].color)
	end
end
local function loadColorsPersistent()
	local config=Workspace:FindFirstChild("TerrainBuilderConfig"); if not config then return end
	local gi=config:FindFirstChild("GrassColorIndex")
	if gi and grassColors[gi.Value] then _TB.currentGrassColorIndex=gi.Value end
	local gri=config:FindFirstChild("GroundColorIndex")
	if gri and groundColors[gri.Value] then _TB.currentGroundColorIndex=gri.Value end
end

-- ═══════════════════════════════════════════════════════════
-- TERRAIN CORE
-- ═══════════════════════════════════════════════════════════
local function applyMaterialColor(T, matName, matE)
	if grassOnlyMaterials[matName] then T:SetMaterialColor(matE,grassColors[_TB.currentGrassColorIndex].color)
	elseif groundOnlyMaterials[matName] then T:SetMaterialColor(matE,groundColors[_TB.currentGroundColorIndex].color) end
end

local function doTerrainFill(T, pos, size, shape, matE, rot)
	local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(rot or 0),0)
	local accSize,accRadius=getAccurateSize(shape,size.X,size.Y,size.Z)
	if shape=="Bola" then T:FillBall(pos,accRadius,matE)
	elseif shape=="Silinder" then T:FillCylinder(cf*CFrame.Angles(0,0,math.rad(90)),size.Y,accRadius,matE)
	else T:FillBlock(cf,accSize,matE) end
end

local function applyTerrainForPart(part, matName)
	local T=Workspace:FindFirstChild("Terrain"); if not T then return end
	if not terrainOnlyMaterials[matName] then return end
	local matE=materialEnum[matName]; if not matE then return end
	pcall(function()
		local sz=part.Size
		local shapeStr=part:IsA("WedgePart") and "Baji" or
			(part.Shape==Enum.PartType.Ball and "Bola" or
			(part.Shape==Enum.PartType.Cylinder and "Silinder" or "Balok"))
		local accSize,accRadius=getAccurateSize(shapeStr,sz.X,sz.Y,sz.Z)
		if part.Shape==Enum.PartType.Ball then T:FillBall(part.Position,accRadius,matE)
		elseif part.Shape==Enum.PartType.Cylinder then T:FillCylinder(part.CFrame*CFrame.Angles(0,0,math.rad(90)),sz.Y,accRadius,matE)
		else T:FillBlock(part.CFrame,accSize,matE) end
		applyMaterialColor(T,matName,matE)
	end)
end

local function applyTerrainDirectly(pos, size, shape, matName, rotDeg)
	local T=Workspace:FindFirstChild("Terrain"); if not T then return nil end
	if not terrainOnlyMaterials[matName] then return nil end
	local matE=materialEnum[matName]; if not matE then return nil end
	if not _TB.terrainDataByMaterial[matName] then _TB.terrainDataByMaterial[matName]={} end
	local isColorable=colorableMaterials[matName] and true or false
	local sR,sG,sB=0,0,0
	if isColorable then sR,sG,sB=getActiveColorRGB(matName) end
	local rot=rotDeg or 0
	local vol=calcVolume(shape,size.X,size.Y,size.Z)
	local entry={position=pos,size=size,shape=shape,material=matName,isColorable=isColorable,grR=sR,grG=sG,grB=sB,rotation=rot,volume=vol,_undone=false}
	table.insert(_TB.terrainDataByMaterial[matName],entry)
	pcall(function() doTerrainFill(T,pos,size,shape,matE,rot); applyMaterialColor(T,matName,matE) end)
	return entry
end

local function convertPartsToTerrain()
	local T=Workspace:FindFirstChild("Terrain"); if not T then return 0 end
	local c=0
	for _,matName in ipairs(materials) do
		if terrainOnlyMaterials[matName] then
			local f=Workspace:FindFirstChild(matName)
			if f then for _,part in ipairs(f:GetChildren()) do
				if part:IsA("BasePart") then pcall(function() applyTerrainForPart(part,matName);c=c+1 end) end
			end end
		end
	end
	return c
end

-- ═══════════════════════════════════════════════════════════
-- [A1] SEA LEVEL — isi Water di bawah Y target
-- Data disimpan ke _TB.seaLevelData agar masuk konversi script
-- ═══════════════════════════════════════════════════════════
local function applySeaLevel(targetY, matName, areaHalfSize)
	local T=Workspace:FindFirstChild("Terrain"); if not T then return false end
	local matE=materialEnum[matName] or Enum.Material.Water
	local stepSize=8
	local R=areaHalfSize or 200
	local isColorable=colorableMaterials[matName] and true or false
	local grR,grG,grB=0,0,0
	if isColorable then grR,grG,grB=getActiveColorRGB(matName) end
	pcall(function()
		for dx=-R,R,stepSize do
			for dz=-R,R,stepSize do
				-- Isi dari bawah (targetY-areaHalfSize) sampai targetY
				local fillPos=Vector3.new(dx,targetY-stepSize/2,dz)
				local fillSize=Vector3.new(stepSize,stepSize,stepSize)
				T:FillBlock(CFrame.new(fillPos),fillSize,matE)
			end
			task.wait()
		end
		applyMaterialColor(T,matName,matE)
	end)
	-- Simpan ke _TB.seaLevelData untuk konversi
	table.insert(_TB.seaLevelData,{
		y=targetY, matName=matName, areaSize=R,
		isColorable=isColorable, grR=grR, grG=grG, grB=grB,
		stepSize=stepSize
	})
	return true
end

-- ═══════════════════════════════════════════════════════════
-- [A2] REPLACE MATERIAL
-- Ganti semua terrain material X → Y
-- Data disimpan ke _TB.replaceData agar masuk konversi script
-- ═══════════════════════════════════════════════════════════
local function doReplaceMaterial(fromMat, toMat)
	local T=Workspace:FindFirstChild("Terrain"); if not T then return 0 end
	local fromEnum
