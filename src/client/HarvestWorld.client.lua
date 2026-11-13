--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local plantRequest = remotes:WaitForChild("PlantRequest") :: RemoteEvent
local harvestRequest = remotes:WaitForChild("HarvestRequest") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "HarvestWorldHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "FarmPanel"
panel.Size = UDim2.fromOffset(286, 348)
panel.Position = UDim2.new(0, 22, 0.5, -174)
panel.BackgroundColor3 = Color3.fromRGB(35, 57, 42)
panel.BackgroundTransparency = 0.04
panel.Parent = gui

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
coinsLabel.Position = UDim2.fromOffset(12, 91)
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
slotLabel.Position = UDim2.fromOffset(12, 130)
slotLabel.BackgroundTransparency = 1
slotLabel.Text = "CANTEIRO SELECIONADO: 1"
slotLabel.TextColor3 = Color3.fromRGB(235, 240, 224)
slotLabel.Font = Enum.Font.GothamBold
slotLabel.TextSize = 12
slotLabel.TextXAlignment = Enum.TextXAlignment.Left
slotLabel.Parent = panel

local function makeButton(text: string, y: number, color: Color3, callback: () -> ())
    local button = Instance.new("TextButton")
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

makeButton("Trocar canteiro  (1–9)", 160, Color3.fromRGB(220, 231, 195), function()
    selectedSlot = selectedSlot % 9 + 1
    slotLabel.Text = "CANTEIRO SELECIONADO: " .. selectedSlot
end)
makeButton("🥕  Plantar cenoura", 205, Color3.fromRGB(255, 190, 105), function()
    plantRequest:FireServer("Carrot", selectedSlot)
end)
makeButton("🍅  Plantar tomate", 250, Color3.fromRGB(244, 137, 119), function()
    plantRequest:FireServer("Tomato", selectedSlot)
end)
makeButton("Colher canteiro", 295, Color3.fromRGB(157, 211, 130), function()
    harvestRequest:FireServer(selectedSlot)
end)

local stats = player:WaitForChild("leaderstats", 15)
local coins = stats and stats:WaitForChild("Coins", 15)
if coins and coins:IsA("IntValue") then
    coinsLabel.Text = "  ◉  " .. coins.Value .. " moedas"
    coins:GetPropertyChangedSignal("Value"):Connect(function()
        coinsLabel.Text = "  ◉  " .. coins.Value .. " moedas"
    end)
end

print("[HarvestWorld] Interface visual carregada.")
