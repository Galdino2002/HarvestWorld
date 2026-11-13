--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WorldService = require(script.Parent.Services.WorldService)
local FarmService = require(script.Parent.Services.FarmService)
local PlantService = require(script.Parent.Services.PlantService)
local FarmAccessService = require(script.Parent.Services.FarmAccessService)
local FarmBuildingService = require(script.Parent.Services.FarmBuildingService)
local WorldLifeService = require(script.Parent.Services.WorldLifeService)

local remotes = ReplicatedStorage:FindFirstChild("Remotes") :: Folder?
if not remotes then
    remotes = Instance.new("Folder")
    remotes.Name = "Remotes"
    remotes.Parent = ReplicatedStorage
end

local function ensureRemote(name: string): RemoteEvent
    local remote = remotes:FindFirstChild(name) :: RemoteEvent?
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = remotes
    end
    return remote
end

ensureRemote("PlantRequest")
ensureRemote("HarvestRequest")
ensureRemote("FarmAccessRequest")

WorldService.Init()
FarmService.Init()
WorldLifeService.Init()
FarmBuildingService.Init()
PlantService.Init(remotes)
FarmAccessService.Init(remotes)

local function setupPlayer(player: Player)
    if player:FindFirstChild("leaderstats") then return end
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 100
    coins.Parent = stats

    local wood = Instance.new("IntValue")
    wood.Name = "Wood"
    wood.Value = 0
    wood.Parent = stats

    local stone = Instance.new("IntValue")
    stone.Name = "Stone"
    stone.Value = 0
    stone.Parent = stats

    FarmService.Assign(player)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    FarmService.Release(player)
end)

for _, player in Players:GetPlayers() do
    task.spawn(setupPlayer, player)
end

print("[HarvestWorld] Server foundation initialized.")
