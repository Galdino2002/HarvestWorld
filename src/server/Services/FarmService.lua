--!strict
local FarmService = {}
local plotsFolder: Folder
local playerPlots: {[Player]: Model} = {}

local GRASS = Color3.fromRGB(112, 174, 91)
local WOOD = Color3.fromRGB(112, 72, 43)
local CREAM = Color3.fromRGB(255, 239, 198)

local function part(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
 local item = Instance.new("Part")
 item.Name = name; item.Size = size; item.Position = position; item.Anchored = true
 item.TopSurface = Enum.SurfaceType.Smooth; item.BottomSurface = Enum.SurfaceType.Smooth
 item.Color = color; item.Material = material; item.Parent = parent
 return item
end

local function makeTree(parent: Instance, origin: Vector3, scale: number)
 local trunk = part(parent, "TreeTrunk", Vector3.new(5, 1.4, 1.4) * scale, origin + Vector3.new(0, 2.5, 0), WOOD, Enum.Material.Wood)
 trunk.Shape = Enum.PartType.Cylinder
 trunk.Orientation = Vector3.new(0, 0, 90)
 local leaves = part(parent, "TreeCanopy", Vector3.new(6, 6, 6) * scale, origin + Vector3.new(0, 6, 0), Color3.fromRGB(75, 145, 72), Enum.Material.Grass)
 leaves.Shape = Enum.PartType.Ball
end

local function makeFlower(parent: Instance, origin: Vector3, color: Color3)
 part(parent, "FlowerStem", Vector3.new(.18, 1.1, .18), origin + Vector3.new(0, .55, 0), Color3.fromRGB(64, 125, 59), Enum.Material.Grass)
 local bloom = part(parent, "FlowerBloom", Vector3.new(.8, .8, .8), origin + Vector3.new(0, 1.1, 0), color, Enum.Material.SmoothPlastic)
 bloom.Shape = Enum.PartType.Ball
end

local function fence(model: Model, center: Vector3, half: number)
 for _, z in {-half, half} do
  for x = -half, half, 14 do part(model, "FencePost", Vector3.new(1, 3, 1), center + Vector3.new(x, 1.5, z), WOOD, Enum.Material.Wood) end
  part(model, "FenceRail", Vector3.new(half * 2, .45, .45), center + Vector3.new(0, 2.1, z), Color3.fromRGB(155, 105, 66), Enum.Material.Wood)
 end
 for _, x in {-half, half} do
  for z = -half, half, 14 do part(model, "FencePost", Vector3.new(1, 3, 1), center + Vector3.new(x, 1.5, z), WOOD, Enum.Material.Wood) end
  part(model, "FenceRail", Vector3.new(.45, .45, half * 2), center + Vector3.new(x, 2.1, 0), Color3.fromRGB(155, 105, 66), Enum.Material.Wood)
 end
end

local function buildZone(model: Model, name: string, center: Vector3, offset: Vector3, size: Vector3, title: string)
 local pad = part(model, name, size, center + offset + Vector3.new(0, .65, 0), Color3.fromRGB(177, 151, 111), Enum.Material.Ground)
 pad:SetAttribute("BuildZone", title)
 local post = part(model, name .. "SignPost", Vector3.new(.6, 4, .6), pad.Position + Vector3.new(0, 2.3, -size.Z / 2 + 2), WOOD, Enum.Material.Wood)
 local gui = Instance.new("BillboardGui")
 gui.Size = UDim2.fromOffset(150, 34); gui.StudsOffset = Vector3.new(0, 2.5, 0); gui.MaxDistance = 100; gui.Parent = post
 local label = Instance.new("TextLabel")
 label.Size = UDim2.fromScale(1, 1); label.BackgroundTransparency = 1
 label.Text = title .. " • área de construção"; label.TextColor3 = Color3.fromRGB(255, 246, 218)
 label.TextStrokeTransparency = .35; label.TextScaled = true; label.Font = Enum.Font.GothamBold; label.Parent = gui
end

local function createPlot(index: number): Model
 local model = Instance.new("Model")
 model.Name = "FarmPlot_" .. index
 local column = (index - 1) % 4
 local row = math.floor((index - 1) / 4)
 local center = Vector3.new((column - 1.5) * 235, 0, 280 + row * 245)
 local ground = part(model, "Ground", Vector3.new(190, 1, 190), center, GRASS, Enum.Material.Grass)
 model.PrimaryPart = ground
 part(model, "FarmPath", Vector3.new(10, .15, 48), center + Vector3.new(0, .58, 65), Color3.fromRGB(177, 143, 99), Enum.Material.Ground)
 part(model, "FrontStep", Vector3.new(15, .3, 5), center + Vector3.new(0, .72, 91), Color3.fromRGB(145, 112, 76), Enum.Material.WoodPlanks)
 fence(model, center, 91)

 -- Reserved build pads: players will later place their own coop, barn and pasture here.
 buildZone(model, "ChickenCoopBuildPad", center, Vector3.new(-53, 0, -45), Vector3.new(48, .35, 42), "Galinheiro")
 buildZone(model, "BarnBuildPad", center, Vector3.new(53, 0, -45), Vector3.new(54, .35, 48), "Celeiro")
 buildZone(model, "PastureBuildPad", center, Vector3.new(0, 0, 42), Vector3.new(92, .35, 48), "Pasto")
 -- Nine starter crop beds remain close to the farm entrance.
 for i = 1, 9 do
  local rowSlot = math.floor((i - 1) / 3)
  local col = (i - 1) % 3
  local bed = part(model, "GardenBed_" .. i, Vector3.new(10, .35, 10), center + Vector3.new((col - 1) * 13, .72, 79 - rowSlot * 14), Color3.fromRGB(112, 75, 48), Enum.Material.Ground)
  bed:SetAttribute("PlantSlot", i)
 end

 local sign = part(model, "OwnerSign", Vector3.new(12, 4, .7), center + Vector3.new(0, 5, -84), CREAM, Enum.Material.WoodPlanks)
 sign.CanCollide = false
 local gui = Instance.new("BillboardGui")
 gui.Name = "SignText"; gui.Size = UDim2.fromOffset(170, 40); gui.StudsOffset = Vector3.new(0, 2.5, 0)
 gui.MaxDistance = 110; gui.Parent = sign
 local label = Instance.new("TextLabel")
 label.Name = "OwnerName"; label.Size = UDim2.fromScale(1, 1); label.BackgroundTransparency = 1
 label.Text = "Fazenda livre"; label.TextColor3 = Color3.fromRGB(75, 55, 35)
 label.TextStrokeTransparency = .55; label.TextScaled = true; label.Font = Enum.Font.GothamBold; label.Parent = gui
 model:SetAttribute("OwnerUserId", 0)
 model:SetAttribute("OwnerName", "Disponível")
 model:SetAttribute("AccessMode", "Friends")
 model.Parent = plotsFolder
 return model
end

local function updateSign(plot: Model, text: string)
 local sign = plot:FindFirstChild("OwnerSign")
 local gui = sign and sign:FindFirstChild("SignText")
 local label = gui and gui:FindFirstChild("OwnerName")
 if label and label:IsA("TextLabel") then label.Text = text end
end

function FarmService.Init()
 plotsFolder = Instance.new("Folder")
 plotsFolder.Name = "PlayerFarms"
 plotsFolder.Parent = workspace
 for index = 1, 12 do createPlot(index) end
end

function FarmService.Assign(player: Player): Model?
 for _, plot in plotsFolder:GetChildren() do
  if plot:GetAttribute("OwnerUserId") == 0 then
   plot:SetAttribute("OwnerUserId", player.UserId)
   plot:SetAttribute("OwnerName", player.DisplayName)
   plot:SetAttribute("AccessMode", "Friends")
   plot.Name = "Farm_" .. player.UserId
   playerPlots[player] = plot
   updateSign(plot, player.DisplayName .. "'s FARM")
   local function moveToFarm(character: Model)
    character:PivotTo(plot:GetPivot() + Vector3.new(0, 5, 70))
   end
   if player.Character then moveToFarm(player.Character) end
   player.CharacterAdded:Connect(moveToFarm)
   return plot
  end
 end
 warn("No free farm plot for " .. player.Name)
 return nil
end

function FarmService.GetPlayerPlot(player: Player): Model?
 return playerPlots[player]
end

function FarmService.GetPlotByUserId(userId: number): Model?
 for _, plot in plotsFolder:GetChildren() do
  if plot:GetAttribute("OwnerUserId") == userId then return plot end
 end
 return nil
end

function FarmService.Release(player: Player)
 local plot = playerPlots[player]
 if plot then
  plot:SetAttribute("OwnerUserId", 0)
  plot:SetAttribute("OwnerName", "Disponível")
  plot:SetAttribute("AccessMode", "Friends")
  plot.Name = "FarmPlot_Available_" .. tostring(math.random(1000, 9999))
  updateSign(plot, "Fazenda livre")
  for _, child in plot:GetChildren() do
   if child.Name == "PlantSlots" then child:Destroy() end
  end
  playerPlots[player] = nil
 end
end

return FarmService
