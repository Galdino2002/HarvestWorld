--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local plantRequest = remotes:WaitForChild("PlantRequest") :: RemoteEvent
local harvestRequest = remotes:WaitForChild("HarvestRequest") :: RemoteEvent
local farmAccessRequest = remotes:WaitForChild("FarmAccessRequest") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "HarvestWorldHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "FarmPanel"
panel.Size = UDim2.fromOffset(286, 438)
panel.Position = UDim2.new(0, 18, 0.5, -219)
panel.BackgroundColor3 = Color3.fromRGB(35, 57, 42)
panel.BackgroundTransparency = 0.04
panel.Parent = gui

local panelScale = Instance.new("UIScale")
panelScale.Parent = panel
local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    panelScale.Scale = math.clamp(math.min(viewport.X / 1050, viewport.Y / 720), 0.72, 1)
end
updateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 18)
panelCorner.Parent = panel
local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(190, 225, 151)
panelStroke.Thickness = 2
panelStroke.Transparency = 0.12
panelStroke.Parent = panel

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 82)
header.BackgroundColor3 = Color3.fromRGB(76, 133, 73)
header.Parent = panel
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 18)
headerCorner.Parent = header
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 18)
headerFix.Position = UDim2.new(0, 0, 1, -18)
headerFix.BackgroundColor3 = header.BackgroundColor3
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 34)
title.Position = UDim2.fromOffset(12, 10)
title.BackgroundTransparency = 1
title.Text = "HARVEST WORLD"
title.TextColor3 = Color3.fromRGB(255, 249, 220)
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -24, 0, 22)
subtitle.Position = UDim2.fromOffset(13, 45)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Sua fazenda começa aqui"
subtitle.TextColor3 = Color3.fromRGB(224, 244, 205)
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 13
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size = UDim2.new(1, -24, 0, 30)
coinsLabel.Position = UDim2.fromOffset(12, 88)
coinsLabel.BackgroundColor3 = Color3.fromRGB(245, 207, 91)
coinsLabel.TextColor3 = Color3.fromRGB(75, 55, 24)
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.TextSize = 15
coinsLabel.Text = "  ◉  100 moedas"
coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
coinsLabel.Parent = panel
local coinsCorner = Instance.new("UICorner")
coinsCorner.CornerRadius = UDim.new(0, 9)
coinsCorner.Parent = coinsLabel

local selectedSlot = 1
local slotLabel = Instance.new("TextLabel")
slotLabel.Size = UDim2.new(1, -24, 0, 24)
slotLabel.Position = UDim2.fromOffset(12, 151)
slotLabel.BackgroundTransparency = 1
slotLabel.Text = "CANTEIRO SELECIONADO: 1"
slotLabel.TextColor3 = Color3.fromRGB(235, 240, 224)
slotLabel.Font = Enum.Font.GothamBold
slotLabel.TextSize = 12
slotLabel.TextXAlignment = Enum.TextXAlignment.Left
slotLabel.Parent = panel

local function makeButton(text: string, y: number, color: Color3, callback: () -> ())
    local button = Instance.new("TextButton")
    if text == "Visitas: amigos" then button.Name = "FarmAccessButton" end
    button.Size = UDim2.new(1, -24, 0, 39)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.fromRGB(45, 54, 37)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.AutoButtonColor = true
    button.Parent = panel
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.72
    stroke.Parent = button
    button.Activated:Connect(callback)
end

makeButton("Trocar canteiro  (1–9)", 178, Color3.fromRGB(220, 231, 195), function()
    selectedSlot = selectedSlot % 9 + 1
    slotLabel.Text = "CANTEIRO SELECIONADO: " .. selectedSlot
end)
makeButton("🥕  Plantar cenoura", 222, Color3.fromRGB(255, 190, 105), function()
    plantRequest:FireServer("Carrot", selectedSlot)
end)
makeButton("🍅  Plantar tomate", 266, Color3.fromRGB(244, 137, 119), function()
    plantRequest:FireServer("Tomato", selectedSlot)
end)
makeButton("🫐  Plantar mirtilo", 310, Color3.fromRGB(171, 159, 224), function()\n    plantRequest:FireServer("Blueberry", selectedSlot)\nend)\nmakeButton("Colher canteiro", 354, Color3.fromRGB(157, 211, 130), function()
    harvestRequest:FireServer(selectedSlot)
end)

local accessModes = {"Friends", "Public", "Private"}
local accessLabels = {Friends = "Visitas: amigos", Public = "Visitas: públicas", Private = "Visitas: privadas"}
local accessIndex = 1
makeButton("Visitas: amigos", 398, Color3.fromRGB(180, 205, 232), function()
    accessIndex = accessIndex % #accessModes + 1
    local mode = accessModes[accessIndex]
    farmAccessRequest:FireServer(mode)
    local button = panel:FindFirstChild("FarmAccessButton")
    if button and button:IsA("TextButton") then button.Text = accessLabels[mode] end
end)

local resourcesLabel = Instance.new("TextLabel")
resourcesLabel.Size = UDim2.new(1, -24, 0, 22)
resourcesLabel.Position = UDim2.fromOffset(12, 122)
resourcesLabel.BackgroundTransparency = 1
resourcesLabel.TextColor3 = Color3.fromRGB(224, 235, 211)
resourcesLabel.Font = Enum.Font.GothamBold
resourcesLabel.TextSize = 12
resourcesLabel.TextXAlignment = Enum.TextXAlignment.Left
resourcesLabel.Parent = panel

local stats = player:WaitForChild("leaderstats", 15)
local function refreshStats()
    if not stats then return end
    local coins = stats:FindFirstChild("Coins")
    local wood = stats:FindFirstChild("Wood")
    local stone = stats:FindFirstChild("Stone")
    if coins and coins:IsA("IntValue") then coinsLabel.Text = "  ◉  " .. coins.Value .. " moedas" end
    local woodValue = wood and wood:IsA("IntValue") and wood.Value or 0
    local stoneValue = stone and stone:IsA("IntValue") and stone.Value or 0
    resourcesLabel.Text = "🪵 Madeira: " .. woodValue .. "       🪨 Pedra: " .. stoneValue
end
if stats then
    for _, value in stats:GetChildren() do
        if value:IsA("IntValue") then
            value:GetPropertyChangedSignal("Value"):Connect(refreshStats)
        end
    end
    stats.ChildAdded:Connect(function(value)
        if value:IsA("IntValue") then value:GetPropertyChangedSignal("Value"):Connect(refreshStats) end
        refreshStats()
    end)
end
refreshStats()

print("[HarvestWorld] Interface visual carregada.")
