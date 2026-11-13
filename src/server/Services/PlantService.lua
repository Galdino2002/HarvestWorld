--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Crops = require(ReplicatedStorage.Shared.Config.Crops)
local FarmService = require(script.Parent.FarmService)

local PlantService = {}
local plantRequest: RemoteEvent
local harvestRequest: RemoteEvent
local inventory: {[Player]: {[string]: number}} = {}
local lastAction: {[Player]: number} = {}

local function getInventory(player: Player): {[string]: number}
    inventory[player] = inventory[player] or { Carrot = 5, Tomato = 2, Blueberry = 2 }
    return inventory[player]
end

local function getPlantSlot(plot: Model, slot: number): BasePart?
    if slot < 1 or slot > 9 or slot % 1 ~= 0 then return nil end
    -- Use the visible garden beds created by FarmService; never create invisible planting slots.
    local bed = plot:FindFirstChild("GardenBed_" .. tostring(slot))
    if bed and bed:IsA("BasePart") then return bed end
    return nil
end

local function makeCropVisual(slotPart: BasePart, cropId: string, growSeconds: number): Model
    local model = Instance.new("Model")
    model.Name = "Crop"
    model:SetAttribute("CropId", cropId)
    model:SetAttribute("PlantedAt", os.time())
    model:SetAttribute("MaturesAt", os.time() + growSeconds)
    model:SetAttribute("Mature", false)

    local stem = Instance.new("Part")
    stem.Name = "Stem"
    stem.Shape = Enum.PartType.Cylinder
    stem.Size = Vector3.new(0.35, 0.8, 0.35)
    stem.Orientation = Vector3.new(0, 0, 90)
    stem.Position = slotPart.Position + Vector3.new(0, 0.85, 0)
    stem.Anchored = true
    stem.CanCollide = false
    stem.Color = Color3.fromRGB(75, 132, 66)
    stem.Material = Enum.Material.Grass
    stem.Parent = model

    local leaves = {}
    for _, side in {-1, 1} do
        local leaf = Instance.new("Part")
        leaf.Name = "Leaf"
        leaf.Shape = Enum.PartType.Ball
        leaf.Size = Vector3.new(0.35, 0.18, 0.5)
        leaf.Position = slotPart.Position + Vector3.new(side * 0.22, 1.05, 0)
        leaf.Anchored = true
        leaf.CanCollide = false
        leaf.Color = Color3.fromRGB(82, 151, 70)
        leaf.Material = Enum.Material.Grass
        leaf.Parent = model
        table.insert(leaves, leaf)
    end

    local produce = Instance.new("Part")
    produce.Name = "Produce"
    produce.Shape = Enum.PartType.Ball
    produce.Size = Vector3.new(0.25, 0.25, 0.25)
    produce.Position = slotPart.Position + Vector3.new(0, 1.25, 0)
    produce.Anchored = true
    produce.CanCollide = false
    produce.Color = Crops[cropId].Color
    produce.Material = Enum.Material.SmoothPlastic
    produce.Parent = model

    if cropId == "Carrot" then
        produce.Shape = Enum.PartType.Block
        produce.Size = Vector3.new(0.35, 0.5, 0.35)
        produce.Orientation = Vector3.new(0, 0, 12)
    elseif cropId == "Blueberry" then
        produce.Size = Vector3.new(0.2, 0.2, 0.2)
    end

    model.PrimaryPart = stem
    model.Parent = slotPart

    task.delay(growSeconds * 0.45, function()
        if not model.Parent then return end
        stem.Size = Vector3.new(0.45, 1.35, 0.45)
        stem.Position = slotPart.Position + Vector3.new(0, 1.15, 0)
        for index, leaf in leaves do
            leaf.Size = Vector3.new(0.8, 0.25, 1.0)
            leaf.Position = slotPart.Position + Vector3.new(index == 1 and -0.55 or 0.55, 1.35, 0)
        end
        produce.Size = cropId == "Blueberry" and Vector3.new(0.35, 0.35, 0.35) or Vector3.new(0.65, 0.65, 0.65)
        produce.Position = slotPart.Position + Vector3.new(0, 1.8, 0)
    end)

    task.delay(growSeconds, function()
        if not model.Parent then return end
        model:SetAttribute("Mature", true)
        stem.Size = Vector3.new(0.55, 2.0, 0.55)
        stem.Position = slotPart.Position + Vector3.new(0, 1.45, 0)
        for index, leaf in leaves do
            leaf.Size = Vector3.new(1.1, 0.3, 1.2)
            leaf.Position = slotPart.Position + Vector3.new(index == 1 and -0.8 or 0.8, 1.65, 0)
        end
        if cropId == "Blueberry" then
            produce.Size = Vector3.new(0.42, 0.42, 0.42)
            produce.Position = slotPart.Position + Vector3.new(0, 2.1, 0)
        else
            produce.Size = Vector3.new(0.9, 0.9, 0.9)
            produce.Position = slotPart.Position + Vector3.new(0, 2.0, 0)
        end
    end)

    return model
end

function PlantService.Init(remotes: Folder)
    game:GetService("Players").PlayerRemoving:Connect(function(player)
        inventory[player] = nil
        lastAction[player] = nil
    end)
    plantRequest = remotes:FindFirstChild("PlantRequest") :: RemoteEvent?
    harvestRequest = remotes:FindFirstChild("HarvestRequest") :: RemoteEvent?

    plantRequest.OnServerEvent:Connect(function(player, cropId, slotIndex)
        local now = os.clock()
        if now - (lastAction[player] or 0) < 0.25 then return end
        lastAction[player] = now
        if typeof(cropId) ~= "string" or typeof(slotIndex) ~= "number" then return end
        local definition = Crops[cropId]
        if not definition or slotIndex % 1 ~= 0 then return end
        local plot = FarmService.GetPlayerPlot(player)
        if not plot or plot:GetAttribute("OwnerUserId") ~= player.UserId then return end
        local slot = getPlantSlot(plot, slotIndex)
        if not slot or slot:FindFirstChild("Crop") then return end
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart or (rootPart.Position - slot.Position).Magnitude > 28 then return end
        local playerInventory = getInventory(player)
        if (playerInventory[cropId] or 0) < 1 then return end

        playerInventory[cropId] -= 1
        makeCropVisual(slot, cropId, definition.GrowSeconds)
    end)

    harvestRequest.OnServerEvent:Connect(function(player, slotIndex)
        local now = os.clock()
        if now - (lastAction[player] or 0) < 0.25 then return end
        lastAction[player] = now
        if typeof(slotIndex) ~= "number" or slotIndex % 1 ~= 0 then return end
        local plot = FarmService.GetPlayerPlot(player)
        if not plot or plot:GetAttribute("OwnerUserId") ~= player.UserId then return end
        local slot = getPlantSlot(plot, slotIndex)
        local crop = slot and slot:FindFirstChild("Crop")
        if not slot or not crop then return end
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart or (rootPart.Position - slot.Position).Magnitude > 28 then return end
        local cropId = crop:GetAttribute("CropId")
        local definition = typeof(cropId) == "string" and Crops[cropId]
        if not definition then return end
        if os.time() < (crop:GetAttribute("MaturesAt") or math.huge) then return end

        local stats = player:FindFirstChild("leaderstats")
        local coins = stats and stats:FindFirstChild("Coins")
        if coins and coins:IsA("IntValue") then
            coins.Value += definition.SellValue
        end
        crop:Destroy()
    end)
end

return PlantService
