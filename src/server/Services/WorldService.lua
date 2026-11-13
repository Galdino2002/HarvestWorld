--!strict
-- Greenfields: large shared world, authored regions and harvestable resources.
local WorldService = {}
local Terrain = workspace.Terrain
local root: Folder
local rng = Random.new(481516)

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
 local trunk = makePart(model, "Trunk", Vector3.new(3.2, trunkHeight, 3.2) * scale, position + Vector3.new(0, trunkHeight / 2, 0), kind == "Pine" and Color3.fromRGB(91, 75, 59) or Color3.fromRGB(119, 81, 52), Enum.Material.Wood, Enum.PartType.Cylinder)
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

local function forestRegions()
 local f = folder(root, "Forests")
 makeTreeCluster(f, Vector3.new(-1120, 0, -520), 85, 390, false)
 makeTreeCluster(f, Vector3.new(-1150, 0, 900), 65, 350, false)
 makeTreeCluster(f, Vector3.new(40, 0, -1330), 100, 470, true)
 makeTreeCluster(f, Vector3.new(1330, 0, -720), 60, 330, true)
 makeTreeCluster(f, Vector3.new(1430, 0, 1120), 50, 300, false)
 for i = 1, 52 do
  local x = 900 + rng:NextNumber(-230, 230)
  local z = -950 + rng:NextNumber(-230, 230)
  createRock(f, Vector3.new(x, 0, z), rng:NextNumber(.75, 1.4))
 end
end

local function mountains()
 local f = folder(root, "HighlandRidge")
 -- Terrain hills and rocky outcrops form a distant mountain region.
 for i = 1, 28 do
  local x = 850 + (i % 5) * 115
  local z = -1660 + i * 42
  Terrain:FillBall(Vector3.new(x, 35 + (i % 4) * 12, z), 100 + (i % 3) * 22, i % 3 == 0 and Enum.Material.Rock or Enum.Material.Grass)
 end
 for i = 1, 22 do
  local x = 830 + rng:NextNumber(-170, 380)
  local z = -1500 + rng:NextNumber(-170, 170)
  createRock(f, Vector3.new(x, 0, z), rng:NextNumber(1, 1.8))
 end
 makeRoad(f, "MountainTrail", {Vector3.new(420, 1, -450), Vector3.new(620, 1, -680), Vector3.new(770, 1, -920), Vector3.new(900, 1, -1190)}, 18)
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
end

function WorldService.Init()
 local old = workspace:FindFirstChild("HarvestWorldMap")
 if old then old:Destroy() end
 local oldFarms = workspace:FindFirstChild("PlayerFarms")
 if oldFarms then oldFarms:Destroy() end
 Terrain:Clear()
 root = folder(workspace, "HarvestWorldMap")
 -- A 3.6 km x 3.6 km landmass. Region streaming should be enabled in Studio.
 Terrain:FillBlock(CFrame.new(0, -14, 0), Vector3.new(3600, 28, 3600), Enum.Material.Grass)
 riverAndLake()
 village()
 forestRegions()
 mountains()
 details()
 lighting()
 print("[HarvestWorld] Greenfields expanded: 3.6km world, village, farms, forests, lake and highlands.")
end

return WorldService
