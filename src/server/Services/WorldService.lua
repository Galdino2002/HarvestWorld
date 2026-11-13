--!strict
local WorldService = {}
local root: Folder
local grass = Color3.fromRGB(111, 166, 91)
local wood = Color3.fromRGB(105, 72, 48)
local road = Color3.fromRGB(190, 157, 112)

local function part(parent: Instance, name: string, size: Vector3, pos: Vector3, color: Color3, material: Enum.Material): Part
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=pos; p.Anchored=true
 p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
 p.Color=color; p.Material=material; p.Parent=parent; return p
end
local function tree(parent: Instance,x:number,z:number,s:number)
 local trunk=part(parent,"TreeTrunk",Vector3.new(2,7,2)*s,Vector3.new(x,3.5*s,z),wood,Enum.Material.Wood); trunk.Shape=Enum.PartType.Cylinder
 local crown=part(parent,"TreeCrown",Vector3.new(9,9,9)*s,Vector3.new(x,8*s,z),Color3.fromRGB(73,139,75),Enum.Material.Grass); crown.Shape=Enum.PartType.Ball
 local crown2=part(parent,"TreeCrownSmall",Vector3.new(6,6,6)*s,Vector3.new(x+2*s,10*s,z+s),Color3.fromRGB(91,153,81),Enum.Material.Grass); crown2.Shape=Enum.PartType.Ball
end
local function building(parent:Instance,name:string,pos:Vector3,wall:Color3,roof:Color3,w:number,d:number)
 local m=Instance.new("Model"); m.Name=name; m.Parent=parent
 part(m,"Foundation",Vector3.new(w+3,1,d+3),pos+Vector3.new(0,.5,0),Color3.fromRGB(130,133,122),Enum.Material.Cobblestone)
 part(m,"Walls",Vector3.new(w,13,d),pos+Vector3.new(0,7,0),wall,Enum.Material.WoodPlanks)
 part(m,"Roof",Vector3.new(w+5,4,d+5),pos+Vector3.new(0,15,0),roof,Enum.Material.Slate)
 part(m,"Door",Vector3.new(4,8,.6),pos+Vector3.new(0,4.5,-d/2-.4),wood,Enum.Material.Wood)
 for _,x in {-w/3,w/3} do part(m,"Window",Vector3.new(4,4,.5),pos+Vector3.new(x,8,-d/2-.4),Color3.fromRGB(139,204,218),Enum.Material.Glass) end
end
local function village()
 local f=Instance.new("Folder"); f.Name="CentralVillage"; f.Parent=root
 part(f,"VillageGreen",Vector3.new(340,1,230),Vector3.new(0,.1,-300),Color3.fromRGB(126,173,101),Enum.Material.Grass)
 part(f,"MainStreet",Vector3.new(34,.3,250),Vector3.new(0,.8,-285),road,Enum.Material.Ground)
 part(f,"MarketSquare",Vector3.new(110,.35,80),Vector3.new(0,.9,-300),Color3.fromRGB(205,177,132),Enum.Material.Cobblestone)
 building(f,"SeedShop",Vector3.new(-82,1,-350),Color3.fromRGB(230,194,133),Color3.fromRGB(169,83,63),48,38)
 building(f,"HarvestMarket",Vector3.new(82,1,-350),Color3.fromRGB(226,213,169),Color3.fromRGB(83,132,82),52,42)
 building(f,"Workshop",Vector3.new(-120,1,-220),Color3.fromRGB(184,155,119),Color3.fromRGB(92,107,120),42,38)
 building(f,"TownHall",Vector3.new(0,1,-190),Color3.fromRGB(238,222,181),Color3.fromRGB(93,124,82),58,42)
 building(f,"Cafe",Vector3.new(120,1,-220),Color3.fromRGB(232,174,150),Color3.fromRGB(126,83,66),42,38)
 for _,x in {-135,-55,55,135} do
  local post=part(f,"VillageLamp",Vector3.new(.7,9,.7),Vector3.new(x,5,-300),wood,Enum.Material.Wood)
  local glow=part(f,"Lantern",Vector3.new(2,2,2),post.Position+Vector3.new(0,5,0),Color3.fromRGB(255,226,143),Enum.Material.Glass); glow.Shape=Enum.PartType.Ball
  local light=Instance.new("PointLight"); light.Color=glow.Color; light.Brightness=1; light.Range=18; light.Parent=glow
 end
end
local function river()
 local f=Instance.new("Folder"); f.Name="HarvestRiver"; f.Parent=root
 part(f,"RiverWater",Vector3.new(1100,2,66),Vector3.new(0,-.1,65),Color3.fromRGB(76,157,190),Enum.Material.Glass)
 part(f,"NorthBank",Vector3.new(1100,1.5,15),Vector3.new(0,.2,24),grass,Enum.Material.Grass)
 part(f,"SouthBank",Vector3.new(1100,1.5,15),Vector3.new(0,.2,106),grass,Enum.Material.Grass)
 part(f,"BridgeDeck",Vector3.new(30,2,92),Vector3.new(0,2,65),Color3.fromRGB(133,91,55),Enum.Material.WoodPlanks)
 for _,x in {-13,13} do
  part(f,"BridgeRail",Vector3.new(1,4,92),Vector3.new(x,4.5,65),wood,Enum.Material.Wood)
  for z=25,105,12 do part(f,"BridgePost",Vector3.new(1.5,6,1.5),Vector3.new(x,5,z),wood,Enum.Material.Wood) end
 end
 part(f,"NorthBridgePath",Vector3.new(30,.3,65),Vector3.new(0,1,-5),road,Enum.Material.Ground)
 part(f,"SouthBridgePath",Vector3.new(30,.3,70),Vector3.new(0,1,145),road,Enum.Material.Ground)
end
local function nature()
 local f=Instance.new("Folder"); f.Name="Nature"; f.Parent=root
 for i=1,24 do
  local z=-480+(i%8)*135
  tree(f,-500-(i%3)*22,z,.8+(i%4)*.12)
  tree(f,500+(i%3)*22,z+35,.85+(i%3)*.14)
 end
 for i=1,16 do tree(f,-420+i*53,-475-(i%3)*18,.7+(i%4)*.1) end
 for i=1,12 do
  local side=if i%2==0 then -1 else 1
  local hill=part(f,"RollingHill",Vector3.new(115,48,100),Vector3.new(side*(420+(i%3)*25),8,-430+i*78),Color3.fromRGB(105,157,91),Enum.Material.Grass)
  hill.Shape=Enum.PartType.Ball
 end
end
function WorldService.Init()
 local defaultBaseplate=workspace:FindFirstChild("Baseplate")
 if defaultBaseplate and defaultBaseplate:IsA("BasePart") then defaultBaseplate:Destroy() end
 if workspace:FindFirstChild("HarvestWorldMap") then root=workspace.HarvestWorldMap :: Folder; return end
 root=Instance.new("Folder"); root.Name="HarvestWorldMap"; root.Parent=workspace
 part(root,"GreenfieldsGround",Vector3.new(1200,2,1200),Vector3.new(0,-1.7,0),grass,Enum.Material.Grass)
 river(); village(); nature()
 print("[HarvestWorld] Greenfields world generated.")
end
return WorldService
