--!strict
-- Region dressing for the shared world. Keeps farm pads, roads, landmarks and water clear.
local WorldLandscapeService = {}

local WOOD = Color3.fromRGB(105, 75, 52)
local LEAF = {
    Color3.fromRGB(76, 132, 73),
    Color3.fromRGB(91, 145, 78),
    Color3.fromRGB(108, 151, 82),
    Color3.fromRGB(64, 112, 83),
}
local FLOWERS = {
    Color3.fromRGB(241, 195, 105),
    Color3.fromRGB(224, 139, 164),
    Color3.fromRGB(242, 232, 198),
    Color3.fromRGB(154, 151, 203),
}
local rng = Random.new(90210)

local function groundPosition(map: Instance, position: Vector3): Vector3
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {map}
    local result = workspace:Raycast(position + Vector3.new(0, 600, 0), Vector3.new(0, -1200, 0), params)
    if result then
        return Vector3.new(position.X, result.Position.Y, position.Z)
    end
    return position
end

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
    p.CastShadow = true
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function tree(parent: Instance, position: Vector3, scale: number, style: number, map: Instance)
    position = groundPosition(map, position)
    local model = Instance.new("Model")
    model.Name = style == 4 and "PineLandmarkTree" or "LandscapeTree"
    model.Parent = parent

    local trunkHeight = 10 * scale
    local trunk = makePart(model, "Trunk", Vector3.new(trunkHeight, 2.1 * scale, 2.1 * scale), position + Vector3.new(0, trunkHeight / 2, 0), WOOD, Enum.Material.Wood, Enum.PartType.Cylinder)
    trunk.Orientation = Vector3.new(0, 0, 90)

    local color = LEAF[style]
    if style == 4 then
        for layer = 1, 3 do
            local cone = makePart(model, "PineLayer", Vector3.new((9 - layer * 1.1) * scale, 6 * scale, (9 - layer * 1.1) * scale), position + Vector3.new(0, trunkHeight - 1 + layer * 3.4 * scale, 0), color, Enum.Material.Grass, Enum.PartType.Ball)
            cone.CanCollide = false
        end
    else
        for index, offset in {{0, 0, 0}, {-3.2, 1.1, 1.4}, {3.1, .8, -1.2}} do
            local size = index == 1 and 9.5 or 7
            local crown = makePart(model, "Canopy", Vector3.new(size, size * .88, size) * scale, position + Vector3.new(offset[1] * scale, trunkHeight + 1.6 * scale + offset[2] * scale, offset[3] * scale), color, Enum.Material.Grass, Enum.PartType.Ball)
            crown.CanCollide = false
        end
    end
end

local function flowerPatch(parent: Instance, center: Vector3, radius: number, count: number, map: Instance)
    local model = Instance.new("Model")
    model.Name = "WildflowerPatch"
    model.Parent = parent
    for index = 1, count do
        local angle = rng:NextNumber(0, math.pi * 2)
        local distance = math.sqrt(rng:NextNumber()) * radius
        local position = groundPosition(map, center + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance))
        local stemHeight = rng:NextNumber(.65, 1.25)
        local stem = makePart(model, "Stem", Vector3.new(.16, stemHeight, .16), position + Vector3.new(0, stemHeight / 2, 0), Color3.fromRGB(70, 119, 62), Enum.Material.Grass)
        stem.CanCollide = false
        local bloom = makePart(model, "Bloom", Vector3.new(.7, .7, .7), position + Vector3.new(0, stemHeight + .25, 0), FLOWERS[rng:NextInteger(1, #FLOWERS)], Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        bloom.CanCollide = false
    end
end

local function rockCluster(parent: Instance, center: Vector3, count: number, radius: number, map: Instance)
    local model = Instance.new("Model")
    model.Name = "ScenicRockCluster"
    model.Parent = parent
    for index = 1, count do
        local angle = rng:NextNumber(0, math.pi * 2)
        local distance = rng:NextNumber(0, radius)
        local size = rng:NextNumber(2.5, 6)
        local ground = groundPosition(map, center + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance))
        local rock = makePart(model, "Rock", Vector3.new(size * 1.25, size * .75, size), ground + Vector3.new(0, size * .32, 0), index % 2 == 0 and Color3.fromRGB(119, 126, 113) or Color3.fromRGB(145, 143, 125), Enum.Material.Rock, Enum.PartType.Ball)
        rock.Orientation = Vector3.new(rng:NextNumber(-12, 12), rng:NextNumber(0, 180), rng:NextNumber(-12, 12))
    end
end

local function grove(parent: Instance, center: Vector3, count: number, radius: number, pineOnly: boolean?, map: Instance)
    for index = 1, count do
        local angle = rng:NextNumber(0, math.pi * 2)
        local distance = math.sqrt(rng:NextNumber()) * radius
        local position = center + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
        local style = pineOnly and 4 or rng:NextInteger(1, 3)
        tree(parent, position, rng:NextNumber(.78, 1.22), style, map)
    end
end

function WorldLandscapeService.Init()
    local map = workspace:FindFirstChild("HarvestWorldMap")
    if not map then
        warn("[HarvestWorld] WorldLandscape skipped: map not found.")
        return
    end

    local previous = map:FindFirstChild("WorldLandscape")
    if previous then previous:Destroy() end
    local root = Instance.new("Folder")
    root.Name = "WorldLandscape"
    root.Parent = map

    -- A broken ring of tree groups frames the central valley without walling off the horizon.
    grove(root, Vector3.new(-1540, 0, -760), 8, 150, false, map)
    grove(root, Vector3.new(-1510, 0, 10), 7, 130, false, map)
    grove(root, Vector3.new(-1530, 0, 850), 8, 145, false, map)
    grove(root, Vector3.new(-1420, 0, 1450), 7, 130, false, map)
    grove(root, Vector3.new(1500, 0, -1370), 8, 145, true, map)
    grove(root, Vector3.new(1510, 0, -500), 7, 125, true, map)
    grove(root, Vector3.new(1510, 0, 520), 8, 140, false, map)
    grove(root, Vector3.new(1450, 0, 1450), 7, 130, false, map)

    -- The woods get a denser edge and a few clearings, not a uniform wall of trees.
    grove(root, Vector3.new(-1370, 0, -640), 13, 210, false, map)
    grove(root, Vector3.new(-890, 0, -1010), 9, 155, false, map)
    flowerPatch(root, Vector3.new(-1000, 0, -850), 24, 22, map)
    flowerPatch(root, Vector3.new(-1320, 0, -390), 20, 18, map)

    -- The ridge gains a readable rocky foothill and small pine groups.
    grove(root, Vector3.new(620, 0, -1390), 9, 175, true, map)
    grove(root, Vector3.new(1320, 0, -1270), 11, 190, true, map)
    rockCluster(root, Vector3.new(710, 0, -1040), 12, 25, map)
    rockCluster(root, Vector3.new(1190, 0, -1110), 15, 34, map)
    rockCluster(root, Vector3.new(950, 0, -1510), 13, 30, map)

    -- The lake shore receives irregular tree groups and flower clearings outside the water.
    grove(root, Vector3.new(790, 0, 1190), 8, 130, false, map)
    grove(root, Vector3.new(1430, 0, 1030), 10, 165, false, map)
    flowerPatch(root, Vector3.new(820, 0, 820), 22, 20, map)
    flowerPatch(root, Vector3.new(1420, 0, 1280), 24, 24, map)
    rockCluster(root, Vector3.new(790, 0, 930), 8, 18, map)

    -- Seasonal grounds have a planted perimeter, leaving the lawn and pavilion unobstructed.
    flowerPatch(root, Vector3.new(1030, 0, 1430), 28, 28, map)
    flowerPatch(root, Vector3.new(1460, 0, 1510), 26, 24, map)
    grove(root, Vector3.new(1580, 0, 1320), 6, 100, false, map)

    -- Soft landscape accents around the village approach; the square and roads stay clear.
    grove(root, Vector3.new(-330, 0, -720), 5, 85, false, map)
    grove(root, Vector3.new(340, 0, -720), 5, 85, false, map)
    flowerPatch(root, Vector3.new(-300, 0, -560), 18, 16, map)
    flowerPatch(root, Vector3.new(300, 0, -560), 18, 16, map)

    -- Natural stone groups at the valley's edge help break the endless green silhouette.
    rockCluster(root, Vector3.new(-1450, 0, 350), 10, 26, map)
    rockCluster(root, Vector3.new(1460, 0, 20), 10, 24, map)
    rockCluster(root, Vector3.new(-1260, 0, 1370), 9, 23, map)

    print("[HarvestWorld] Regional landscape dressing loaded.")
end

return WorldLandscapeService
