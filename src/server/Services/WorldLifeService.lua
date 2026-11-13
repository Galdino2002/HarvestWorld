--!strict
-- Adds a cohesive art pass to the generated highlands and each farm entrance.
-- Kept separate from WorldService/FarmService so map decoration can evolve safely.
local WorldLifeService = {}

local rng = Random.new(20261113)

local COLORS = {
    wood = Color3.fromRGB(105, 70, 45),
    warmWood = Color3.fromRGB(151, 105, 66),
    leafA = Color3.fromRGB(71, 128, 67),
    leafB = Color3.fromRGB(91, 146, 75),
    leafC = Color3.fromRGB(119, 157, 78),
    rock = Color3.fromRGB(103, 111, 108),
    rockLight = Color3.fromRGB(137, 143, 132),
}

local function makePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Color = color
    part.Material = material
    part.CastShadow = true
    if shape then
        part.Shape = shape
    end
    part.Parent = parent
    return part
end

local function decorateFarmGate(plot: Model)
    if plot:FindFirstChild("FenceArtPass") then
        return
    end

    local ground = plot.PrimaryPart
    if not ground then
        return
    end

    local center = ground.Position
    local half = 91
    local art = Instance.new("Folder")
    art.Name = "FenceArtPass"
    art.Parent = plot

    -- Rounded timber caps give the repetitive fence posts a deliberate finished top.
    for _, item in plot:GetDescendants() do
        if item:IsA("BasePart") and item.Name == "FencePost" then
            local cap = makePart(
                art,
                "PostCap",
                Vector3.new(1.48, 0.38, 1.48),
                item.Position + Vector3.new(0, item.Size.Y / 2 + 0.12, 0),
                COLORS.warmWood,
                Enum.Material.Wood,
                Enum.PartType.Ball
            )
            cap.Size = Vector3.new(1.38, 0.34, 1.38)
            cap.CanCollide = false
        end
    end

    -- Heavier corner posts and diagonal braces visually anchor the fence to the ground.
    for _, sx in {-1, 1} do
        for _, sz in {-1, 1} do
            local corner = center + Vector3.new(sx * half, 0, sz * half)
            local brace = makePart(
                art,
                "CornerBrace",
                Vector3.new(0.65, 0.65, 12),
                corner + Vector3.new(-sx * 4.8, 2.05, -sz * 4.8),
                COLORS.warmWood,
                Enum.Material.Wood
            )
            brace.CFrame = CFrame.lookAt(brace.Position, corner + Vector3.new(-sx * 12, 2.05, -sz * 12))
            brace.CanCollide = false
        end
    end

    -- A small gate crest, warm lanterns and planted edges make the entrance readable.
    local gateTop = plot:FindFirstChild("GateTop")
    if gateTop and gateTop:IsA("BasePart") then
        local crest = makePart(
            art,
            "GateCrest",
            Vector3.new(25, 0.55, 1.5),
            gateTop.Position + Vector3.new(0, 0.72, 0),
            Color3.fromRGB(174, 126, 76),
            Enum.Material.WoodPlanks
        )
        crest.CanCollide = false

        for _, side in {-1, 1} do
            local lantern = makePart(
                art,
                "GateLantern",
                Vector3.new(1.45, 1.45, 1.45),
                center + Vector3.new(side * 11, 5.7, half),
                Color3.fromRGB(255, 218, 145),
                Enum.Material.Glass,
                Enum.PartType.Ball
            )
            lantern.CanCollide = false
            local light = Instance.new("PointLight")
            light.Color = Color3.fromRGB(255, 210, 137)
            light.Brightness = 0.45
            light.Range = 10
            light.Shadows = false
            light.Parent = lantern
        end
    end

    local flowerColors = {
        Color3.fromRGB(245, 197, 105),
        Color3.fromRGB(225, 139, 164),
        Color3.fromRGB(236, 230, 194),
        Color3.fromRGB(160, 151, 219),
    }
    for index = 1, 16 do
        local x = -70 + index * 9
        local z = half + 5 + (index % 2) * 2
        local stem = makePart(
            art,
            "GateFlowerStem",
            Vector3.new(0.22, 1.25, 0.22),
            center + Vector3.new(x, 0.62, z),
            Color3.fromRGB(69, 119, 58),
            Enum.Material.Grass
        )
        stem.CanCollide = false
        local bloom = makePart(
            art,
            "GateFlower",
            Vector3.new(0.85, 0.85, 0.85),
            stem.Position + Vector3.new(0, 0.72, 0),
            flowerColors[(index % #flowerColors) + 1],
            Enum.Material.SmoothPlastic,
            Enum.PartType.Ball
        )
        bloom.CanCollide = false
    end
end

local function makeMountainTree(parent: Instance, position: Vector3, scale: number)
    local trunkHeight = 8.5 * scale
    local trunk = makePart(
        parent,
        "HighlandTreeTrunk",
        Vector3.new(1.7, trunkHeight, 1.7) * scale,
        position + Vector3.new(0, trunkHeight / 2, 0),
        Color3.fromRGB(104, 76, 55),
        Enum.Material.Wood,
        Enum.PartType.Cylinder
    )
    trunk.Orientation = Vector3.new(0, 0, 90)
    trunk.CanCollide = true

    local crownColor = ({COLORS.leafA, COLORS.leafB, COLORS.leafC})[rng:NextInteger(1, 3)]
    for layer = 1, 3 do
        local width = (8.8 - layer * 1.25) * scale
        local crown = makePart(
            parent,
            "HighlandTreeCrown",
            Vector3.new(width, width * 0.9, width) ,
            position + Vector3.new(0, trunkHeight - 1.5 * scale + layer * 2.4 * scale, 0),
            crownColor,
            Enum.Material.Grass,
            Enum.PartType.Ball
        )
        crown.CanCollide = false
    end
end

local function mountainGarden(ridge: Folder)
    local dressing = Instance.new("Folder")
    dressing.Name = "HighlandLifePass"
    dressing.Parent = ridge

    -- Faceted rock shoulders create a more layered skyline instead of one row of round hills.
    local shoulders = {
        {850, 70, -1535, 150, 95, 120, -18},
        {1035, 92, -1605, 185, 118, 145, 12},
        {1225, 76, -1510, 165, 105, 130, -9},
        {1390, 62, -1400, 145, 88, 115, 16},
        {780, 48, -1330, 125, 78, 105, 8},
        {1320, 55, -1240, 138, 84, 112, -14},
    }

    for index, data in shoulders do
        local base = groundPosition(data[1], data[3])
        local rock = makePart(
            dressing,
            "LayeredMountainShoulder",
            Vector3.new(data[4], data[5], data[6]),
            base + Vector3.new(0, data[5] * 0.22, 0),
            index % 2 == 0 and COLORS.rockLight or COLORS.rock,
            Enum.Material.Rock
        )
        rock.Shape = Enum.PartType.Block
        rock.Orientation = Vector3.new(data[7], (index * 29) % 360, (index % 2 == 0) and 8 or -6)
        rock.CanCollide = true

        local ledge = makePart(
            dressing,
            "MossyMountainLedge",
            Vector3.new(data[4] * 0.78, 5, data[6] * 0.78),
            base + Vector3.new(-12, data[5] * 0.68, 9),
            index % 2 == 0 and COLORS.leafB or COLORS.leafA,
            Enum.Material.Grass
        )
        ledge.Orientation = Vector3.new(0, rock.Orientation.Y, rock.Orientation.Z)
        ledge.CanCollide = false
    end

    -- Trees sit in irregular groups along the lower slopes, leaving the skyline exposed.
    local groves = {
        {770, -1190, 14, 115},
        {1110, -1215, 18, 145},
        {1430, -1110, 12, 110},
        {930, -1430, 10, 100},
    }
    for _, grove in groves do
        for index = 1, grove[3] do
            local angle = rng:NextNumber(0, math.pi * 2)
            local radius = math.sqrt(rng:NextNumber()) * grove[4]
            local position = Vector3.new(
                grove[1] + math.cos(angle) * radius,
                0,
                grove[2] + math.sin(angle) * radius
            )
            makeMountainTree(dressing, position, rng:NextNumber(0.72, 1.12))
        end
    end

    -- Low bushes, ferns and flowers give the trail edges a readable foreground layer.
    local flowerColors = {
        Color3.fromRGB(246, 205, 112),
        Color3.fromRGB(228, 145, 164),
        Color3.fromRGB(240, 236, 206),
    }
    for index = 1, 72 do
        local x = rng:NextNumber(520, 920)
        local z = rng:NextNumber(-1180, -720)
        local nearTrail = (Vector3.new(x, 0, z) - Vector3.new(770, 0, -920)).Magnitude < 95
        if not nearTrail then
            local bush = makePart(
                dressing,
                "HighlandFern",
                Vector3.new(rng:NextNumber(2.2, 3.8), rng:NextNumber(1.2, 2.1), rng:NextNumber(2.2, 3.8)),
                Vector3.new(x, 0.9, z),
                index % 2 == 0 and COLORS.leafA or COLORS.leafB,
                Enum.Material.Grass,
                Enum.PartType.Ball
            )
            bush.CanCollide = false
            if index % 3 == 0 then
                local flower = makePart(
                    dressing,
                    "HighlandWildflower",
                    Vector3.new(0.8, 0.8, 0.8),
                    bush.Position + Vector3.new(0.7, 0.8, 0.4),
                    flowerColors[(index % #flowerColors) + 1],
                    Enum.Material.SmoothPlastic,
                    Enum.PartType.Ball
                )
                flower.CanCollide = false
            end
        end
    end

    -- Stone clusters at the base of the ridge help the mountain meet the meadow naturally.
    for index = 1, 18 do
        local x = rng:NextNumber(690, 1450)
        local z = rng:NextNumber(-1080, -920)
        local size = rng:NextNumber(5, 11)
        local boulder = makePart(
            dressing,
            "RidgeFootBoulder",
            Vector3.new(size * 1.3, size, size),
            Vector3.new(x, size * 0.38, z),
            index % 2 == 0 and COLORS.rockLight or COLORS.rock,
            Enum.Material.Rock,
            Enum.PartType.Ball
        )
        boulder.Orientation = Vector3.new(rng:NextInteger(-12, 12), rng:NextInteger(0, 180), rng:NextInteger(-12, 12))
    end
end

function WorldLifeService.Init()
    local farms = workspace:FindFirstChild("PlayerFarms")
    if farms then
        for _, child in farms:GetChildren() do
            if child:IsA("Model") then
                decorateFarmGate(child)
            end
        end
    end

    local map = workspace:FindFirstChild("HarvestWorldMap")
    local ridge = map and map:FindFirstChild("HighlandRidge")
    if ridge and ridge:IsA("Folder") and not ridge:FindFirstChild("HighlandLifePass") then
        mountainGarden(ridge)
    end

    print("[HarvestWorld] Fence and highland art pass loaded.")
end

return WorldLifeService
