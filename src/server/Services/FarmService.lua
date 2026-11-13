--!strict
local FarmService = {}

local plotsFolder: Folder
local playerPlots: {[Player]: Model} = {}

local GRASS = Color3.fromRGB(112, 174, 91)
local WOOD = Color3.fromRGB(112, 72, 43)
local CREAM = Color3.fromRGB(255, 239, 198)

local function part(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
    local item = Instance.new("Part")
    item.Name = name
    item.Size = size
    item.Position = position
    item.Anchored = true
    item.TopSurface = Enum.SurfaceType.Smooth
    item.BottomSurface = Enum.SurfaceType.Smooth
    item.Color = color
    item.Material = material
    item.Parent = parent
    return item
end

local function makeTree(parent: Instance, origin: Vector3, scale: number)
    local trunk = part(parent, "TreeTrunk", Vector3.new(1.4, 5, 1.4) * scale, origin + Vector3.new(0, 2.5, 0), WOOD, Enum.Material.Wood)
    trunk.Shape = Enum.PartType.Cylinder
    local leaves = part(parent, "TreeCanopy", Vector3.new(6, 6, 6) * scale, origin + Vector3.new(0, 6, 0), Color3.fromRGB(75, 145, 72), Enum.Material.Grass)
    leaves.Shape = Enum.PartType.Ball
end

local function makeFlower(parent: Instance, origin: Vector3, petalColor: Color3)
    part(parent, "FlowerStem", Vector3.new(0.18, 1.1, 0.18), origin + Vector3.new(0, 0.55, 0), Color3.fromRGB(64, 125, 59), Enum.Material.Grass)
    local bloom = part(parent, "FlowerBloom", Vector3.new(0.8, 0.8, 0.8), origin + Vector3.new(0, 1.1, 0), petalColor, Enum.Material.SmoothPlastic)
    bloom.Shape = Enum.PartType.Ball
end

local function createFence(model: Model, center: Vector3)
    local half = 27
    for _, z in {-half, half} do
        for x = -half, half, 9 do
            part(model, "FencePost", Vector3.new(0.8, 2.4, 0.8), center + Vector3.new(x, 1.2, z), WOOD, Enum.Material.Wood)
        end
        part(model, "FenceRail", Vector3.new(54, 0.35, 0.35), center + Vector3.new(0, 1.75, z), Color3.fromRGB(155, 105, 66), Enum.Material.Wood)
    end
    for _, x in {-half, half} do
        for z = -half, half, 9 do
            part(model, "FencePost", Vector3.new(0.8, 2.4, 0.8), center + Vector3.new(x, 1.2, z), WOOD, Enum.Material.Wood)
        end
        part(model, "FenceRail", Vector3.new(0.35, 0.35, 54), center + Vector3.new(x, 1.75, 0), Color3.fromRGB(155, 105, 66), Enum.Material.Wood)
    end
end

local function createPlot(index: number): Model
    local model = Instance.new("Model")
    model.Name = "FarmPlot_" .. index

    local column = (index - 1) % 4
    local row = math.floor((index - 1) / 4)
    local center = Vector3.new((column - 1.5) * 150, 0, 220 + row * 145)

    local ground = part(model, "Ground", Vector3.new(56, 1, 56), center, GRASS, Enum.Material.Grass)
    model.PrimaryPart = ground

    -- Entrada de terra e caminho até os canteiros.
    part(model, "FarmPath", Vector3.new(7, 0.12, 25), center + Vector3.new(0, 0.56, 15), Color3.fromRGB(177, 143, 99), Enum.Material.Ground)
    part(model, "FrontStep", Vector3.new(10, 0.25, 4), center + Vector3.new(0, 0.68, 27), Color3.fromRGB(145, 112, 76), Enum.Material.WoodPlanks)

    createFence(model, center)

    -- Placa com nome do proprietário, atualizada ao atribuir a fazenda.
    local signPost = part(model, "OwnerSignPost", Vector3.new(0.5, 4, 0.5), center + Vector3.new(0, 2, -24), WOOD, Enum.Material.Wood)
    local sign = part(model, "OwnerSign", Vector3.new(9, 3.2, 0.5), center + Vector3.new(0, 4.3, -24), CREAM, Enum.Material.WoodPlanks)
    sign.CanCollide = false
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SignText"
    billboard.Size = UDim2.fromOffset(150, 34)
    billboard.StudsOffset = Vector3.new(0, 0, -0.4)
    billboard.AlwaysOnTop = false
    billboard.MaxDistance = 85
    billboard.Parent = sign
    local visitPrompt = Instance.new("ProximityPrompt")
    visitPrompt.Name = "VisitFarmPrompt"
    visitPrompt.ActionText = "Visitar fazenda"
    visitPrompt.ObjectText = "Propriedade"
    visitPrompt.HoldDuration = 0.5
    visitPrompt.MaxActivationDistance = 12
    visitPrompt.Parent = sign

    local label = Instance.new("TextLabel")
    label.Name = "OwnerName"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "Fazenda livre"
    label.TextColor3 = Color3.fromRGB(75, 55, 35)
    label.TextStrokeTransparency = 0.65
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    -- Árvores e canteiros de flores nos cantos.
    makeTree(model, center + Vector3.new(-21, 0.5, -18), 0.85)
    makeTree(model, center + Vector3.new(21, 0.5, -18), 0.75)
    makeTree(model, center + Vector3.new(-22, 0.5, 20), 0.65)
    for i = 1, 5 do
        makeFlower(model, center + Vector3.new(-20 + i * 2, 0.55, 25), if i % 2 == 0 then Color3.fromRGB(255, 205, 90) else Color3.fromRGB(245, 130, 160))
        makeFlower(model, center + Vector3.new(10 + i * 2, 0.55, -24), Color3.fromRGB(255, 220, 110))
    end

    model:SetAttribute("OwnerUserId", 0)
    model:SetAttribute("OwnerName", "Disponível")
    model:SetAttribute("AccessMode", "Friends")
    model.Parent = plotsFolder
    return model
end

local function updateSign(plot: Model, text: string)
    local sign = plot:FindFirstChild("OwnerSign")
    local billboard = sign and sign:FindFirstChild("SignText")
    local label = billboard and billboard:FindFirstChild("OwnerName")
    if label and label:IsA("TextLabel") then
        label.Text = text
    end
end

function FarmService.Init()
    plotsFolder = workspace:FindFirstChild("PlayerFarms") :: Folder?
    if not plotsFolder then
        plotsFolder = Instance.new("Folder")
        plotsFolder.Name = "PlayerFarms"
        plotsFolder.Parent = workspace
    end

    for index = 1, 12 do
        if not plotsFolder:FindFirstChild("FarmPlot_" .. index) then
            createPlot(index)
        end
    end
end

function FarmService.Assign(player: Player): Model?
    for _, plot in plotsFolder:GetChildren() do
        if plot:GetAttribute("OwnerUserId") == 0 then
            plot:SetAttribute("OwnerUserId", player.UserId)
            plot:SetAttribute("OwnerName", player.DisplayName)
            plot:SetAttribute("AccessMode", "Friends")
            plot.Name = "Farm_" .. player.UserId
            playerPlots[player] = plot
            updateSign(plot, player.DisplayName .. "'s FARM")
            if player.Character then
                player.Character:PivotTo(plot:GetPivot() + Vector3.new(0, 4, 19))
            end
            player.CharacterAdded:Connect(function(character)
                character:PivotTo(plot:GetPivot() + Vector3.new(0, 4, 19))
            end)
            return plot
        end
    end
    warn("No free farm plot for " .. player.Name)
    return nil
end

function FarmService.GetPlayerPlot(player: Player): Model?
    return playerPlots[player]
end

function FarmService.GetPlotByUserId(userId: number): Model?
    for _, plot in plotsFolder:GetChildren() do
        if plot:GetAttribute("OwnerUserId") == userId then return plot end
    end
    return nil
end

function FarmService.Release(player: Player)
    local plot = playerPlots[player]
    if plot then
        plot:SetAttribute("OwnerUserId", 0)
        plot:SetAttribute("OwnerName", "Disponível")
        plot:SetAttribute("AccessMode", "Friends")
        plot.Name = "FarmPlot_Available"
        updateSign(plot, "FAZENDA DISPONÍVEL")
        for _, child in plot:GetChildren() do
            if child.Name == "PlantSlots" then child:Destroy() end
        end
        playerPlots[player] = nil
    end
end

return FarmService
