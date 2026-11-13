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
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "FarmPanel"
panel.Size = UDim2.fromOffset(230, 250)
panel.Position = UDim2.new(0, 16, 0.5, -125)
panel.BackgroundColor3 = Color3.fromRGB(35, 75, 48)
panel.BackgroundTransparency = 0.08
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local function makeButton(text: string, y: number, callback: () -> ())
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 42)
    button.Position = UDim2.fromOffset(10, y)
    button.BackgroundColor3 = Color3.fromRGB(235, 220, 170)
    button.TextColor3 = Color3.fromRGB(45, 55, 35)
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.AutoButtonColor = true
    button.Parent = panel
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    button.Activated:Connect(callback)
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.fromOffset(10, 6)
title.BackgroundTransparency = 1
title.Text = "HARVEST WORLD"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.Parent = panel

local selectedSlot = 1
local slotLabel = Instance.new("TextLabel")
slotLabel.Size = UDim2.new(1, -20, 0, 24)
slotLabel.Position = UDim2.fromOffset(10, 40)
slotLabel.BackgroundTransparency = 1
slotLabel.Text = "Canteiro selecionado: 1"
slotLabel.TextColor3 = Color3.new(1, 1, 1)
slotLabel.Font = Enum.Font.Gotham
slotLabel.TextSize = 13
slotLabel.Parent = panel

makeButton("Alternar canteiro (1–9)", 66, function()
    selectedSlot = selectedSlot % 9 + 1
    slotLabel.Text = "Canteiro selecionado: " .. selectedSlot
end)
makeButton("Plantar cenoura", 114, function()
    plantRequest:FireServer("Carrot", selectedSlot)
end)
makeButton("Plantar tomate", 162, function()
    plantRequest:FireServer("Tomato", selectedSlot)
end)
makeButton("Colher canteiro", 210, function()
    harvestRequest:FireServer(selectedSlot)
end)
