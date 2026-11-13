--!strict
-- Shared world layout. Coordinates are Roblox studs; keep farm plot anchors clear.
return {
	WorldBounds = 1800,
	Regions = {
		Greenfields = { Center = Vector3.new(-650, 0, 430), Radius = 720, Ground = Enum.Material.Grass },
		CentralVillage = { Center = Vector3.new(0, 0, -360), Radius = 330, Ground = Enum.Material.Cobblestone },
		WhisperingWoods = { Center = Vector3.new(-1110, 0, -610), Radius = 440, Ground = Enum.Material.LeafyGrass },
		HighlandRidge = { Center = Vector3.new(850, 0, -1120), Radius = 610, Ground = Enum.Material.Rock },
		SeasonalGrounds = { Center = Vector3.new(1240, 0, 1360), Radius = 360, Ground = Enum.Material.Grass },
	},
	FarmPlots = {
		Count = 12,
		Columns = 4,
		SpacingX = 235,
		SpacingZ = 245,
		FirstCenter = Vector3.new(-352.5, 0, 280),
	},
}
