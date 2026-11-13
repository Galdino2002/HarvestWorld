--!strict
local Players = game:GetService("Players")

local FarmService = {}
local plotsFolder: Folder
local playerPlots: {[Player]: Model} = {}

local function createPlot(index: number): Model
    local model = Instance.new("Model")
    model.Name = "FarmPlot_" .. index

    local base = Instance.new("Part")
    base.Name = "Ground"
    base.Size = Vector3.new(42, 1, 42)
    base.Position = Vector3.new((index - 1) * 55, 0, 0)
    base.Anchored = true
    base.Material = Enum.Material.Grass
    base.Color = Color3.fromRGB(105, 175, 85)
    base.Parent = model

    local sign = Instance.new("Part")
    sign.Name = "OwnerSign"
    sign.Size = Vector3.new(5, 4, 0.5)
    sign.Position = base.Position + Vector3.new(0, 3, -18)
    sign.Anchored = true
    sign.Color = Color3.fromRGB(245, 225, 170)
    sign.Parent = model

    model.PrimaryPart = base
    model:SetAttribute("OwnerUserId", 0)
    model.Parent = plotsFolder
    return model
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
            plot.Name = "Farm_" .. player.UserId
            playerPlots[player] = plot
            return plot
        end
    end
    warn("No free farm plot for " .. player.Name)
    return nil
end

function FarmService.GetPlayerPlot(player: Player): Model?
    return playerPlots[player]
end

function FarmService.Release(player: Player)
    local plot = playerPlots[player]
    if plot then
        plot:SetAttribute("OwnerUserId", 0)
        plot.Name = "FarmPlot_Available"
        for _, child in plot:GetChildren() do
            if child.Name == "Crop" then child:Destroy() end
        end
        playerPlots[player] = nil
    end
end

return FarmService
