--!strict
local TweenService = game:GetService("TweenService")
local FarmService = require(script.Parent.FarmService)

local FarmBuildingService = {}
local COSTS = {
 ChickenCoopBuildPad = { Wood = 30, Stone = 5, Name = "Galinheiro" },
 BarnBuildPad = { Wood = 55, Stone = 20, Name = "Celeiro" },
 PastureBuildPad = { Wood = 25, Stone = 0, Name = "Pasto" },
}

local function getResource(player: Player, name: string): IntValue?
 local stats = player:FindFirstChild("leaderstats")
 local value = stats and stats:FindFirstChild(name)
 if value and value:IsA("IntValue") then return value end
 return nil
end

local function makePart(parent: Instance, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material): Part
 local part = Instance.new("Part")
 part.Name = name; part.Size = size; part.CFrame = offset
 part.Anchored = true; part.TopSurface = Enum.SurfaceType.Smooth; part.BottomSurface = Enum.SurfaceType.Smooth
 part.Color = color; part.Material = material; part.Parent = parent
 return part
end

local function animal(parent: Instance, kind: string, origin: CFrame, tint: Color3)
 local model = Instance.new("Model")
 model.Name = kind
 model.Parent = parent
 local body = makePart(model, "Body", Vector3.new(4, 2.6, 2.4), origin, tint, Enum.Material.SmoothPlastic)
 body.Shape = Enum.PartType.Ball
 model.PrimaryPart = body
 if kind == "Chicken" then
  local head = makePart(model, "Head", Vector3.new(1.3, 1.3, 1.3), origin * CFrame.new(0, 1.25, -1.1), Color3.fromRGB(248, 242, 222), Enum.Material.SmoothPlastic)
  head.Shape = Enum.PartType.Ball
  local beak = makePart(model, "Beak", Vector3.new(.55, .35, .55), origin * CFrame.new(0, 1.1, -1.85), Color3.fromRGB(238, 157, 54), Enum.Material.SmoothPlastic)
  beak.Shape = Enum.PartType.Ball
  local comb = makePart(model, "Comb", Vector3.new(.45, .7, .4), origin * CFrame.new(0, 2, -1.05), Color3.fromRGB(190, 56, 48), Enum.Material.SmoothPlastic)
  comb.Shape = Enum.PartType.Ball
 else
  local head = makePart(model, "Head", Vector3.new(1.8, 1.8, 1.7), origin * CFrame.new(0, .3, -1.8), tint, Enum.Material.SmoothPlastic)
  head.Shape = Enum.PartType.Ball
  for _, x in {-1.1, 1.1} do
   for _, z in {-.75, .75} do
    makePart(model, "Leg", Vector3.new(.45, 1.4, .45), origin * CFrame.new(x, -1.6, z), Color3.fromRGB(93, 78, 62), Enum.Material.Wood)
   end
  end
  local patch = makePart(model, "CoatPatch", Vector3.new(1.4, .9, .35), origin * CFrame.new(.8, .45, -.25), Color3.fromRGB(55, 55, 52), Enum.Material.SmoothPlastic)
  patch.Shape = Enum.PartType.Ball
 end
 -- Small wandering loop; movement stays inside the animal's own pen.
 task.spawn(function()
  while model.Parent do
   local pivot = model:GetPivot()
   local target = pivot * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5)) * CFrame.Angles(0, math.rad(math.random(-90, 90)), 0)
   local start = pivot
   for step = 1, 30 do
    if not model.Parent then break end
    model:PivotTo(start:Lerp(target, step / 30))
    task.wait(.08)
   end
   task.wait(math.random(2, 5))
  end
 end)
end

local function buildCoop(plot: Model, pad: BasePart)
 local model = Instance.new("Model"); model.Name = "BuiltChickenCoop"; model.Parent = plot
 local cf = pad.CFrame
 makePart(model, "Floor", Vector3.new(30, 1, 24), cf * CFrame.new(0, 1, 0), Color3.fromRGB(145, 105, 68), Enum.Material.WoodPlanks)
 makePart(model, "Walls", Vector3.new(28, 12, 22), cf * CFrame.new(0, 7, 0), Color3.fromRGB(222, 190, 139), Enum.Material.WoodPlanks)
 local roofLeft = makePart(model, "RoofLeft", Vector3.new(36, 2, 17), cf * CFrame.new(0, 14, -7) * CFrame.Angles(math.rad(-29), 0, 0), Color3.fromRGB(151, 69, 57), Enum.Material.Slate)
 local roofRight = makePart(model, "RoofRight", Vector3.new(36, 2, 17), cf * CFrame.new(0, 14, 7) * CFrame.Angles(math.rad(29), 0, 0), Color3.fromRGB(151, 69, 57), Enum.Material.Slate)
 makePart(model, "DoorFrame", Vector3.new(7, 9, .8), cf * CFrame.new(0, 4.5, -11.6), Color3.fromRGB(105, 70, 44), Enum.Material.Wood)
 makePart(model, "Door", Vector3.new(5, 8, .5), cf * CFrame.new(0, 4.5, -12), Color3.fromRGB(145, 103, 66), Enum.Material.Wood)
 for _, x in {-9, 9} do
  makePart(model, "CoopWindow", Vector3.new(4, 3, .3), cf * CFrame.new(x, 8, -11.2), Color3.fromRGB(151, 205, 215), Enum.Material.Glass)
 end
 for i = 1, 3 do animal(model, "Chicken", cf * CFrame.new(-7 + i * 7, 3, 19), Color3.fromRGB(247, 241, 222)) end
end

local function buildBarn(plot: Model, pad: BasePart)
 local model = Instance.new("Model"); model.Name = "BuiltBarn"; model.Parent = plot
 local cf = pad.CFrame
 makePart(model, "Floor", Vector3.new(38, 1, 32), cf * CFrame.new(0, 1, 0), Color3.fromRGB(145, 105, 68), Enum.Material.WoodPlanks)
 makePart(model, "Walls", Vector3.new(36, 16, 30), cf * CFrame.new(0, 9, 0), Color3.fromRGB(160, 69, 57), Enum.Material.WoodPlanks)
 makePart(model, "RoofLeft", Vector3.new(48, 2.5, 21), cf * CFrame.new(0, 18, -8) * CFrame.Angles(math.rad(-28), 0, 0), Color3.fromRGB(75, 83, 91), Enum.Material.Slate)
 makePart(model, "RoofRight", Vector3.new(48, 2.5, 21), cf * CFrame.new(0, 18, 8) * CFrame.Angles(math.rad(28), 0, 0), Color3.fromRGB(75, 83, 91), Enum.Material.Slate)
 makePart(model, "BarnDoorFrame", Vector3.new(14, 12, .8), cf * CFrame.new(0, 6, -15.6), Color3.fromRGB(95, 59, 40), Enum.Material.Wood)
 makePart(model, "DoorLeft", Vector3.new(6, 11, .5), cf * CFrame.new(-3, 6, -16), Color3.fromRGB(158, 105, 64), Enum.Material.Wood)
 makePart(model, "DoorRight", Vector3.new(6, 11, .5), cf * CFrame.new(3, 6, -16), Color3.fromRGB(158, 105, 64), Enum.Material.Wood)
 animal(model, "Cow", cf * CFrame.new(-7, 3, 22), Color3.fromRGB(238, 235, 220))
 animal(model, "Cow", cf * CFrame.new(8, 3, 22), Color3.fromRGB(238, 235, 220))
end

local function buildPasture(plot: Model, pad: BasePart)
 local model = Instance.new("Model"); model.Name = "BuiltPasture"; model.Parent = plot
 local cf = pad.CFrame
 for _, x in {-39, 39} do
  for z = -20, 20, 10 do makePart(model, "PasturePost", Vector3.new(1, 4, 1), cf * CFrame.new(x, 2, z), Color3.fromRGB(107, 73, 46), Enum.Material.Wood) end
 end
 for _, z in {-20, 20} do
  for x = -39, 39, 10 do makePart(model, "PasturePost", Vector3.new(1, 4, 1), cf * CFrame.new(x, 2, z), Color3.fromRGB(107, 73, 46), Enum.Material.Wood) end
 end
 for _, height in {2.8, 4.0} do
  for _, z in {-20, 20} do makePart(model, "PastureRail", Vector3.new(78, .5, .5), cf * CFrame.new(0, height, z), Color3.fromRGB(143, 101, 65), Enum.Material.Wood) end
  for _, x in {-39, 39} do makePart(model, "PastureRail", Vector3.new(.5, .5, 40), cf * CFrame.new(x, height, 0), Color3.fromRGB(143, 101, 65), Enum.Material.Wood) end
 end
 makePart(model, "PastureGate", Vector3.new(10, 3, .7), cf * CFrame.new(0, 2.7, -20), Color3.fromRGB(143, 101, 65), Enum.Material.Wood)
end

local BUILDERS = {
 ChickenCoopBuildPad = buildCoop,
 BarnBuildPad = buildBarn,
 PastureBuildPad = buildPasture,
}

function FarmBuildingService.Init()
 for _, plot in workspace:WaitForChild("PlayerFarms"):GetChildren() do
  for padName, cost in COSTS do
   local pad = plot:FindFirstChild(padName)
   if pad and pad:IsA("BasePart") then
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "BuildPrompt"
    prompt.ActionText = "Construir • " .. cost.Name
    prompt.ObjectText = "Projeto da fazenda"
    prompt.HoldDuration = 1
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = pad
    prompt.Triggered:Connect(function(player)
     if plot:GetAttribute("OwnerUserId") ~= player.UserId then return end
     if plot:FindFirstChild("Built" .. cost.Name:gsub(" ", "")) then return end
     if pad:GetAttribute("Built") then return end
     local wood = getResource(player, "Wood")
     local stone = getResource(player, "Stone")
     if not wood or not stone or wood.Value < cost.Wood or stone.Value < cost.Stone then return end
     wood.Value -= cost.Wood
     stone.Value -= cost.Stone
     BUILDERS[padName](plot, pad)
     pad:SetAttribute("Built", true)
     prompt.Enabled = false
    end)
   end
  end
 end
end

return FarmBuildingService
