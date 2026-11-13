--!strict
-- A simple server-controlled test vehicle so developers can judge the scale of Greenfields.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local VehicleService = {}
local vehicle: Model? = nil
local seat: VehicleSeat? = nil
local chassis: Part? = nil

local MAX_SPEED = 58
local REVERSE_SPEED = 26
local TURN_RATE = 1.65

local function makePart(parent: Instance, name: string, size: Vector3, color: Color3, material: Enum.Material, cf: CFrame, shape: Enum.PartType?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Color = color
    p.Material = material
    p.CFrame = cf
    p.Anchored = false
    p.CanCollide = false
    p.Massless = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function weld(root: BasePart, part: BasePart)
    local constraint = Instance.new("WeldConstraint")
    constraint.Part0 = root
    constraint.Part1 = part
    constraint.Parent = root
end

local function buildCar(parent: Instance): Model
    local model = Instance.new("Model")
    model.Name = "GreenfieldsExplorerCar"
    model.Parent = parent

    local base = Instance.new("Part")
    base.Name = "Chassis"
    base.Size = Vector3.new(8, 1.1, 12)
    base.Position = Vector3.new(-80, 5, 330)
    base.Color = Color3.fromRGB(54, 70, 57)
    base.Material = Enum.Material.Metal
    base.Anchored = false
    base.TopSurface = Enum.SurfaceType.Smooth
    base.BottomSurface = Enum.SurfaceType.Smooth
    base.Parent = model
    base:SetNetworkOwner(nil)
    model.PrimaryPart = base
    chassis = base

    local function add(name: string, size: Vector3, offset: Vector3, color: Color3, material: Enum.Material, shape: Enum.PartType?)
        local p = makePart(model, name, size, color, material, base.CFrame * CFrame.new(offset), shape)
        weld(base, p)
        return p
    end

    add("LowerBody", Vector3.new(8.4, 1.5, 11.5), Vector3.new(0, 1.15, 0), Color3.fromRGB(63, 126, 82), Enum.Material.SmoothPlastic, nil)
    add("Hood", Vector3.new(7.8, 1.2, 3.8), Vector3.new(0, 2.1, -3.4), Color3.fromRGB(75, 151, 94), Enum.Material.SmoothPlastic, nil)
    add("Cabin", Vector3.new(6.4, 3.1, 5.2), Vector3.new(0, 3.1, 1.1), Color3.fromRGB(76, 137, 153), Enum.Material.Glass, nil).Transparency = .22
    add("Roof", Vector3.new(6.8, .55, 5.5), Vector3.new(0, 4.95, 1.1), Color3.fromRGB(49, 103, 68), Enum.Material.SmoothPlastic, nil)
    add("FrontBumper", Vector3.new(8.5, .65, .6), Vector3.new(0, .65, -6.1), Color3.fromRGB(40, 43, 42), Enum.Material.Metal, nil)
    add("RearBumper", Vector3.new(8.5, .65, .6), Vector3.new(0, .65, 6.1), Color3.fromRGB(40, 43, 42), Enum.Material.Metal, nil)

    for _, x in {-3.9, 3.9} do
        for _, z in {-3.8, 3.8} do
            local wheel = add("AllTerrainWheel", Vector3.new(2.5, 1.15, 2.5), Vector3.new(x, .1, z), Color3.fromRGB(35, 38, 36), Enum.Material.Rubber, Enum.PartType.Cylinder)
            wheel.CFrame *= CFrame.Angles(0, 0, math.rad(90))
            local hub = add("WheelHub", Vector3.new(1.05, 1.2, 1.05), Vector3.new(x * 1.02, .1, z), Color3.fromRGB(164, 166, 151), Enum.Material.Metal, Enum.PartType.Cylinder)
            hub.CFrame *= CFrame.Angles(0, 0, math.rad(90))
        end
    end

    for _, x in {-2.7, 2.7} do
        local lamp = add("Headlamp", Vector3.new(1.15, .65, .2), Vector3.new(x, 2.1, -5.35), Color3.fromRGB(255, 231, 164), Enum.Material.Neon, nil)
        lamp.CanCollide = false
    end

    local driverSeat = Instance.new("VehicleSeat")
    driverSeat.Name = "DriverSeat"
    driverSeat.Size = Vector3.new(2.4, 1, 2.4)
    driverSeat.CFrame = base.CFrame * CFrame.new(0, 2.25, 1.1)
    driverSeat.Color = Color3.fromRGB(49, 54, 48)
    driverSeat.Material = Enum.Material.Leather
    driverSeat.Anchored = false
    driverSeat.Parent = model
    weld(base, driverSeat)
    seat = driverSeat

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Dirigir"
    prompt.ObjectText = "Carro explorador"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = .25
    prompt.MaxActivationDistance = 12
    prompt.Parent = driverSeat

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VehicleLabel"
    billboard.Size = UDim2.fromOffset(190, 42)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = base
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(36, 57, 43)
    label.BackgroundTransparency = .15
    label.Text = "CARRO EXPLORADOR"
    label.TextColor3 = Color3.fromRGB(255, 244, 216)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    prompt.Triggered:Connect(function(player)
        if driverSeat and not driverSeat.Occupant then
            driverSeat:Sit(player.Character and player.Character:FindFirstChildOfClass("Humanoid") or nil)
        end
    end)

    return model
end

function VehicleService.Init()
    local map = workspace:FindFirstChild("HarvestWorldMap")
    if not map then
        warn("[HarvestWorld] VehicleService skipped: map not found.")
        return
    end
    local old = map:FindFirstChild("GreenfieldsExplorerCar")
    if old then old:Destroy() end
    vehicle = buildCar(map)
    print("[HarvestWorld] Greenfields explorer car spawned near the farm district.")
end

RunService.Heartbeat:Connect(function()
    if not seat or not chassis then return end
    local occupant = seat.Occupant
    if not occupant then
        chassis.AssemblyAngularVelocity = Vector3.zero
        local velocity = chassis.AssemblyLinearVelocity
        chassis.AssemblyLinearVelocity = Vector3.new(velocity.X * .92, velocity.Y, velocity.Z * .92)
        return
    end

    local throttle = seat.ThrottleFloat
    local steer = seat.SteerFloat
    local forward = chassis.CFrame.LookVector
    local currentSpeed = throttle >= 0 and MAX_SPEED or REVERSE_SPEED
    local target = forward * (throttle * currentSpeed)
    local velocity = chassis.AssemblyLinearVelocity
    chassis.AssemblyLinearVelocity = Vector3.new(target.X, velocity.Y, target.Z)
    local speedFactor = math.clamp(math.abs(throttle) + .15, 0, 1)
    chassis.AssemblyAngularVelocity = Vector3.new(0, -steer * TURN_RATE * speedFactor, 0)
end)

Players.PlayerRemoving:Connect(function(player)
    if seat and seat.Occupant and Players:GetPlayerFromCharacter(seat.Occupant.Parent) == player then
        seat:Sit(nil)
    end
end)

return VehicleService
