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
 local railColor = Color3.fromRGB(155, 105, 66)
 -- Rear and side fences are continuous; the front has a real entrance gate.
 for _, z in {-half, half} do
  local isFront = z == half
  for x = -half, half, 14 do
   if not (isFront and math.abs(x) < 14) then
    part(model, "FencePost", Vector3.new(1, 3, 1), center + Vector3.new(x, 1.5, z), WOOD, Enum.Material.Wood)
   end
  end
  if isFront then
   for _, side in {-1, 1} do
    part(model, "FenceRail", Vector3.new(half - 11, .45, .45), center + Vector3.new(side * (half + 11) / 2, 2.1, z), railColor, Enum.Material.Wood)
   end
  else
   part(model, "FenceRail", Vector3.new(half * 2, .45, .45), center + Vector3.new(0, 2.1, z), railColor, Enum.Material.Wood)
  end
 end
 for _, x in {-half, half} do
  for z = -half, half, 14 do
   if not (x == 0 and z == half) then
    part(model, "FencePost", Vector3.new(1, 3, 1), center + Vector3.new(x, 1.5, z), WOOD, Enum.Material.Wood)
   end
  end
  part(model, "FenceRail", Vector3.new(.45, .45, half * 2), center + Vector3.new(x, 2.1, 0), railColor, Enum.Material.Wood)
 end
 for _, x in {-11, 11} do
  part(model, "GatePost", Vector3.new(1.5, 5, 1.5), center + Vector3.new(x, 2.5, half), Color3.fromRGB(91, 61, 39), Enum.Material.Wood)
 end
 part(model, "GateTop", Vector3.new(22, .7, 1), center + Vector3.new(0, 4.6, half), Color3.fromRGB(139, 96, 59), Enum.Material.Wood)
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


local function farmhouse(model: Model, center: Vector3)
 center = center + Vector3.new(0, 0, -43)
 local wall = Color3.fromRGB(231, 211, 169)
 local roof = Color3.fromRGB(143, 74, 61)
 part(model, "FarmhouseFoundation", Vector3.new(42, 1.2, 34), center + Vector3.new(0, 1, -7), Color3.fromRGB(142, 132, 111), Enum.Material.Cobblestone)
 part(model, "FarmhouseWalls", Vector3.new(36, 15, 28), center + Vector3.new(0, 9, -7), wall, Enum.Material.WoodPlanks)
 local leftRoof = part(model, "FarmhouseRoofLeft", Vector3.new(42, 2, 19), center + Vector3.new(0, 17, -16), roof, Enum.Material.Slate)
 leftRoof.CFrame *= CFrame.Angles(math.rad(-32), 0, 0)
 local rightRoof = part(model, "FarmhouseRoofRight", Vector3.new(42, 2, 19), center + Vector3.new(0, 17, 2), roof, Enum.Material.Slate)
 rightRoof.CFrame *= CFrame.Angles(math.rad(32), 0, 0)
 part(model, "FarmhouseDoor", Vector3.new(5, 9, .8), center + Vector3.new(0, 5.5, -21.5), WOOD, Enum.Material.Wood)
 for _, x in {-11, 11} do
  part(model, "FarmhouseWindowFrame", Vector3.new(6, 5, .8), center + Vector3.new(x, 10, -21.5), WOOD, Enum.Material.Wood)
  part(model, "FarmhouseWindow", Vector3.new(4.8, 3.8, .3), center + Vector3.new(x, 10, -22), Color3.fromRGB(145, 202, 214), Enum.Material.Glass)
 end
 part(model, "FarmhousePorch", Vector3.new(28, .7, 8), center + Vector3.new(0, 2, -25), Color3.fromRGB(155, 111, 71), Enum.Material.WoodPlanks)
 for _, x in {-12, 12} do part(model, "PorchSupport", Vector3.new(.8, 7, .8), center + Vector3.new(x, 5, -28), CREAM, Enum.Material.Wood) end
 part(model, "Chimney", Vector3.new(5, 11, 5), center + Vector3.new(13, 22, -4), Color3.fromRGB(151, 91, 72), Enum.Material.Brick)
 local mailbox = part(model, "Mailbox", Vector3.new(3, 2, 2), center + Vector3.new(15, 2, 20), Color3.fromRGB(70, 111, 153), Enum.Material.Metal)
 mailbox.CanCollide = false
 part(model, "MailboxPost", Vector3.new(.6, 3, .6), center + Vector3.new(15, 1.5, 20), WOOD, Enum.Material.Wood)
end

local function orchardAndYard(model: Model, center: Vector3)
 for i, offset in {{-76, -8}, {-76, 18}, {76, -8}, {76, 18}} do
  makeTree(model, center + Vector3.new(offset[1], 0, offset[2]), .85 + (i % 2) * .12)
 end
 -- A small water trough and hay bales make the yard feel used, not like an empty template.
 local trough = part(model, "WaterTrough", Vector3.new(12, 2, 4), center + Vector3.new(-24, 1, 24), Color3.fromRGB(113, 143, 151), Enum.Material.Metal)
 trough.CanCollide = true
 for _, offset in {Vector3.new(25, 1.5, 20), Vector3.new(31, 1.5, 24)} do
  local hay = part(model, "HayBale", Vector3.new(5, 3, 4), center + offset, Color3.fromRGB(207, 174, 91), Enum.Material.Grass)
  hay.Shape = Enum.PartType.Cylinder
  hay.Orientation = Vector3.new(0, 0, 90)
 end
 for _, x in {-78, 78} do
  local post = part(model, "YardLamp", Vector3.new(.7, 7, .7), center + Vector3.new(x, 3.5, 65), WOOD, Enum.Material.Wood)
  local bulb = part(model, "YardLantern", Vector3.new(1.5, 1.5, 1.5), post.Position + Vector3.new(0, 3.7, 0), Color3.fromRGB(255, 222, 151), Enum.Material.Glass)
  bulb.Shape = Enum.PartType.Ball
  local light = Instance.new("PointLight"); light.Brightness = .55; light.Range = 12; light.Parent = bulb
 end
end

local function createPlot(index: number): Model
 local model = Instance.new("Model")
 model.Name = "FarmPlot_" .. index
 local column = (index - 1) % 4
 local row = math.floor((index - 1) / 4)
 local center = Vector3.new((column - 1.5) * 235, 0, 280 + row * 245)
 local ground = part(model, "Ground", Vector3.new(190, 1, 190), center, GRASS, Enum.Material.Grass)
 model.PrimaryPart = ground
 farmhouse(model, center)
 orchardAndYard(model, center)
 part(model, "FarmPath", Vector3.new(10, .15, 48), center + Vector3.new(0, .58, 65), Color3.fromRGB(177, 143, 99), Enum.Material.Ground)
 part(model, "FrontStep", Vector3.new(15, .3, 5), center + Vector3.new(0, .72, 91), Color3.fromRGB(145, 112, 76), Enum.Material.WoodPlanks)
 fence(model, center, 91)
 local gatePrompt = Instance.new("ProximityPrompt")
 gatePrompt.Name = "VisitFarmPrompt"
 gatePrompt.ActionText = "Visitar fazenda"
 gatePrompt.ObjectText = "Conhecer esta fazenda"
 gatePrompt.HoldDuration = .5
 gatePrompt.MaxActivationDistance = 12
 gatePrompt.RequiresLineOfSight = false
 local gateTop = model:FindFirstChild("GateTop")
 if gateTop and gateTop:IsA("BasePart") then gatePrompt.Parent = gateTop end

 -- Reserved build pads: players will later place their own coop, barn and pasture here.
 buildZone(model, "ChickenCoopBuildPad", center, Vector3.new(-53, 0, -45), Vector3.new(48, .35, 42), "Galinheiro")
 buildZone(model, "BarnBuildPad", center, Vector3.new(53, 0, -45), Vector3.new(54, .35, 48), "Celeiro")
 buildZone(model, "PastureBuildPad", center, Vector3.new(0, 0, 42), Vector3.new(92, .35, 48), "Pasto")
 -- Nine starter crop beds remain close to the farm entrance.
 for i = 1, 9 do
  local rowSlot = math.floor((i - 1) / 3)
  local col = (i - 1) % 3
  local bed = part(model, "GardenBed_" .. i, Vector3.new(10, .35, 10), center + Vector3.new(55 + col * 13, .72, 25 + rowSlot * 14), Color3.fromRGB(112, 75, 48), Enum.Material.Ground)
  bed:SetAttribute("PlantSlot", i)
 end

 local sign = part(model, "OwnerSign", Vector3.new(12, 4, .7), center + Vector3.new(0, 5, -84), CREAM, Enum.Material.WoodPlanks)
 sign.CanCollide = false
 local gui = Instance.new("BillboardGui")
 gui.Name = "SignText"; gui.Size = UDim2.fromOffset(132, 30); gui.StudsOffset = Vector3.new(0, 2.5, 0)
 gui.MaxDistance = 72; gui.Parent = sign
 local label = Instance.new("TextLabel")
 label.Name = "OwnerName"; label.Size = UDim2.fromScale(1, 1); label.BackgroundTransparency = 1
 label.Text = "FAZENDA DISPONÍVEL"; label.TextColor3 = Color3.fromRGB(75, 55, 35)
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
    character:PivotTo(plot:GetPivot() + Vector3.new(0, 5, 76))
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
