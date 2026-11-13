--!strict
-- Authoritative crop definitions. Keep prices and growth values server-side.
export type CropDefinition = {
    DisplayName: string,
    SeedCost: number,
    SellValue: number,
    GrowSeconds: number,
    Rarity: string,
    Color: Color3,
}

local Crops: {[string]: CropDefinition} = {
    Carrot = {
        DisplayName = "Carrot",
        SeedCost = 5,
        SellValue = 12,
        GrowSeconds = 30,
        Rarity = "Common",
        Color = Color3.fromRGB(255, 135, 45),
    },
    Tomato = {
        DisplayName = "Tomato",
        SeedCost = 12,
        SellValue = 28,
        GrowSeconds = 60,
        Rarity = "Uncommon",
        Color = Color3.fromRGB(220, 65, 55),
    },
    Blueberry = {
        DisplayName = "Blueberry",
        SeedCost = 25,
        SellValue = 65,
        GrowSeconds = 120,
        Rarity = "Rare",
        Color = Color3.fromRGB(75, 105, 220),
    },
}

return Crops
