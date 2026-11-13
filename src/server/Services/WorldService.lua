--!strict
local WorldService = {}
local root: Folder
local Terrain = workspace.Terrain

local C = {
 grass = Color3.fromRGB(116, 165, 91),
 darkGrass = Color3.fromRGB(91, 143, 76),
 wood = Color3.fromRGB(105, 72, 48),
 dirt = Color3.fromRGB(177, 139, 91),
 water = Color3.fromRGB(83, 166, 202),
 cream = Color3.fromRGB(239, 218, 174),
}

local function part(parent: Instance, name: string, size: Vector3, pos: Vector3, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
 local p = Instance.new("Part")
 p.Name = name; p.Size = size; p.Position = pos; p.Anchored = true
 p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
 p.Color = color; p.Material = material
 if shape then p.Shape = shape end
 p.Parent = parent
 return p
end

local function tree(parent: Instance, x: number, z: number, scale: number, palette: number)
 local trunk = part(parent, "TreeTrunk", Vector3.new(2.1, 7, 2.1) * scale, Vector3.new(x, 3.5 * scale, z), C.wood, Enum.Material.Wood, Enum.PartType.Cylinder)
 trunk.Orientation = Vector3.new(0, 0, 90)
 local colors = {
  Color3.fromRGB(73, 137, 73), Color3.fromRGB(91, 151, 77),
  Color3.fromRGB(116, 158, 76), Color3.fromRGB(67, 124, 91),
 }
 local leafColor = colors[palette]
 part(parent, "TreeCanopy", Vector3.new(9, 10, 9) * scale, Vector3.new(x, 8 * scale, z), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
 part(parent, "TreeCanopyLeft", Vector3.new(6.5, 7, 6.5) * scale, Vector3.new(x - 3.1 * scale, 7 * scale, z + .7 * scale), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
 part(parent, "TreeCanopyRight", Vector3.new(6.7, 7.5, 6.7) * scale, Vector3.new(x + 3 * scale, 7.5 * scale, z - .5 * scale), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
end

local function roadSegment(parent: Instance, name: string, a: Vector3, b: Vector3, width: number)
 local delta = b - a
 local midpoint = (a + b) / 2
 local p = part(parent, name, Vector3.new(width, .22, delta.Magnitude), midpoint, C.dirt, Enum.Material.Ground)
 p.CFrame = CFrame.lookAt(midpoint, b)
end

local function curvedPath(parent: Instance, name: string, points: {Vector3}, width: number)
 for i = 1, #points - 1 do roadSegment(parent, name, points[i], points[i + 1], width) end
 for _, point in points do
  part(parent, name .. "SoftEdge", Vector3.new(width, .2, width), point, C.dirt, Enum.Material.Ground, Enum.PartType.Ball)
 end
end

local function building(parent: Instance, name: string, pos: Vector3, wall: Color3, roof: Color3, w: number, d: number)
 local m = Instance.new("Model"); m.Name = name; m.Parent = parent
 part(m, "StoneFoundation", Vector3.new(w + 5, 1.4, d + 5), pos + Vector3.new(0, .7, 0), Color3.fromRGB(139, 133, 116), Enum.Material.Cobblestone)
 part(m, "MainWalls", Vector3.new(w, 13, d), pos + Vector3.new(0, 7.5, 0), wall, Enum.Material.WoodPlanks)
 -- Telhado em duas águas, para fugir do aspecto de caixa.
 local roofLeft = part(m, "RoofSlopeLeft", Vector3.new(w + 8, 2.2, d / 2 + 5), pos + Vector3.new(0, 15, -d / 4), roof, Enum.Material.Slate)
 roofLeft.CFrame = CFrame.new(roofLeft.Position) * CFrame.Angles(math.rad(-28), 0, 0)
 local roofRight = part(m, "RoofSlopeRight", Vector3.new(w + 8, 2.2, d / 2 + 5), pos + Vector3.new(0, 15, d / 4), roof, Enum.Material.Slate)
 roofRight.CFrame = CFrame.new(roofRight.Position) * CFrame.Angles(math.rad(28), 0, 0)
 part(m, "FrontDoor", Vector3.new(4.2, 8, .7), pos + Vector3.new(0, 4.7, -d / 2 - .5), C.wood, Enum.Material.Wood)
 for _, x in {-w / 3, w / 3} do
  part(m, "WindowFrame", Vector3.new(5.2, 5.2, .8), pos + Vector3.new(x, 8.5, -d / 2 - .5), C.wood, Enum.Material.Wood)
  part(m, "WindowGlass", Vector3.new(4, 4, .25), pos + Vector3.new(x, 8.5, -d / 2 - .95), Color3.fromRGB(133, 201, 214), Enum.Material.Glass)
 end
 for _, x in {-w / 3, w / 3} do
  part(m, "PorchPost", Vector3.new(.8, 7, .8), pos + Vector3.new(x, 4, -d / 2 - 4), C.wood, Enum.Material.Wood)
 end
 part(m, "Porch", Vector3.new(w * .8, .6, 7), pos + Vector3.new(0, 1.8, -d / 2 - 3), Color3.fromRGB(151, 112, 75), Enum.Material.WoodPlanks)
end

local function village()
 local f = Instance.new("Folder"); f.Name = "CentralVillage"; f.Parent = root
 part(f, "VillageGreen", Vector3.new(360, .5, 270), Vector3.new(0, .2, -300), C.grass, Enum.Material.Grass)
 part(f, "MarketSquare", Vector3.new(120, .4, 90), Vector3.new(0, .8, -300), Color3.fromRGB(202, 177, 139), Enum.Material.Cobblestone)
 building(f, "SeedShop", Vector3.new(-88, 1, -360), Color3.fromRGB(231, 197, 143), Color3.fromRGB(155, 75, 62), 48, 38)
 building(f, "HarvestMarket", Vector3.new(88, 1, -360), Color3.fromRGB(225, 211, 171), Color3.fromRGB(78, 126, 75), 52, 42)
 building(f, "Workshop", Vector3.new(-135, 1, -225), Color3.fromRGB(183, 151, 112), Color3.fromRGB(85, 103, 119), 42, 38)
 building(f, "TownHall", Vector3.new(0, 1, -190), Color3.fromRGB(237, 220, 179), Color3.fromRGB(91, 119, 77), 58, 42)
 building(f, "Cafe", Vector3.new(135, 1, -225), Color3.fromRGB(231, 174, 151), Color3.fromRGB(129, 82, 68), 42, 38)
 curvedPath(f, "VillageRoad", {
  Vector3.new(0, 1, -90), Vector3.new(-12, 1, -145), Vector3.new(8, 1, -205),
  Vector3.new(0, 1, -265), Vector3.new(0, 1, -335), Vector3.new(0, 1, -420),
 }, 22)
 for _, x in {-155, -55, 55, 155} do
  local post = part(f, "VillageLampPost", Vector3.new(.8, 9, .8), Vector3.new(x, 5, -300), C.wood, Enum.Material.Wood)
  local lamp = part(f, "Lantern", Vector3.new(2.4, 2.4, 2.4), post.Position + Vector3.new(0, 5, 0), Color3.fromRGB(255, 224, 148), Enum.Material.Glass, Enum.PartType.Ball)
  local light = Instance.new("PointLight"); light.Color = lamp.Color; light.Brightness = 1.2; light.Range = 20; light.Parent = lamp
 end
end

local function river()
 local f = Instance.new("Folder"); f.Name = "HarvestRiver"; f.Parent = root
 -- Trechos sobrepostos e curvos: o rio deixa de ser uma única faixa retangular.
 local centers = {
  Vector3.new(-550, 0, 95), Vector3.new(-420, 0, 75), Vector3.new(-290, 0, 55),
  Vector3.new(-160, 0, 45), Vector3.new(-25, 0, 55), Vector3.new(110, 0, 78),
  Vector3.new(245, 0, 98), Vector3.new(380, 0, 90), Vector3.new(550, 0, 65),
 }
 for i = 1, #centers - 1 do
  local a = centers[i]; local b = centers[i + 1]
  local mid = (a + b) / 2
  local delta = b - a
  local water = part(f, "RiverBend", Vector3.new(58, 1.8, delta.Magnitude + 18), mid, C.water, Enum.Material.Water)
  water.CFrame = CFrame.lookAt(mid, b)
  part(f, "RiverPool", Vector3.new(58, 1.8, 58), a, C.water, Enum.Material.Water, Enum.PartType.Cylinder)
 end
 for _, side in {-1, 1} do
  for i = 1, #centers - 1 do
   local a = centers[i]; local b = centers[i + 1]
   local mid = (a + b) / 2
   local delta = b - a
   local bank = part(f, "SandyRiverBank", Vector3.new(72, 1, delta.Magnitude + 20), mid + Vector3.new(0, -.3, side * 38), Color3.fromRGB(174, 158, 112), Enum.Material.Sand)
   bank.CFrame = CFrame.lookAt(bank.Position, bank.Position + delta)
  end
 end
 local deck = part(f, "BridgeDeck", Vector3.new(34, 2, 100), Vector3.new(0, 2, 62), Color3.fromRGB(139, 96, 59), Enum.Material.WoodPlanks)
 for _, x in {-16, 16} do
  part(f, "BridgeRail", Vector3.new(1.2, 4, 100), Vector3.new(x, 4.8, 62), C.wood, Enum.Material.Wood)
  for z = 18, 106, 12 do part(f, "BridgePost", Vector3.new(1.6, 6, 1.6), Vector3.new(x, 5, z), C.wood, Enum.Material.Wood) end
 end
 curvedPath(f, "BridgeNorthPath", {Vector3.new(0, 1, -75), Vector3.new(-12, 1, -25), Vector3.new(0, 1, 18)}, 28)
 curvedPath(f, "BridgeSouthPath", {Vector3.new(0, 1, 108), Vector3.new(20, 1, 150), Vector3.new(38, 1, 205)}, 28)
end

local function nature()
 local f = Instance.new("Folder"); f.Name = "Nature"; f.Parent = root
 -- Bordas de bosque, com árvores em grupos e escalas diferentes.
 for i = 1, 38 do
  local z = -500 + (i % 13) * 78
  local scale = .75 + (i % 5) * .13
  tree(f, -520 - (i % 4) * 16, z, scale, (i % 4) + 1)
  tree(f, 520 + (i % 4) * 16, z + 24, scale + .08, ((i + 1) % 4) + 1)
 end
 for i = 1, 24 do
  tree(f, -470 + i * 40, -520 - (i % 3) * 18, .7 + (i % 4) * .12, (i % 4) + 1)
 end
 -- Colinas suaves usando Terrain, sem grandes blocos aparentes.
 for i = 1, 18 do
  local side = if i % 2 == 0 then -1 else 1
  local x = side * (390 + (i % 4) * 35)
  local z = -460 + i * 55
  Terrain:FillBall(Vector3.new(x, 8, z), 58 + (i % 3) * 12, Enum.Material.Grass)
 end
 -- Pedras, arbustos e flores ao longo dos caminhos.
 for i = 1, 45 do
  local x = -420 + (i * 37) % 840
  local z = -120 + (i * 53) % 350
  if math.abs(x) > 95 then
   local shrub = part(f, "WildShrub", Vector3.new(4, 3, 4), Vector3.new(x, 1.2, z), Color3.fromRGB(74, 132, 70), Enum.Material.Grass, Enum.PartType.Ball)
   shrub.Size *= .8 + (i % 4) * .12
  end
 end
end

local function lighting()
 local Lighting = game:GetService("Lighting")
 Lighting.ClockTime = 14.2
 Lighting.Brightness = 2
 Lighting.Ambient = Color3.fromRGB(145, 151, 137)
 Lighting.OutdoorAmbient = Color3.fromRGB(165, 172, 153)
 Lighting.EnvironmentDiffuseScale = .35
 Lighting.EnvironmentSpecularScale = .25
 local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
 atmosphere.Density = .24; atmosphere.Offset = .15
 atmosphere.Color = Color3.fromRGB(199, 220, 225)
 atmosphere.Decay = Color3.fromRGB(112, 145, 123)
 atmosphere.Glare = .15; atmosphere.Haze = 1.1
 atmosphere.Parent = Lighting
end

function WorldService.Init()
 local defaultBaseplate = workspace:FindFirstChild("Baseplate")
 if defaultBaseplate and defaultBaseplate:IsA("BasePart") then defaultBaseplate:Destroy() end
 local existing = workspace:FindFirstChild("HarvestWorldMap")
 if existing then existing:Destroy() end
 root = Instance.new("Folder"); root.Name = "HarvestWorldMap"; root.Parent = workspace
 Terrain:FillBlock(CFrame.new(0, -12, 0), Vector3.new(1200, 22, 1200), Enum.Material.Grass)
 river(); village(); nature(); lighting()
 print("[HarvestWorld] Greenfields natural environment generated.")
end

return WorldService
