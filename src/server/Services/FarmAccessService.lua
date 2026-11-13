--!strict
local Players = game:GetService("Players")
local FarmService = require(script.Parent.FarmService)

local FarmAccessService = {}
local connectedPrompts: {[ProximityPrompt]: boolean} = {}
local lastVisit: {[Player]: number} = {}

local VALID_MODES = { Private = true, Friends = true, Public = true }

local function isFriend(visitor: Player, ownerUserId: number): boolean
    local ok, result = pcall(function()
        return visitor:IsFriendsWith(ownerUserId)
    end)
    return ok and result == true
end

local function canVisit(visitor: Player, plot: Model): boolean
    local ownerId = plot:GetAttribute("OwnerUserId")
    if typeof(ownerId) ~= "number" or ownerId == 0 then return false end
    if ownerId == visitor.UserId then return true end
    local mode = plot:GetAttribute("AccessMode")
    if mode == "Public" then return true end
    if mode == "Friends" then return isFriend(visitor, ownerId) end
    return false
end

function FarmAccessService.Init(remotes: Folder)
    local accessRequest = remotes:WaitForChild("FarmAccessRequest") :: RemoteEvent
    accessRequest.OnServerEvent:Connect(function(player, requestedMode)
        if typeof(requestedMode) ~= "string" or not VALID_MODES[requestedMode] then return end
        local plot = FarmService.GetPlayerPlot(player)
        if not plot or plot:GetAttribute("OwnerUserId") ~= player.UserId then return end
        plot:SetAttribute("AccessMode", requestedMode)
    end)

    local function connectPrompt(instance: Instance)
        if not instance:IsA("ProximityPrompt") or instance.Name ~= "VisitFarmPrompt" then return end
        if connectedPrompts[instance] then return end
        connectedPrompts[instance] = true
        instance.Triggered:Connect(function(visitor)
            local plot = instance:FindFirstAncestorWhichIsA("Model")
            if not plot or not canVisit(visitor, plot) then return end
            local now = os.clock()
            if now - (lastVisit[visitor] or 0) < 3 then return end
            lastVisit[visitor] = now
            local character = visitor.Character
            if character then character:PivotTo(plot:GetPivot() + Vector3.new(0, 4, 19)) end
        end)
    end

    for _, descendant in workspace:GetDescendants() do connectPrompt(descendant) end
    workspace.DescendantAdded:Connect(connectPrompt)
    Players.PlayerRemoving:Connect(function(player) lastVisit[player] = nil end)
end

return FarmAccessService
