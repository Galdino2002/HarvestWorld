--!strict
-- Greenfields: large shared world, authored regions and harvestable resources.
local WorldService = {}
local Terrain = workspace.Terrain
local root: Folder
local rng = Random.new(481516)
local Regions = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("WorldRegions"))

local PALETTE = {
 grass = Color3.fromRGB(112, 158, 86),
 deepGrass = Color3.fromRGB(82, 128, 72),
 wood = Color3.fromRGB(105, 72, 48),
 dirt = Color3.fromRGB(166, 128, 83),
 sand = Color3.fromRGB(196, 177, 128),
 water = Color3.fromRGB(79, 157, 196),
 stone = Color3.fromRGB(119, 119, 112),
}

local function makePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
 local p = Instance.new("Part")
 p.Name = name
 p.Size = size
 p.Position = position
 p.Anchored = true
 p.TopSurface = Enum.SurfaceType.Smooth
 p.BottomSurface = Enum.SurfaceType.Smooth
 p.Color = color
 p.Material = material
 if shape then p.Shape = shape end
 p.Parent = parent
 return p
end

local function folder(parent: Instance, name: string): Folder
 local f = Instance.new("Folder")
 f.Name = name
 f.Parent = parent
 return f
end

local function addResource(player: Player, resource: string, amount: number)
 local stats = player:FindFirstChild("leaderstats")
 local value = stats and stats:FindFirstChild(resource)
 if value and value:IsA("IntValue") then value.Value += amount end
end

local function createHarvestTree(parent: Instance, position: Vector3, scale: number, kind: string)
 local model = Instance.new("Model")
 model.Name = kind .. "Tree"
 model:SetAttribute("ResourceType", "Wood")
 model.Parent = parent
 local trunkHeight = 13 * scale
 local trunk = makePart(model, "Trunk", Vector3.new(trunkHeight, 3.2, 3.2) * scale, position + Vector3.new(0, trunkHeight / 2, 0), kind == "Pine" and Color3.fromRGB(91, 75, 59) or Color3.fromRGB(119, 81, 52), Enum.Material.Wood, Enum.PartType.Cylinder)
 trunk.Orientation = Vector3.new(0, 0, 90)
 local leafColor = kind == "Pine" and Color3.fromRGB(48, 105, 82) or Color3.fromRGB(rng:NextInteger(65, 92), rng:NextInteger(125, 157), rng:NextInteger(65, 91))
 if kind == "Pine" then
  for layer = 1, 3 do
   local cone = makePart(model, "PineCanopy", Vector3.new(10 - layer * 1.8, 8, 10 - layer * 1.8) * scale, position + Vector3.new(0, trunkHeight - 2 + layer * 3.2 * scale, 0), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
   cone.Shape = Enum.PartType.Ball
  end
 else
  makePart(model, "Canopy", Vector3.new(12, 12, 12) * scale, position + Vector3.new(0, trunkHeight + 3 * scale, 0), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
  makePart(model, "CanopyLeft", Vector3.new(8, 8, 8) * scale, position + Vector3.new(-4 * scale, trunkHeight + 2 * scale, 1 * scale), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
  makePart(model, "CanopyRight", Vector3.new(8, 8, 8) * scale, position + Vector3.new(4 * scale, trunkHeight + 2.5 * scale, -1 * scale), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
 end
 local prompt = Instance.new("ProximityPrompt")
 prompt.Name = "ChopPrompt"
 prompt.ActionText = "Cortar (3 golpes)"
 prompt.ObjectText = kind == "Pine" and "Pinheiro" or "Árvore"
 prompt.HoldDuration = 0.7
 prompt.MaxActivationDistance = 13
 prompt.RequiresLineOfSight = false
 prompt.Parent = trunk
 local hits = 0
 local depleted = false
 prompt.Triggered:Connect(function(player)
  if depleted or not player.Character then return end
  local hrp = player.Character:FindFirstChild("HumanoidRootPart")
  if not hrp or (hrp.Position - trunk.Position).Magnitude > 16 then return end
  hits += 1
  if hits < 3 then
   prompt.ActionText = "Cortar (" .. tostring(3 - hits) .. " golpes)"
   trunk.Color = Color3.fromRGB(139, 101, 66)
   return
  end
  depleted = true
  prompt.Enabled = false
  addResource(player, "Wood", 4 + math.floor(scale * 2))
  for _, item in model:GetDescendants() do
   if item:IsA("BasePart") then
    item.CanCollide = false
    item.Transparency = 1
   end
  end
  task.delay(100, function()
   if model.Parent then
    hits = 0
    depleted = false
    for _, item in model:GetDescendants() do
     if item:IsA("BasePart") then item.Transparency = 0; item.CanCollide = item.Name == "Trunk" end
    end
    prompt.ActionText = "Cortar (3 golpes)"
    prompt.Enabled = true
   end
  end)
 end)
 return model
end

local function createRock(parent: Instance, position: Vector3, scale: number)
 local model = Instance.new("Model")
 model.Name = "StoneDeposit"
 model.Parent = parent
 local rock = makePart(model, "Rock", Vector3.new(9, 7, 8) * scale, position + Vector3.new(0, 3 * scale, 0), Color3.fromRGB(120, 124, 119), Enum.Material.Rock, Enum.PartType.Ball)
 rock.Orientation = Vector3.new(rng:NextInteger(-12, 12), rng:NextInteger(0, 180), rng:NextInteger(-12, 12))
 local prompt = Instance.new("ProximityPrompt")
 prompt.ActionText = "Coletar pedra"
 prompt.ObjectText = "Depósito de pedra"
 prompt.HoldDuration = 1
 prompt.MaxActivationDistance = 11
 prompt.Parent = rock
 local depleted = false
 prompt.Triggered:Connect(function(player)
  if depleted or not player.Character then return end
  local hrp = player.Character:FindFirstChild("HumanoidRootPart")
  if not hrp or (hrp.Position - rock.Position).Magnitude > 14 then return end
  depleted = true
  addResource(player, "Stone", 3)
  rock.Transparency = 1
  prompt.Enabled = false
  task.delay(75, function()
   if rock.Parent then rock.Transparency = 0; prompt.Enabled = true; depleted = false end
  end)
 end)
end

local function makeRoad(parent: Instance, name: string, points: {Vector3}, width: number)
 for i = 1, #points - 1 do
  local a, b = points[i], points[i + 1]
  local mid = (a + b) / 2
  local road = makePart(parent, name, Vector3.new(width, .35, (b - a).Magnitude + 3), mid, PALETTE.dirt, Enum.Material.Ground)
  road.CFrame = CFrame.lookAt(mid, b)
 end
end

local function makeTreeCluster(parent: Instance, center: Vector3, count: number, radius: number, pine: boolean?)
 for i = 1, count do
  local angle = rng:NextNumber(0, math.pi * 2)
  local distance = math.sqrt(rng:NextNumber()) * radius
  local x = center.X + math.cos(angle) * distance
  local z = center.Z + math.sin(angle) * distance
  createHarvestTree(parent, Vector3.new(x, 0, z), rng:NextNumber(.72, 1.35), pine and "Pine" or "Oak")
 end
end

local function makeHouse(parent: Instance, name: string, pos: Vector3, wall: Color3, roof: Color3, width: number, depth: number)
 local m = folder(parent, name)
 makePart(m, "Foundation", Vector3.new(width + 6, 1.5, depth + 6), pos + Vector3.new(0, .75, 0), Color3.fromRGB(139, 132, 112), Enum.Material.Cobblestone)
 makePart(m, "Walls", Vector3.new(width, 15, depth), pos + Vector3.new(0, 9, 0), wall, Enum.Material.WoodPlanks)
 local roofA = makePart(m, "RoofA", Vector3.new(width + 10, 2.5, depth / 2 + 6), pos + Vector3.new(0, 17, -depth / 4), roof, Enum.Material.Slate)
 roofA.CFrame *= CFrame.Angles(math.rad(-30), 0, 0)
 local roofB = makePart(m, "RoofB", Vector3.new(width + 10, 2.5, depth / 2 + 6), pos + Vector3.new(0, 17, depth / 4), roof, Enum.Material.Slate)
 roofB.CFrame *= CFrame.Angles(math.rad(30), 0, 0)
 makePart(m, "Door", Vector3.new(4, 8, .7), pos + Vector3.new(0, 4.5, -depth / 2 - .5), PALETTE.wood, Enum.Material.Wood)
 for _, x in {-width / 3, width / 3} do
  makePart(m, "WindowFrame", Vector3.new(5.5, 5.5, .8), pos + Vector3.new(x, 9, -depth / 2 - .5), PALETTE.wood, Enum.Material.Wood)
  makePart(m, "WindowGlass", Vector3.new(4.2, 4.2, .25), pos + Vector3.new(x, 9, -depth / 2 - .95), Color3.fromRGB(131, 199, 216), Enum.Material.Glass)
 end
 makePart(m, "Porch", Vector3.new(width * .78, .6, 7), pos + Vector3.new(0, 2, -depth / 2 - 3), Color3.fromRGB(151, 111, 73), Enum.Material.WoodPlanks)
 for _, x in {-width * .34, width * .34} do makePart(m, "PorchPost", Vector3.new(.8, 7, .8), pos + Vector3.new(x, 4.8, -depth / 2 - 5), PALETTE.wood, Enum.Material.Wood) end
end

local function makeMarketStall(parent: Instance, pos: Vector3, canopy: Color3)
 local stall = folder(parent, "MarketStall")
 makePart(stall, "Counter", Vector3.new(18, 4, 8), pos + Vector3.new(0, 2, 0), Color3.fromRGB(132, 91, 57), Enum.Material.WoodPlanks)
 makePart(stall, "Canopy", Vector3.new(20, 1.2, 10), pos + Vector3.new(0, 7, 0), canopy, Enum.Material.Fabric)
 for _, x in {-8, 8} do makePart(stall, "Post", Vector3.new(.7, 7, .7), pos + Vector3.new(x, 3.5, 0), PALETTE.wood, Enum.Material.Wood) end
end

local function village()
 local f = folder(root, "CentralVillage")
 makePart(f, "VillageGreen", Vector3.new(520, .6, 420), Vector3.new(0, .15, -360), PALETTE.grass, Enum.Material.Grass)
 makePart(f, "MarketSquare", Vector3.new(190, .45, 145), Vector3.new(0, .7, -360), Color3.fromRGB(196, 177, 143), Enum.Material.Cobblestone)
 makeHouse(f, "SeedShop", Vector3.new(-145, 1, -440), Color3.fromRGB(231, 197, 143), Color3.fromRGB(151, 75, 62), 58, 45)
 makeHouse(f, "HarvestMarket", Vector3.new(145, 1, -440), Color3.fromRGB(225, 211, 171), Color3.fromRGB(78, 126, 75), 62, 48)
 makeHouse(f, "Workshop", Vector3.new(-220, 1, -250), Color3.fromRGB(183, 151, 112), Color3.fromRGB(85, 103, 119), 52, 44)
 makeHouse(f, "TownHall", Vector3.new(0, 1, -180), Color3.fromRGB(237, 220, 179), Color3.fromRGB(91, 119, 77), 72, 52)
 makeHouse(f, "Cafe", Vector3.new(220, 1, -250), Color3.fromRGB(231, 174, 151), Color3.fromRGB(129, 82, 68), 52, 44)
 makeMarketStall(f, Vector3.new(-65, 1, -340), Color3.fromRGB(188, 74, 61))
 makeMarketStall(f, Vector3.new(65, 1, -340), Color3.fromRGB(83, 132, 77))
 makeRoad(f, "VillageRoad", {Vector3.new(0, 1, 120), Vector3.new(-35, 1, 30), Vector3.new(25, 1, -65), Vector3.new(0, 1, -160), Vector3.new(0, 1, -260), Vector3.new(0, 1, -390), Vector3.new(0, 1, -520)}, 28)
 for i = 1, 18 do
  local x = rng:NextNumber(-245, 245)
  local z = rng:NextNumber(-535, -145)
  if math.abs(x) > 185 or z > -300 then
   local tree = makePart(f, "VillageTree", Vector3.new(7, 8, 7), Vector3.new(x, 5, z), Color3.fromRGB(85, 142, 76), Enum.Material.Grass, Enum.PartType.Ball)
   tree.Shape = Enum.PartType.Ball
   makePart(f, "VillageTreeTrunk", Vector3.new(1.5, 5, 1.5), Vector3.new(x, 2.5, z), PALETTE.wood, Enum.Material.Wood, Enum.PartType.Cylinder)
  end
 end
 for _, x in {-210, -70, 70, 210} do
  local post = makePart(f, "StreetLamp", Vector3.new(.8, 10, .8), Vector3.new(x, 5, -360), PALETTE.wood, Enum.Material.Wood)
  local bulb = makePart(f, "Lantern", Vector3.new(2.2, 2.2, 2.2), post.Position + Vector3.new(0, 5, 0), Color3.fromRGB(255, 225, 155), Enum.Material.Glass, Enum.PartType.Ball)
  local light = Instance.new("PointLight"); light.Brightness = 1.1; light.Range = 18; light.Parent = bulb
 end
end

local function riverAndLake()
 local f = folder(root, "Waterways")
 local points = {
  Vector3.new(-1650, 0, 20), Vector3.new(-1300, 0, 80), Vector3.new(-950, 0, 45),
  Vector3.new(-600, 0, 5), Vector3.new(-260, 0, 35), Vector3.new(80, 0, 95),
  Vector3.new(420, 0, 145), Vector3.new(760, 0, 125), Vector3.new(1120, 0, 60),
  Vector3.new(1650, 0, 15),
 }
 for i = 1, #points - 1 do
  local a, b = points[i], points[i + 1]
  local mid = (a + b) / 2
  local water = makePart(f, "RiverSection", Vector3.new(78, 2, (b - a).Magnitude + 30), mid, PALETTE.water, Enum.Material.Water)
  water.CFrame = CFrame.lookAt(mid, b)
  for _, side in {-1, 1} do
   local bank = makePart(f, "Riverbank", Vector3.new(94, .8, (b - a).Magnitude + 30), mid + Vector3.new(0, -.25, side * 47), PALETTE.sand, Enum.Material.Sand)
   bank.CFrame = CFrame.lookAt(bank.Position, bank.Position + (b - a))
  end
 end
 -- Lake built from overlapping soft-edged water volumes.
 for _, offset in {Vector3.new(0, 0, 0), Vector3.new(-85, 0, 15), Vector3.new(82, 0, -12), Vector3.new(0, 0, 68)} do
  local lake = makePart(f, "BluewaterLake", Vector3.new(190, 2, 190), Vector3.new(1120, 0, 1030) + offset, PALETTE.water, Enum.Material.Water, Enum.PartType.Ball)
  lake.Size = Vector3.new(190, 2, 190)
  lake.CanCollide = false
 end
 for _, x in {-24, 24} do
  makePart(f, "BridgeRail", Vector3.new(1.5, 5, 110), Vector3.new(x, 5, 95), PALETTE.wood, Enum.Material.Wood)
  for z = 45, 145, 12 do makePart(f, "BridgePost", Vector3.new(1.8, 6, 1.8), Vector3.new(x, 5, z), PALETTE.wood, Enum.Material.Wood) end
 end
 makePart(f, "BridgeDeck", Vector3.new(50, 2, 110), Vector3.new(0, 2, 95), Color3.fromRGB(143, 99, 60), Enum.Material.WoodPlanks)
 makeRoad(f, "BridgeRoadNorth", {Vector3.new(0, 1, -100), Vector3.new(-22, 1, -30), Vector3.new(0, 1, 38)}, 30)
 makeRoad(f, "BridgeRoadSouth", {Vector3.new(0, 1, 152), Vector3.new(35, 1, 220), Vector3.new(65, 1, 310)}, 30)
end


local function farmDistrictRoads()
 local roads = folder(root, "FarmDistrictRoads")
 -- Each lane meets the south entrance of all four plots in that row.
 local layout = Regions.FarmPlots
 makeRoad(roads, "MainFarmLane", {Vector3.new(0, 1, 205), Vector3.new(0, 1, 420), Vector3.new(0, 1, 660), Vector3.new(0, 1, 910)}, 22)
 for row = 0, 2 do
  local z = layout.FirstCenter.Z + row * layout.SpacingZ + 112
  local rowPoints = {Vector3.new(-520, 1, z)}
  for column = 0, layout.Columns - 1 do
   local x = layout.FirstCenter.X + column * layout.SpacingX
   table.insert(rowPoints, Vector3.new(x, 1, z))
   makeRoad(roads, "FarmDriveway", {Vector3.new(x, 1, z), Vector3.new(x, 1, layout.FirstCenter.Z + row * layout.SpacingZ + 96)}, 9)
  end
  table.insert(rowPoints, Vector3.new(520, 1, z))
  makeRoad(roads, "FarmRowLane", rowPoints, 16)
 end
 -- Roadside lamps, signposts and small planted beds give the district scale and landmarks.
 local lampPositions = {Vector3.new(-18, 0, 260), Vector3.new(18, 0, 260)}
 for row = 0, 2 do
  local rowZ = layout.FirstCenter.Z + row * layout.SpacingZ + 112
  table.insert(lampPositions, Vector3.new(-485, 0, rowZ - 13))
  table.insert(lampPositions, Vector3.new(485, 0, rowZ + 13))
 end
 for _, position in lampPositions do
   local pole = makePart(roads, "FarmLaneLamp", Vector3.new(.65, 9, .65), position + Vector3.new(0, 4.5, 0), PALETTE.wood, Enum.Material.Wood)
   local lamp = makePart(roads, "FarmLaneLantern", Vector3.new(1.8, 1.8, 1.8), pole.Position + Vector3.new(0, 4.6, 0), Color3.fromRGB(255, 224, 157), Enum.Material.Glass, Enum.PartType.Ball)
   local light = Instance.new("PointLight")
   light.Brightness = .7
   light.Range = 13
   light.Parent = lamp
 end
 for i = 1, 46 do
  local x = rng:NextNumber(-520, 520)
  local z = rng:NextNumber(180, 980)
  local nearRoad = math.abs(x) < 30 or math.abs(z - 410) < 22 or math.abs(z - 655) < 22 or math.abs(z - 900) < 22
  if not nearRoad then
   local shrub = makePart(roads, "FarmDistrictShrub", Vector3.new(3, 2.2, 3), Vector3.new(x, 1.1, z), Color3.fromRGB(68, 125, 65), Enum.Material.Grass, Enum.PartType.Ball)
   shrub.CanCollide = false
  end
 end
end

local function meadowLife()
 local f = folder(root, "MeadowLife")
 for i = 1, 280 do
  local x = rng:NextNumber(-1580, 1580)
  local z = rng:NextNumber(-1580, 1580)
  local nearTown = math.abs(x) < 310 and z < -100 and z > -590
  local nearFarm = math.abs(x) < 540 and z > 180 and z < 990
  local nearRiver = math.abs(z - (80 + math.sin(x / 400) * 50)) < 100
  local nearMountain = z < -1200 and x > 650
  local nearEventGrounds = (Vector3.new(x, 0, z) - Regions.Regions.SeasonalGrounds.Center).Magnitude < 250
  if not nearTown and not nearFarm and not nearRiver and not nearMountain and not nearEventGrounds then
   local bush = makePart(f, "WildflowerPatch", Vector3.new(rng:NextNumber(2, 4), rng:NextNumber(1, 2), rng:NextNumber(2, 4)), Vector3.new(x, .8, z), Color3.fromRGB(75, rng:NextInteger(120, 150), 67), Enum.Material.Grass, Enum.PartType.Ball)
   bush.CanCollide = false
   if i % 3 == 0 then
    local flower = makePart(f, "Wildflower", Vector3.new(.8, .8, .8), Vector3.new(x + 1.2, 1.1, z), ({Color3.fromRGB(245, 204, 104), Color3.fromRGB(231, 143, 165), Color3.fromRGB(245, 239, 211)})[(i % 3) + 1], Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    flower.CanCollide = false
   end
  end
 end
end

local function forestRegions()
 local f = folder(root, "Forests")
 makeTreeCluster(f, Vector3.new(-1120, 0, -520), 85, 390, false)
 makeTreeCluster(f, Vector3.new(-1150, 0, 900), 65, 350, false)
 makeTreeCluster(f, Vector3.new(40, 0, -1330), 100, 470, true)
 makeTreeCluster(f, Vector3.new(1330, 0, -720), 60, 330, true)
 makeTreeCluster(f, Vector3.new(1510, 0, 650), 50, 270, false)
 for i = 1, 52 do
  local x = 900 + rng:NextNumber(-230, 230)
  local z = -950 + rng:NextNumber(-230, 230)
  createRock(f, Vector3.new(x, 0, z), rng:NextNumber(.75, 1.4))
 end
end

local function mountains()
 local f = folder(root, "HighlandRidge")
 -- Terrain hills and rocky outcrops form a distant mountain region.
 for i = 1, 34 do
  local x = 760 + (i % 6) * 126
  local z = -1680 + i * 43
  local height = 48 + (i % 5) * 17
  local radius = 92 + (i % 3) * 25
  local material = i % 3 == 0 and Enum.Material.Rock or Enum.Material.Ground
  Terrain:FillBall(Vector3.new(x, height, z), radius, material)
  Terrain:FillBall(Vector3.new(x - 42, height - 22, z + 44), radius * .74, material)
 end
 -- Rolling green foothills break the flat horizon and frame the playable valley.
 local foothills = {
  { -1480, -1050, 185 }, { -1510, -420, 155 }, { -1490, 520, 190 },
  { -1320, 1320, 210 }, { -650, 1510, 175 }, { 120, 1510, 165 },
  { 720, 1490, 190 }, { 1480, 1120, 210 }, { 1510, 360, 175 },
  { 1480, -520, 190 }, { 1220, -1390, 210 }, { 380, -1510, 170 },
 }
 for _, hill in foothills do
  Terrain:FillBall(Vector3.new(hill[1], 22, hill[2]), hill[3], Enum.Material.Ground)
 end
 for i = 1, 22 do
  local x = 830 + rng:NextNumber(-170, 380)
  local z = -1500 + rng:NextNumber(-170, 170)
  createRock(f, Vector3.new(x, 0, z), rng:NextNumber(1, 1.8))
 end
 makeRoad(f, "MountainTrail", {Vector3.new(420, 1, -450), Vector3.new(620, 1, -680), Vector3.new(770, 1, -920), Vector3.new(900, 1, -1190)}, 18)
 -- A stepped stream and whitewater ribbon tie the ridge to the river below.
 local cascade = folder(f, "HiddenCascade")
 for step = 0, 5 do
  local y = 72 - step * 10
  local z = -1020 + step * 34
  local pool = makePart(cascade, "CascadePool", Vector3.new(58 + step * 8, 2, 48), Vector3.new(1030, y - 5, z), PALETTE.water, Enum.Material.Water)
  pool.CanCollide = false
  local fall = makePart(cascade, "WaterfallVeil", Vector3.new(30, 17, 2), Vector3.new(1030, y - 5, z - 26), Color3.fromRGB(160, 216, 226), Enum.Material.Glass)
  fall.Transparency = .28
  fall.CanCollide = false
 end
end

local function landmarksAndSeasonalGrounds()
 local landmarks = folder(root, "Landmarks")
 -- Ancient tree: broad layered canopy and a ring path makes it a readable valley landmark.
 local treeBase = Vector3.new(-700, 0, 120)
 local trunk = makePart(landmarks, "ElderTreeTrunk", Vector3.new(8, 38, 8), treeBase + Vector3.new(0, 19, 0), Color3.fromRGB(105, 73, 49), Enum.Material.Wood, Enum.PartType.Cylinder)
 trunk.Orientation = Vector3.new(0, 0, 90)
 for _, item in {{0, 42, 0, 42}, {-17, 36, 2, 28}, {18, 37, -3, 29}, {0, 53, 4, 25}} do
  local crown = makePart(landmarks, "ElderTreeCrown", Vector3.new(item[4], item[4] * .82, item[4]), treeBase + Vector3.new(item[1], item[2], item[3]), Color3.fromRGB(76, 130, 69), Enum.Material.Grass, Enum.PartType.Ball)
  crown.CanCollide = false
 end
 for i = 1, 12 do
  local a = i * math.pi / 6
  local stone = makePart(landmarks, "ElderTreeStone", Vector3.new(5, 2, 3), treeBase + Vector3.new(math.cos(a) * 26, 1, math.sin(a) * 26), Color3.fromRGB(147, 139, 115), Enum.Material.Cobblestone)
  stone.CFrame *= CFrame.Angles(0, -a, 0)
 end
 -- A small watermill silhouette at the village edge.
 local mill = folder(landmarks, "OldWatermill")
 makeHouse(mill, "MillHouse", Vector3.new(510, 1, 240), Color3.fromRGB(167, 128, 83), Color3.fromRGB(106, 71, 55), 44, 42)
 local wheel = makePart(mill, "MillWheel", Vector3.new(28, 3, 28), Vector3.new(537, 14, 196), Color3.fromRGB(119, 82, 50), Enum.Material.Wood, Enum.PartType.Cylinder)
 wheel.Orientation = Vector3.new(0, 0, 90)
 for i = 0, 7 do
  local a = i * math.pi / 4
  local spoke = makePart(mill, "MillSpoke", Vector3.new(2, 1, 27), wheel.Position + Vector3.new(math.cos(a) * 8, math.sin(a) * 8, 0), Color3.fromRGB(142, 102, 65), Enum.Material.WoodPlanks)
  spoke.CFrame *= CFrame.Angles(0, 0, a)
 end
 -- Forest cabin and low ancient stonework offer destinations off the main roads.
 makeHouse(landmarks, "WhisperCabin", Vector3.new(-1170, 1, -775), Color3.fromRGB(138, 105, 72), Color3.fromRGB(74, 86, 70), 32, 28)
 local ruins = folder(landmarks, "OldRuins")
 for i = 0, 5 do
  local a = i * math.pi / 3
  local p = Vector3.new(760 + math.cos(a) * 33, 0, 540 + math.sin(a) * 33)
  local pillar = makePart(ruins, "MossyPillar", Vector3.new(7, 13 + (i % 3) * 3, 7), p + Vector3.new(0, 6, 0), Color3.fromRGB(116, 128, 103), Enum.Material.Rock)
  pillar.CFrame *= CFrame.Angles(0, a, math.rad((i % 2 == 0) and 0 or 4))
 end
 makePart(ruins, "RuinLintel", Vector3.new(70, 6, 8), Vector3.new(760, 17, 540), Color3.fromRGB(116, 128, 103), Enum.Material.Rock)
 -- Open seasonal commons: perimeter planting frames a clear central gathering lawn.
 local seasonal = folder(root, "SeasonalGrounds")
 local center = Regions.Regions.SeasonalGrounds.Center
 makePart(seasonal, "FestivalLawn", Vector3.new(360, .4, 300), center + Vector3.new(0, .2, 0), Color3.fromRGB(119, 166, 91), Enum.Material.Grass)
 for i = 1, 20 do
  local side = i % 4
  local t = math.floor(i / 4)
  local pos = side == 0 and Vector3.new(center.X - 190, 0, center.Z - 130 + t * 52)
   or side == 1 and Vector3.new(center.X + 190, 0, center.Z - 130 + t * 52)
   or side == 2 and Vector3.new(center.X - 150 + t * 62, 0, center.Z - 165)
   or Vector3.new(center.X - 150 + t * 62, 0, center.Z + 165)
  local trunk = makePart(seasonal, "SeasonalTreeTrunk", Vector3.new(2.6, 10, 2.6), pos + Vector3.new(0, 5, 0), PALETTE.wood, Enum.Material.Wood, Enum.PartType.Cylinder)
  trunk.Orientation = Vector3.new(0, 0, 90)
  local crown = makePart(seasonal, "SeasonalTreeCrown", Vector3.new(11, 12, 11), pos + Vector3.new(0, 12, 0), i % 2 == 0 and Color3.fromRGB(79, 137, 73) or Color3.fromRGB(99, 148, 79), Enum.Material.Grass, Enum.PartType.Ball)
  crown.CanCollide = false
 end
 makePart(seasonal, "FestivalPavilionFloor", Vector3.new(56, 1, 42), center + Vector3.new(0, .5, -190), Color3.fromRGB(162, 128, 87), Enum.Material.WoodPlanks)
 for _, x in {-24, 24} do
  makePart(seasonal, "FestivalPavilionPost", Vector3.new(2, 18, 2), center + Vector3.new(x, 9, -190), PALETTE.wood, Enum.Material.Wood)
 end
 makePart(seasonal, "FestivalPavilionRoof", Vector3.new(64, 3, 50), center + Vector3.new(0, 19, -190), Color3.fromRGB(153, 79, 61), Enum.Material.Slate)
end

local function details()
 local f = folder(root, "WorldDetails")
 -- Meadow flowers and boulders around the lake and roads.
 for i = 1, 150 do
  local x = rng:NextNumber(-1550, 1550)
  local z = rng:NextNumber(-1550, 1550)
  local nearTown = math.abs(x) < 290 and z < -120 and z > -570
  local nearFarm = math.abs(x) < 510 and z > 180 and z < 900
  local nearRiver = math.abs(z - (80 + math.sin(x / 400) * 50)) < 65
  if not nearTown and not nearFarm and not nearRiver then
   local color = ({Color3.fromRGB(245, 208, 105), Color3.fromRGB(230, 139, 157), Color3.fromRGB(236, 231, 194)})[(i % 3) + 1]
   local flower = makePart(f, "MeadowFlower", Vector3.new(.9, .9, .9), Vector3.new(x, 1, z), color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
   flower.CanCollide = false
  end
 end
end

local function lighting()
 local Lighting = game:GetService("Lighting")
 Lighting.ClockTime = 14
 Lighting.Brightness = 2.1
 Lighting.Ambient = Color3.fromRGB(142, 151, 132)
 Lighting.OutdoorAmbient = Color3.fromRGB(167, 176, 151)
 Lighting.EnvironmentDiffuseScale = .45
 Lighting.EnvironmentSpecularScale = .3
 local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
 atmosphere.Density = .22
 atmosphere.Offset = .12
 atmosphere.Color = Color3.fromRGB(203, 224, 231)
 atmosphere.Decay = Color3.fromRGB(119, 150, 118)
 atmosphere.Glare = .18
 atmosphere.Haze = 1.4
 atmosphere.Parent = Lighting

 local bloom = Lighting:FindFirstChild("HarvestBloom") or Instance.new("BloomEffect")
 bloom.Name = "HarvestBloom"
 bloom.Intensity = .16
 bloom.Size = 22
 bloom.Threshold = 1.15
 bloom.Parent = Lighting

 local color = Lighting:FindFirstChild("HarvestColor") or Instance.new("ColorCorrectionEffect")
 color.Name = "HarvestColor"
 color.Brightness = .025
 color.Contrast = .08
 color.Saturation = .12
 color.TintColor = Color3.fromRGB(255, 247, 226)
 color.Parent = Lighting

 local rays = Lighting:FindFirstChild("HarvestSunRays") or Instance.new("SunRaysEffect")
 rays.Name = "HarvestSunRays"
 rays.Intensity = .055
 rays.Spread = .72
 rays.Parent = Lighting

 local clouds = Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
 clouds.Cover = .28
 clouds.Density = .34
 clouds.Color = Color3.fromRGB(235, 240, 226)
 clouds.Parent = Terrain
end

function WorldService.Init()
 local old = workspace:FindFirstChild("HarvestWorldMap")
 if old then old:Destroy() end
 Terrain:Clear()
 -- Roblox terrain grass blades pop in/out with camera distance and look oversized on this stylized map.
 -- Keep the ground material readable at every zoom level; foliage is authored as separate world props.
 root = folder(workspace, "HarvestWorldMap")
 -- A 3.6 km x 3.6 km landmass. Region streaming should be enabled in Studio.
 Terrain:SetMaterialColor(Enum.Material.Ground, Color3.fromRGB(112, 148, 88))
 Terrain:FillBlock(CFrame.new(0, -14, 0), Vector3.new(3600, 28, 3600), Enum.Material.Ground)
 riverAndLake()
 village()
 farmDistrictRoads()
 meadowLife()
 forestRegions()
 mountains()
 landmarksAndSeasonalGrounds()
 details()
 lighting()
 print("[HarvestWorld] Greenfields expanded: 3.6km world, village, farms, forests, lake and highlands.")
end

return WorldService
