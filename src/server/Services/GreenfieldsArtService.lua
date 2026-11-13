--!strict
-- Region 01: authored environmental art for Greenfields.
-- All props are anchored, lightweight and grouped for easy iteration.
local GreenfieldsArtService = {}

local ROOT_NAME = "GreenfieldsArt"
local WOOD = Color3.fromRGB(111, 75, 48)
local LIGHT_WOOD = Color3.fromRGB(158, 116, 73)
local STONE = Color3.fromRGB(133, 137, 119)
local GRASS = Color3.fromRGB(91, 139, 76)

local function part(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Material = material
    p.Color = color
    p.CastShadow = true
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function beam(parent: Instance, name: string, a: Vector3, b: Vector3, thickness: number, color: Color3)
    local mid = (a + b) / 2
    local p = part(parent, name, Vector3.new(thickness, thickness, (b - a).Magnitude), mid, color, Enum.Material.Wood)
    p.CFrame = CFrame.lookAt(mid, b)
    return p
end

local function lantern(parent: Instance, position: Vector3)
    local pole = part(parent, "TrailLanternPost", Vector3.new(.65, 7, .65), position + Vector3.new(0, 3.5, 0), WOOD, Enum.Material.Wood)
    local cap = part(parent, "LanternCap", Vector3.new(2.1, .45, 2.1), pole.Position + Vector3.new(0, 3.7, 0), WOOD, Enum.Material.Wood)
    local glow = part(parent, "WarmLantern", Vector3.new(1.35, 1.35, 1.35), pole.Position + Vector3.new(0, 2.8, 0), Color3.fromRGB(255, 218, 145), Enum.Material.Glass, Enum.PartType.Ball)
    glow.CanCollide = false
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 204, 125)
    light.Brightness = .55
    light.Range = 15
    light.Shadows = false
    light.Parent = glow
end

local function sign(parent: Instance, name: string, position: Vector3, title: string, subtitle: string)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent
    part(model, "Post", Vector3.new(.8, 5, .8), position + Vector3.new(0, 2.5, 0), WOOD, Enum.Material.Wood)
    local board = part(model, "Board", Vector3.new(9, 3.2, .65), position + Vector3.new(0, 4.8, 0), LIGHT_WOOD, Enum.Material.WoodPlanks)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.PixelsPerStud = 32
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = title .. "\n" .. subtitle
    label.TextColor3 = Color3.fromRGB(255, 244, 218)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

local function flowerBed(parent: Instance, center: Vector3, count: number, radius: number)
    local colors = {
        Color3.fromRGB(246, 203, 112),
        Color3.fromRGB(226, 143, 165),
        Color3.fromRGB(239, 235, 208),
        Color3.fromRGB(164, 154, 215),
    }
    local rng = Random.new(math.floor(math.abs(center.X * 17 + center.Z * 31)))
    for i = 1, count do
        local angle = rng:NextNumber(0, math.pi * 2)
        local distance = math.sqrt(rng:NextNumber()) * radius
        local pos = center + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
        local stem = part(parent, "WildflowerStem", Vector3.new(.22, 1.1, .22), pos + Vector3.new(0, .55, 0), GRASS, Enum.Material.Grass)
        stem.CanCollide = false
        local bloom = part(parent, "WildflowerBloom", Vector3.new(.8, .8, .8), stem.Position + Vector3.new(0, .65, 0), colors[(i % #colors) + 1], Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        bloom.CanCollide = false
    end
end

local function stoneRing(parent: Instance, center: Vector3, radius: number, count: number)
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local p = part(parent, "PathStone", Vector3.new(4.2, 1.1, 3.2), center + Vector3.new(math.cos(angle) * radius, .55, math.sin(angle) * radius), STONE, Enum.Material.Cobblestone)
        p.CFrame *= CFrame.Angles(0, -angle, 0)
    end
end

local function elderGrove(parent: Instance)
    local grove = Instance.new("Folder")
    grove.Name = "ElderGrove"
    grove.Parent = parent
    local center = Vector3.new(-700, 0, 120)
    stoneRing(grove, center, 34, 16)
    flowerBed(grove, center + Vector3.new(44, 0, 0), 24, 15)
    flowerBed(grove, center + Vector3.new(-42, 0, 18), 20, 13)

    -- A timber welcome frame makes the ancient tree visible from the approach trail.
    for _, x in {-15, 15} do
        part(grove, "GroveGatePost", Vector3.new(2.2, 12, 2.2), center + Vector3.new(x, 6, 57), WOOD, Enum.Material.Wood)
    end
    beam(grove, "GroveGateHeader", center + Vector3.new(-17, 12, 57), center + Vector3.new(17, 12, 57), 2, LIGHT_WOOD)
    sign(grove, "GroveWelcomeSign", center + Vector3.new(0, 0, 68), "BOSQUE ANTIGO", "Siga em silêncio")
end

local function millCourtyard(parent: Instance)
    local yard = Instance.new("Folder")
    yard.Name = "MillCourtyard"
    yard.Parent = parent
    local center = Vector3.new(510, 0, 240)
    for i = 1, 10 do
        local angle = i * math.pi * 2 / 10
        local x, z = math.cos(angle) * 39, math.sin(angle) * 34
        local stone = part(yard, "CourtyardStone", Vector3.new(6, .45, 5), center + Vector3.new(x, .25, z), Color3.fromRGB(160, 151, 128), Enum.Material.Cobblestone)
        stone.CFrame *= CFrame.Angles(0, -angle, 0)
    end
    flowerBed(yard, center + Vector3.new(43, 0, -30), 18, 12)
    -- Wooden water channel visually connects the mill to the river-side path.
    local channel = part(yard, "MillWaterChannel", Vector3.new(5, 1.2, 46), center + Vector3.new(30, 1.1, -43), Color3.fromRGB(91, 130, 119), Enum.Material.WoodPlanks)
    channel.CanCollide = false
    for _, x in {-3, 3} do
        local rail = part(yard, "ChannelRail", Vector3.new(.55, 1.4, 46), channel.Position + Vector3.new(x, .8, 0), WOOD, Enum.Material.Wood)
        rail.CanCollide = false
    end
    lantern(yard, center + Vector3.new(-42, 0, 20))
    lantern(yard, center + Vector3.new(45, 0, 16))
end

local function cabinCamp(parent: Instance)
    local camp = Instance.new("Folder")
    camp.Name = "WhisperCabinCamp"
    camp.Parent = parent
    local center = Vector3.new(-1170, 0, -775)
    -- A small abandoned campsite tells a story without blocking the cabin entrance.
    local fireBase = part(camp, "ColdFirepit", Vector3.new(8, 1.2, 8), center + Vector3.new(28, .6, 18), STONE, Enum.Material.Rock, Enum.PartType.Cylinder)
    fireBase.CanCollide = true
    for i = 1, 8 do
        local angle = i * math.pi / 4
        part(camp, "FirepitStone", Vector3.new(2, 1.5, 2), center + Vector3.new(28 + math.cos(angle) * 5, 1, 18 + math.sin(angle) * 5), STONE, Enum.Material.Rock, Enum.PartType.Ball)
    end
    local log = part(camp, "OldBenchSeat", Vector3.new(12, 1.2, 2), center + Vector3.new(43, 2, 27), WOOD, Enum.Material.Wood)
    log.Orientation = Vector3.new(0, -28, 0)
    for _, x in {-1, 1} do
        part(camp, "BenchLeg", Vector3.new(1.2, 2, 1.2), log.Position + Vector3.new(x * 4, -1.2, 0), WOOD, Enum.Material.Wood)
    end
    sign(camp, "CabinTrailSign", center + Vector3.new(-36, 0, 42), "CABANA", "A trilha esquecida")
    flowerBed(camp, center + Vector3.new(-32, 0, -28), 14, 10)
end

local function ruinGarden(parent: Instance)
    local garden = Instance.new("Folder")
    garden.Name = "RuinGarden"
    garden.Parent = parent
    local center = Vector3.new(760, 0, 540)
    stoneRing(garden, center, 49, 12)
    flowerBed(garden, center + Vector3.new(0, 0, 63), 28, 17)
    for _, offset in {Vector3.new(-48, 0, -32), Vector3.new(48, 0, -32)} do
        local stone = part(garden, "BrokenPillarBase", Vector3.new(9, 2, 9), center + offset + Vector3.new(0, 1, 0), STONE, Enum.Material.Rock)
        stone.CFrame *= CFrame.Angles(0, .4, math.rad(3))
    end
    sign(garden, "RuinTrailSign", center + Vector3.new(0, 0, 77), "RUÍNAS DO VALE", "Algo repousa aqui")
end

local function trailWayfinding(parent: Instance)
    local markers = {
        {Vector3.new(-610, 0, 220), "ÁRVORE ANCESTRAL"},
        {Vector3.new(-470, 0, 280), "BOSQUE ANTIGO"},
        {Vector3.new(160, 0, 210), "MOINHO"},
        {Vector3.new(330, 0, 230), "MOINHO"},
        {Vector3.new(-1030, 0, -690), "CABANA"},
        {Vector3.new(-900, 0, -560), "CABANA"},
    }
    for index, data in markers do
        local pos = data[1]
        local post = part(parent, "TrailMarkerPost", Vector3.new(.55, 4.2, .55), pos + Vector3.new(0, 2.1, 0), WOOD, Enum.Material.Wood)
        local plate = part(parent, "TrailMarkerPlate", Vector3.new(4.8, 1.25, .35), post.Position + Vector3.new(0, 1.1, 0), LIGHT_WOOD, Enum.Material.WoodPlanks)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.PixelsPerStud = 30
        gui.Parent = plate
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = data[2]
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = Color3.fromRGB(255, 245, 221)
        label.Parent = gui
    end
end

function GreenfieldsArtService.Init()
    local map = workspace:FindFirstChild("HarvestWorldMap")
    if not map then
        warn("[HarvestWorld] GreenfieldsArt skipped: map not found.")
        return
    end
    local old = map:FindFirstChild(ROOT_NAME)
    if old then old:Destroy() end

    local art = Instance.new("Folder")
    art.Name = ROOT_NAME
    art.Parent = map
    elderGrove(art)
    millCourtyard(art)
    cabinCamp(art)
    ruinGarden(art)
    trailWayfinding(art)
    print("[HarvestWorld] Greenfields art pass loaded: grove, mill courtyard, cabin camp, ruins and trail signs.")
end

return GreenfieldsArtService
