--!strict
-- Greenfields is the first authored exploration region.
-- Discoveries are session-scoped for now; persistence will be added with player data.
local GreenfieldsExploreService = {}

local DISCOVERIES = {
    {
        id = "ElderTree",
        title = "A Árvore Ancestral",
        position = Vector3.new(-650, 0, 178),
        description = "Uma árvore antiga que observa o vale há gerações.",
        reward = 25,
    },
    {
        id = "OldWatermill",
        title = "O Velho Moinho",
        position = Vector3.new(558, 0, 282),
        description = "O som da água revela um antigo moinho escondido no caminho.",
        reward = 35,
    },
    {
        id = "WhisperCabin",
        title = "Cabana dos Sussurros",
        position = Vector3.new(-1122, 0, -731),
        description = "Uma cabana esquecida entre as árvores da floresta.",
        reward = 40,
    },
    {
        id = "OldRuins",
        title = "Ruínas do Vale",
        position = Vector3.new(820, 0, 600),
        description = "Pedras antigas guardam histórias que ninguém mais conta.",
        reward = 50,
    },
}

local function makeSign(parent: Instance, item)
    local model = Instance.new("Model")
    model.Name = item.id .. "Discovery"
    model:SetAttribute("DiscoveryId", item.id)
    model.Parent = parent

    local post = Instance.new("Part")
    post.Name = "SignPost"
    post.Size = Vector3.new(0.8, 5, 0.8)
    post.Position = item.position + Vector3.new(0, 1.5, 0)
    post.Anchored = true
    post.Material = Enum.Material.Wood
    post.Color = Color3.fromRGB(112, 75, 48)
    post.Parent = model

    local board = Instance.new("Part")
    board.Name = "SignBoard"
    board.Size = Vector3.new(8, 3.2, 0.55)
    board.Position = item.position + Vector3.new(0, 4.5, 0)
    board.Anchored = true
    board.Material = Enum.Material.WoodPlanks
    board.Color = Color3.fromRGB(151, 111, 70)
    board.Parent = model

    local gui = Instance.new("SurfaceGui")
    gui.Name = "SignText"
    gui.Face = Enum.NormalId.Front
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 35
    gui.Parent = board

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = item.title
    label.TextColor3 = Color3.fromRGB(255, 242, 210)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "DiscoverPrompt"
    prompt.ActionText = "Explorar"
    prompt.ObjectText = item.title
    prompt.HoldDuration = 0.6
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = post

    prompt.Triggered:Connect(function(player: Player)
        local key = "Discovered_" .. item.id
        if player:GetAttribute(key) == true then
            return
        end
        player:SetAttribute(key, true)

        local stats = player:FindFirstChild("leaderstats")
        local coins = stats and stats:FindFirstChild("Coins")
        local discoveries = stats and stats:FindFirstChild("Discoveries")
        if coins and coins:IsA("IntValue") then
            coins.Value += item.reward
        end
        if discoveries and discoveries:IsA("IntValue") then
            discoveries.Value += 1
        end

        local message = Instance.new("Hint")
        message.Text = "Local descoberto: " .. item.title .. "  |  +" .. tostring(item.reward) .. " moedas"
        message.Parent = workspace
        task.delay(3, function()
            if message.Parent then
                message:Destroy()
            end
        end)
    end)
end

function GreenfieldsExploreService.Init()
    local old = workspace:FindFirstChild("GreenfieldsDiscoveries")
    if old then
        old:Destroy()
    end

    local folder = Instance.new("Folder")
    folder.Name = "GreenfieldsDiscoveries"
    folder.Parent = workspace

    for _, item in DISCOVERIES do
        makeSign(folder, item)
    end

    print("[HarvestWorld] Greenfields exploration points initialized.")
end

return GreenfieldsExploreService
