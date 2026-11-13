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
    inventory[player] = inventory[player] or { Carrot = 5, Tomato = 2, Blueberry = 0 }
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
