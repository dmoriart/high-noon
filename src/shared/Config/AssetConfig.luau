--!strict
-- Replace these grey shapes with Josh's models here, without changing combat code.
return {
    Grey = Color3.fromRGB(132, 132, 132),
    Ground = Color3.fromRGB(166, 166, 166),
    ViewmodelOffset = CFrame.new(0.55, -0.6, -1.5),
    ViewmodelScale = 0.65,
    Revolver = {
        {Name = "Handle", Size = Vector3.new(0.3, 0.8, 0.4), Offset = CFrame.new()},
        {Name = "Barrel", Size = Vector3.new(0.2, 0.2, 1.2), Offset = CFrame.new(0, 0.4, -0.65)},
        {Name = "Cylinder", Size = Vector3.new(0.5, 0.45, 0.5), Offset = CFrame.new(0, 0.35, -0.12)},
    },
    Buildings = {
        {Name = "Saloon", Sign = "SALOON", Position = Vector3.new(-32, 0, -30), Width = 24, Depth = 24, Height = 20},
        {Name = "Sheriff", Sign = "SHERIFF", Position = Vector3.new(32, 0, 30), Width = 24, Depth = 24, Height = 16},
        {Name = "GeneralStore", Sign = "GENERAL STORE", Position = Vector3.new(-32, 0, 30), Width = 24, Depth = 24, Height = 16},
        {Name = "Stable", Sign = "LIVERY", Position = Vector3.new(32, 0, -30), Width = 24, Depth = 24, Height = 16},
    },
    Cover = {Vector3.new(-8, 2, -15), Vector3.new(8, 2, 15), Vector3.new(-12, 2, 42), Vector3.new(12, 2, -42)},
    SpawnPositions = {Vector3.new(-10, 1, -55), Vector3.new(10, 1, 55), Vector3.new(-50, 1, 0), Vector3.new(50, 1, 0)},
    ArenaSize = Vector3.new(140, 2, 150),
    WallHeight = 22,
    CoverSize = Vector3.new(6, 4, 5),
    ClockTime = 17,
    Brightness = 2,
    Ambient = Color3.fromRGB(150, 140, 125),
}
