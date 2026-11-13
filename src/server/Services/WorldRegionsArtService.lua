--!strict
-- Shared environmental art pass for every explorable region.
-- Decorative pieces are anchored, grouped and intentionally kept lightweight for mobile.
local WorldRegionsArtService = {}

local WOOD = Color3.fromRGB(104, 72, 48)
local LIGHT_WOOD = Color3.fromRGB(159, 117, 73)
local STONE = Color3.fromRGB(135, 139, 126)
local DARK_STONE = Color3.fromRGB(91, 101, 94)
local GRASS = Color3.fromRGB(89, 139, 75)
local CREAM = Color3.fromRGB(246, 229, 190)

local function part(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Color = color
    p.Material = material
    p.CastShadow = true
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function beam(parent: Instance, name: string, a: Vector3, b: Vector3, thickness: number, color: Color3, material: Enum.Material?)
    local mid = (a + b) / 2
    local p = part(parent, name, Vector3.new(thickness, thickness, (b - a).Magnitude), mid, color, material or Enum.Material.Wood)
    p.CFrame = CFrame.lookAt(mid, b)
    return p
end

local function sign(parent: Instance, position: Vector3, title: string, subtitle: string, facing: number?)
    local model = Instance.new("Model")
    model.Name = "RegionWayfindingSign"
    model.Parent = parent
    local post = part(model, "Post", Vector3.new(0.8, 5.5, 0.8), position + Vector3.new(0, 2.75, 0), WOOD, Enum.Material.Wood)
    local board = part(model, "Board", Vector3.new(10, 3.1, 0.65), position + Vector3.new(0, 5.1, 0), LIGHT_WOOD, Enum.Material.WoodPlanks)
    board.CFrame = CFrame.new(board.Position) * CFrame.Angles(0, math.rad(facing or 0), 0)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.PixelsPerStud = 28
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = title .. "\n" .. subtitle
    label.TextColor3 = CREAM
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
    return model
end

local function bench(parent: Instance, position: Vector3, rotation: number?)
    local model = Instance.new("Model")
    model.Name = "RestBench"
    model.Parent = parent
    local angle = math.rad(rotation or 0)
    local cf = CFrame.new(position) * CFrame.Angles(0, angle, 0)
    local seat = part(model, "Seat", Vector3.new(10, 0.8, 2.2), position + Vector3.new(0, 2, 0), LIGHT_WOOD, Enum.Material.WoodPlanks)
    seat.CFrame = cf * CFrame.new(0, 2, 0)
    local back = part(model, "Back", Vector3.new(10, 2.8, 0.65), position + Vector3.new(0, 3.35, 0), WOOD, Enum.Material.Wood)
    back.CFrame = cf * CFrame.new(0, 3.35, 0.8)
    for _, x in {-3.8, 3.8} do
        local leg = part(model, "Leg", Vector3.new(0.7, 2, 0.7), position + Vector3.new(0, 1, 0), DARK_STONE, Enum.Material.Wood)
        leg.CFrame = cf * CFrame.new(x, 1, 0)
    end
end

local function planter(parent: Instance, position: Vector3, color: Color3)
    local box = part(parent, "TimberPlanter", Vector3.new(8, 1.4, 5), position + Vector3.new(0, 0.7, 0), WOOD, Enum.Material.WoodPlanks)
    for i = 1, 5 do
        local x = position.X - 2.8 + i * 1.1
        local bloom = part(parent, "PlanterFlower", Vector3.new(1.05, 1.05, 1.05), Vector3.new(x, 2, position.Z), color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        bloom.CanCollide = false
    end
    box.CanCollide = true
end

local function villageArt(parent: Instance)
    local f = Instance.new("Folder")
    f.Name = "CentralVillageArt"
    f.Parent = parent

    -- A small fountain anchors the open market square without blocking the main crossing.
    local center = Vector3.new(0, 0, -382)
    local basin = part(f, "VillageFountainBasin", Vector3.new(2.2, 34, 34), center + Vector3.new(0, 1.1, 0), STONE, Enum.Material.Cobblestone, Enum.PartType.Cylinder)
    basin.Orientation = Vector3.new(0, 0, 90)
    basin.CanCollide = true
    local water = part(f, "FountainWater", Vector3.new(0.35, 28, 28), center + Vector3.new(0, 2.25, 0), Color3.fromRGB(105, 181, 205), Enum.Material.Glass, Enum.PartType.Cylinder)
    water.Orientation = Vector3.new(0, 0, 90)
    water.Transparency = 0.18
    water.CanCollide = false
    local column = part(f, "FountainColumn", Vector3.new(7, 5, 5), center + Vector3.new(0, 5.3, 0), Color3.fromRGB(165, 160, 139), Enum.Material.Cobblestone, Enum.PartType.Cylinder)
    local crown = part(f, "FountainCrown", Vector3.new(10, 2, 10), column.Position + Vector3.new(0, 4, 0), STONE, Enum.Material.Cobblestone, Enum.PartType.Ball)
    crown.CanCollide = false

    bench(f, Vector3.new(-76, 0, -382), 90)
    bench(f, Vector3.new(76, 0, -382), -90)
    planter(f, Vector3.new(-92, 0, -310), Color3.fromRGB(235, 145, 164))
    planter(f, Vector3.new(92, 0, -310), Color3.fromRGB(246, 205, 112))

    -- Market pennants add a readable town silhouette from the road.
    for index, x in {-105, -35, 35, 105} do
        local pole = part(f, "MarketPennantPole", Vector3.new(0.7, 13, 0.7), Vector3.new(x, 6.5, -285), WOOD, Enum.Material.Wood)
        local flag = part(f, "MarketPennant", Vector3.new(5, 3.5, 0.35), pole.Position + Vector3.new(2.3, 3.2, 0), index % 2 == 0 and Color3.fromRGB(191, 83, 68) or Color3.fromRGB(91, 139, 83), Enum.Material.Fabric)
        flag.CanCollide = false
    end
    sign(f, Vector3.new(0, 0, -515), "VILA CENTRAL", "Mercado • Oficinas • Encontros")
end

local function woodsArt(parent: Instance)
    local f = Instance.new("Folder")
    f.Name = "WhisperingWoodsArt"
    f.Parent = parent

    -- A small trail gateway and resting place make the forest edge feel intentional.
    local center = Vector3.new(-790, 0, -515)
    for _, x in {-11, 11} do
        part(f, "ForestGatePost", Vector3.new(2, 10, 2), center + Vector3.new(x, 5, 0), WOOD, Enum.Material.Wood)
    end
    beam(f, "ForestGateHeader", center + Vector3.new(-13, 10, 0), center + Vector3.new(13, 10, 0), 2, LIGHT_WOOD)
    local crest = part(f, "ForestGateCrest", Vector3.new(8, 2.4, 0.8), center + Vector3.new(0, 7.2, -0.7), Color3.fromRGB(74, 111, 75), Enum.Material.WoodPlanks)
    crest.CanCollide = false
    sign(f, Vector3.new(-850, 0, -555), "BOSQUE SUSSURRANTE", "Explore com cuidado", 90)

    -- Fallen log seating and mossy stones form a quiet discovery nook off the trail.
    local log = part(f, "FallenLogSeat", Vector3.new(15, 2.2, 3), Vector3.new(-1010, 1.1, -620), Color3.fromRGB(111, 78, 52), Enum.Material.Wood, Enum.PartType.Cylinder)
    log.Orientation = Vector3.new(0, 0, 90)
    for index = 1, 9 do
        local angle = index * math.pi * 2 / 9
        local pos = Vector3.new(-1010 + math.cos(angle) * 12, 0, -620 + math.sin(angle) * 10)
        local stone = part(f, "MossyRestStone", Vector3.new(3.5, 1.8, 3), pos + Vector3.new(0, 0.9, 0), index % 2 == 0 and STONE or DARK_STONE, Enum.Material.Rock, Enum.PartType.Ball)
        stone.CanCollide = true
    end
    for index = 1, 12 do
        local x = -1060 + (index % 4) * 8
        local z = -660 + math.floor(index / 4) * 8
        local mushroom = part(f, "ForestMushroom", Vector3.new(2.4, 1.2, 2.4), Vector3.new(x, 0.8, z), index % 2 == 0 and Color3.fromRGB(202, 115, 91) or Color3.fromRGB(229, 203, 151), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        mushroom.CanCollide = false
    end
end

local function highlandArt(parent: Instance)
    local f = Instance.new("Folder")
    f.Name = "HighlandRidgeArt"
    f.Parent = parent

    -- A low lookout deck marks the beginning of the mountain trail, not its steep summit.
    local center = Vector3.new(675, 0, -820)
    local deck = part(f, "RidgeLookoutDeck", Vector3.new(34, 1.4, 25), center + Vector3.new(0, 1, 0), Color3.fromRGB(126, 91, 61), Enum.Material.WoodPlanks)
    deck.CanCollide = true
    for _, x in {-15, 15} do
        for _, z in {-10, 10} do
            part(f, "LookoutPost", Vector3.new(1.2, 7, 1.2), center + Vector3.new(x, 4.5, z), WOOD, Enum.Material.Wood)
        end
    end
    for _, z in {-10, 10} do
        beam(f, "LookoutRail", center + Vector3.new(-15, 7, z), center + Vector3.new(15, 7, z), 0.8, LIGHT_WOOD)
    end
    sign(f, Vector3.new(635, 0, -850), "TRILHA DA SERRA", "Mirante do vale", 35)

    -- Trail cairns and sparse warning posts reinforce the rocky route without fencing it in.
    for index = 1, 7 do
        local x = 720 + index * 23
        local z = -875 - index * 18
        for layer = 1, 3 do
            local size = 3.6 - layer * 0.55
            local stone = part(f, "TrailCairnStone", Vector3.new(size, 1.1, size), Vector3.new(x, layer * 1.05, z), layer == 3 and Color3.fromRGB(171, 169, 149) or DARK_STONE, Enum.Material.Rock, Enum.PartType.Ball)
            stone.CanCollide = true
        end
    end
end

local function seasonalArt(parent: Instance)
    local f = Instance.new("Folder")
    f.Name = "SeasonalGroundsArt"
    f.Parent = parent
    local center = Vector3.new(1240, 0, 1360)

    -- A welcoming entrance arch gives the event lawn a strong focal point.
    for _, x in {-25, 25} do
        part(f, "FestivalArchPost", Vector3.new(3, 18, 3), center + Vector3.new(x, 9, -175), WOOD, Enum.Material.Wood)
        local lantern = part(f, "FestivalArchLantern", Vector3.new(2.5, 2.5, 2.5), center + Vector3.new(x, 19, -175), Color3.fromRGB(255, 220, 150), Enum.Material.Glass, Enum.PartType.Ball)
        lantern.CanCollide = false
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 205, 135)
        light.Brightness = 0.55
        light.Range = 14
        light.Shadows = false
        light.Parent = lantern
    end
    beam(f, "FestivalArchHeader", center + Vector3.new(-27, 17, -175), center + Vector3.new(27, 17, -175), 2.5, LIGHT_WOOD)
    sign(f, center + Vector3.new(0, 0, -205), "CAMPOS SAZONAIS", "Festivais • Desafios • Recompensas")

    -- Low flower islands frame the lawn while keeping its middle open for future events.
    local colors = {
        Color3.fromRGB(240, 190, 105),
        Color3.fromRGB(221, 135, 163),
        Color3.fromRGB(230, 226, 194),
        Color3.fromRGB(157, 151, 210),
    }
    for index = 1, 4 do
        local x = (index % 2 == 0 and 1 or -1) * 132
        local z = index <= 2 and -95 or 95
        local bed = part(f, "FestivalFlowerIsland", Vector3.new(38, 1, 18), center + Vector3.new(x, 0.5, z), Color3.fromRGB(101, 132, 76), Enum.Material.Grass, Enum.PartType.Cylinder)
        bed.CanCollide = false
        for flowerIndex = 1, 8 do
            local flower = part(f, "FestivalBloom", Vector3.new(2, 1.7, 2), center + Vector3.new(x - 15 + flowerIndex * 4, 1.7, z), colors[((flowerIndex + index) % #colors) + 1], Enum.Material.SmoothPlastic, Enum.PartType.Ball)
            flower.CanCollide = false
        end
    end
    bench(f, center + Vector3.new(-95, 0, 0), 90)
    bench(f, center + Vector3.new(95, 0, 0), -90)
end

local function lakeArt(parent: Instance)
    local f = Instance.new("Folder")
    f.Name = "BluewaterShoreArt"
    f.Parent = parent

    -- A small fishing pier and shore markers make the lake a destination, not just scenery.
    local start = Vector3.new(900, 0, 1030)
    local deck = part(f, "LakePierDeck", Vector3.new(12, 1.2, 62), start + Vector3.new(0, 1, 0), Color3.fromRGB(137, 99, 65), Enum.Material.WoodPlanks)
    deck.CanCollide = true
    for _, x in {-5, 5} do
        for z = -26, 26, 13 do
            part(f, "PierPost", Vector3.new(1.2, 4.5, 1.2), start + Vector3.new(x, 1.2, z), WOOD, Enum.Material.Wood)
        end
        beam(f, "PierRail", start + Vector3.new(x, 4, -29), start + Vector3.new(x, 4, 29), 0.7, LIGHT_WOOD)
    end
    sign(f, Vector3.new(875, 0, 990), "LAGO AZUL", "Píer de observação", 90)
    for index = 1, 10 do
        local x = 830 + index * 14
        local reed = part(f, "ShoreReed", Vector3.new(0.35, 3 + (index % 3), 0.35), Vector3.new(x, 1.5 + (index % 3) * 0.5, 970 + (index % 2) * 9), Color3.fromRGB(100, 130, 76), Enum.Material.Grass)
        reed.CanCollide = false
    end
end

function WorldRegionsArtService.Init()
    local map = workspace:FindFirstChild("HarvestWorldMap")
    if not map then
        warn("[HarvestWorld] WorldRegionsArt skipped: map not found.")
        return
    end

    local old = map:FindFirstChild("WorldRegionsArt")
    if old then old:Destroy() end
    local root = Instance.new("Folder")
    root.Name = "WorldRegionsArt"
    root.Parent = map

    villageArt(root)
    woodsArt(root)
    highlandArt(root)
    seasonalArt(root)
    lakeArt(root)
    print("[HarvestWorld] Shared art pass loaded for village, woods, highlands, seasonal grounds and lake.")
end

return WorldRegionsArtService
