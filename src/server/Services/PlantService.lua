--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Crops = require(ReplicatedStorage.Shared.Config.Crops)
local FarmService = require(script.Parent.FarmService)

local PlantService = {}
local plantsFolder: Folder
local plantRequest: RemoteEvent
local harvestRequest: RemoteEvent
local inventory: {[Player]: {[string]: number}} = {}

local function getInventory(player: Player): {[string]: number}
    inventory[player] = inventory[player] or { Carrot = 5, Tomato = 2, Blueberry = 0 }
    return inventory[player]
end

local function getPlantSlot(plot: Model, slot: number): BasePart?
    if slot < 1 or slot > 9 then return nil end
    local slots = plot:FindFirstChild("PlantSlots")
    if not slots then
        slots = Instance.new("Folder")
        slots.Name = "PlantSlots"
        slots.Parent = plot
        local ground = plot.PrimaryPart
        if not ground then return nil end
        for i = 1, 9 do
            local part = Instance.new("Part")
            part.Name = "Slot_" .. i
            part.Size = Vector3.new(8, 0.25, 8)
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Ground
            part.Color = Color3.fromRGB(110, 75, 45)
            local row = math.floor((i - 1) / 3)
            local col = (i - 1) % 3
            part.Position = ground.Position + Vector3.new((col - 1) * 10, 0.65, (row - 1) * 10)
            part.Parent = slots
        end
    end
    return slots:FindFirstChild("Slot_" .. slot) :: BasePart?
end

local function makeCropVisual(slotPart: BasePart, cropId: string, growSeconds: number): Model
    local model = Instance.new("Model")
    model.Name = "Crop"
    model:SetAttribute("CropId", cropId)
    model:SetAttribute("PlantedAt", os.time())
    model:SetAttribute("MaturesAt", os.time() + growSeconds)

    local stem = Instance.new("Part")
    stem.Name = "Visual"
    stem.Shape = Enum.PartType.Ball
    stem.Size = Vector3.new(1.5, 1.5, 1.5)
    stem.Position = slotPart.Position + Vector3.new(0, 1.1, 0)
    stem.Anchored = true
    stem.CanCollide = false
    stem.Color = Crops[cropId].Color
    stem.Parent = model
    model.PrimaryPart = stem
    model.Parent = slotPart
    return model
end

function PlantService.Init(remotes: Folder)
    plantsFolder = workspace
    plantRequest = remotes:FindFirstChild("PlantRequest") as RemoteEvent
    harvestRequest = remotes:FindFirstChild("HarvestRequest") as RemoteEvent

    plantRequest.OnServerEvent:Connect(function(player, cropId, slotIndex)
        if typeof(cropId) ~= "string" or typeof(slotIndex) ~= "number" then return end
        local definition = Crops[cropId]
        if not definition or slotIndex % 1 ~= 0 then return end
        local plot = FarmService.GetPlayerPlot(player)
        if not plot or plot:GetAttribute("OwnerUserId") ~= player.UserId then return end
        local slot = getPlantSlot(plot, slotIndex)
        if not slot or slot:FindFirstChild("Crop") then return end
        local playerInventory = getInventory(player)
        if (playerInventory[cropId] or 0) < 1 then return end

        playerInventory[cropId] -= 1
        makeCropVisual(slot, cropId, definition.GrowSeconds)
    end)

    harvestRequest.OnServerEvent:Connect(function(player, slotIndex)
        if typeof(slotIndex) ~= "number" or slotIndex % 1 ~= 0 then return end
        local plot = FarmService.GetPlayerPlot(player)
        if not plot or plot:GetAttribute("OwnerUserId") ~= player.UserId then return end
        local slot = getPlantSlot(plot, slotIndex)
        local crop = slot and slot:FindFirstChild("Crop")
        if not crop then return end
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
