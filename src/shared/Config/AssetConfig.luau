--!strict
-- AI-generated greybox kits; Josh replaces these with original art.
type Shape = {Name: string, Size: Vector3, Transform: CFrame, Material: Enum.Material, Shape: Enum.PartType?}
type Prop = {Name: string, Parts: {Shape}}
local scenery: {Prop} = {}

local function shape(name: string, size: Vector3, transform: CFrame, material: Enum.Material, form: Enum.PartType?): Shape
    return {Name = name, Size = size, Transform = transform, Material = material, Shape = form}
end

local function beam(name: string, a: Vector3, b: Vector3, thickness: number): Shape
    return shape(name, Vector3.new(thickness, thickness, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), Enum.Material.Wood, nil)
end

local function prop(name: string, at: CFrame, parts: {Shape})
    for _, piece in parts do piece.Transform = at * piece.Transform end
    table.insert(scenery, {Name = name, Parts = parts})
end

for _, side in {-1, 1} do
    local boards: {Shape} = {}
    for i = 0, 11 do
        table.insert(boards, shape("BoardwalkPlank", Vector3.new(6, 0.3, 9.8), CFrame.new(side * 16, 0.15, -55 + i * 10), Enum.Material.WoodPlanks, nil))
    end
    prop(if side < 0 then "WestBoardwalk" else "EastBoardwalk", CFrame.new(), boards)
    prop(if side < 0 then "WestHitchingRail" else "EastHitchingRail", CFrame.new(side * 15, 0, side * 47), {
        shape("Post", Vector3.new(0.6, 3, 0.6), CFrame.new(0, 1.5, -3), Enum.Material.Wood, nil),
        shape("Post", Vector3.new(0.6, 3, 0.6), CFrame.new(0, 1.5, 3), Enum.Material.Wood, nil),
        beam("Rail", Vector3.new(0, 2.7, -3.3), Vector3.new(0, 2.7, 3.3), 0.4),
    })
end

local tower: {Shape} = {}
for _, x in {-4, 4} do
    for _, z in {-4, 4} do
        table.insert(tower, shape("Leg", Vector3.new(0.9, 18, 0.9), CFrame.new(x, 9, z), Enum.Material.Wood, nil))
    end
    table.insert(tower, beam("Brace", Vector3.new(x, 2, -4), Vector3.new(x, 16, 4), 0.4))
    table.insert(tower, beam("Brace", Vector3.new(x, 2, 4), Vector3.new(x, 16, -4), 0.4))
end
for _, z in {-4, 4} do
    table.insert(tower, beam("Brace", Vector3.new(-4, 2, z), Vector3.new(4, 16, z), 0.4))
end
table.insert(tower, shape("Platform", Vector3.new(11, 0.7, 11), CFrame.new(0, 18, 0), Enum.Material.WoodPlanks, nil))
table.insert(tower, shape("Tank", Vector3.new(8, 10, 10), CFrame.new(0, 22, 0) * CFrame.Angles(0, 0, math.pi / 2), Enum.Material.WoodPlanks, Enum.PartType.Cylinder))
for _, y in {18.5, 25.5} do
    table.insert(tower, shape("TankBand", Vector3.new(0.35, 10.2, 10.2), CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.pi / 2), Enum.Material.Metal, Enum.PartType.Cylinder))
end
prop("WaterTower", CFrame.new(-10, 0, -65), tower)

local wagon: {Shape} = {
    shape("Bed", Vector3.new(5.5, 0.6, 9), CFrame.new(0, 2.6, 0), Enum.Material.WoodPlanks, nil),
    shape("Rear", Vector3.new(5.5, 1.8, 0.4), CFrame.new(0, 3.6, 4.3), Enum.Material.WoodPlanks, nil),
}
for _, side in {-1, 1} do
    table.insert(wagon, shape("Side", Vector3.new(0.4, 1.8, 9), CFrame.new(side * 2.6, 3.6, 0), Enum.Material.WoodPlanks, nil))
    table.insert(wagon, beam("Shaft", Vector3.new(side * 1.7, 2, -3), Vector3.new(side * 1.7, 1, -9), 0.3))
    for _, z in {-3, 3} do
        table.insert(wagon, shape("Wheel", Vector3.new(0.45, 3, 3), CFrame.new(side * 3.2, 1.5, z), Enum.Material.Wood, Enum.PartType.Cylinder))
        table.insert(wagon, shape("Hub", Vector3.new(0.6, 0.65, 0.65), CFrame.new(side * 3.3, 1.5, z), Enum.Material.Metal, Enum.PartType.Cylinder))
    end
end
prop("SupplyWagon", CFrame.new(-11, 0, 12), wagon)

for i, position in {Vector3.new(-13, 0, -8), Vector3.new(-15.5, 0, -6), Vector3.new(-13, 3, -8), Vector3.new(14, 0, 38), Vector3.new(16.5, 0, 40)} do
    local barrel: {Shape} = {shape("Staves", Vector3.new(3, 2.3, 2.3), CFrame.new(0, 1.5, 0) * CFrame.Angles(0, 0, math.pi / 2), Enum.Material.WoodPlanks, Enum.PartType.Cylinder)}
    for _, y in {0.3, 2.7} do
        table.insert(barrel, shape("Hoop", Vector3.new(0.15, 2.4, 2.4), CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.pi / 2), Enum.Material.Metal, Enum.PartType.Cylinder))
    end
    prop("Barrel" .. i, CFrame.new(position), barrel)
end

local canyon: {Shape} = {}
for _, x in {-92, 92} do
    for _, z in {-92, 92} do
        table.insert(canyon, shape("MesaBase", Vector3.new(58, 20, 54), CFrame.new(x, 10, z), Enum.Material.Rock, nil))
        table.insert(canyon, shape("MesaShelf", Vector3.new(44, 15, 40), CFrame.new(x, 27.5, z), Enum.Material.Rock, nil))
        table.insert(canyon, shape("MesaCrown", Vector3.new(30, 10, 28), CFrame.new(x, 40, z), Enum.Material.Rock, nil))
    end
end
for _, side in {-1, 1} do
    for i, z in {-50, -20, 20, 50} do
        local height = 25 + (i % 3) * 5
        table.insert(canyon, shape("CliffOutcrop", Vector3.new(10, height, 20), CFrame.new(side * 95, height / 2, z) * CFrame.Angles(0, math.rad(side * 8), 0), Enum.Material.Rock, nil))
    end
end
prop("CanyonRim", CFrame.new(), canyon)

local fence: {Shape} = {}
for _, side in {-1, 1} do
    for z = -75, 75, 15 do
        table.insert(fence, shape("FencePost", Vector3.new(0.8, 9, 0.8), CFrame.new(side * 70, 4.5, z), Enum.Material.Wood, nil))
    end
    for x = -60, 60, 15 do
        table.insert(fence, shape("FencePost", Vector3.new(0.8, 9, 0.8), CFrame.new(x, 4.5, side * 75), Enum.Material.Wood, nil))
    end
    for _, y in {3, 7} do
        table.insert(fence, shape("FenceRail", Vector3.new(0.5, 0.5, 150), CFrame.new(side * 70, y, 0), Enum.Material.Wood, nil))
        table.insert(fence, shape("FenceRail", Vector3.new(140, 0.5, 0.5), CFrame.new(0, y, side * 75), Enum.Material.Wood, nil))
    end
end
prop("FrontierFence", CFrame.new(), fence)

return {
    Grey = Color3.fromRGB(132, 132, 132),
    SceneryGrey = Color3.fromRGB(180, 180, 180),
    Ground = Color3.fromRGB(190, 190, 190),
    ViewmodelOffset = CFrame.new(0.55, -0.6, -1.5),
    ViewmodelScale = 0.65,
    Revolver = {
        {Name = "Handle", Size = Vector3.new(0.3, 0.8, 0.4), Offset = CFrame.new()},
        {Name = "Barrel", Size = Vector3.new(0.2, 0.2, 1.2), Offset = CFrame.new(0, 0.4, -0.65)},
        {Name = "Cylinder", Size = Vector3.new(0.5, 0.45, 0.5), Offset = CFrame.new(0, 0.35, -0.12)},
    },
    Buildings = {
        {Name = "Saloon", Bars = false, Sign = "SALOON", Position = Vector3.new(-32, 0, -30), Width = 24, Depth = 24, Height = 20},
        {Name = "Sheriff", Bars = true, Sign = "SHERIFF", Position = Vector3.new(32, 0, 30), Width = 24, Depth = 24, Height = 16},
        {Name = "GeneralStore", Bars = false, Sign = "GENERAL STORE", Position = Vector3.new(-32, 0, 30), Width = 24, Depth = 24, Height = 16},
        {Name = "Stable", Bars = false, Sign = "LIVERY", Position = Vector3.new(32, 0, -30), Width = 24, Depth = 24, Height = 16},
    },
    Cover = {Vector3.new(-8, 2, -15), Vector3.new(8, 2, 15), Vector3.new(-12, 2, 42), Vector3.new(12, 2, -42)},
    SpawnPositions = {Vector3.new(-10, 1, -55), Vector3.new(10, 1, 55), Vector3.new(-50, 1, 0), Vector3.new(50, 1, 0)},
    ArenaSize = Vector3.new(140, 2, 150),
    GroundSize = Vector3.new(300, 2, 300),
    BoundaryTransparency = 1,
    WallHeight = 22,
    CoverSize = Vector3.new(6, 4, 5),
    Scenery = scenery,
    BuildingStyle = {
        Material = Enum.Material.WoodPlanks,
        DoorWidth = 6,
        DoorHeight = 9,
        WallThickness = 0.7,
        FrontHeight = 12,
        FrontRise = 3,
        CrownRise = 2,
        CrownWidth = 12,
        WindowOffset = 8,
        WindowHeight = 7,
        WindowSize = 3.5,
        WindowDepth = 0.12,
        WindowGrey = Color3.fromRGB(66, 66, 66),
        Trim = 0.3,
        PorchReach = 4,
        RailHeight = 2.4,
        RailThickness = 0.35,
        SignHeight = 3,
        SignDepth = 0.7,
        SignMargin = 2,
        SignCanvas = Vector2.new(1000, 160),
    },
    GroundMaterial = Enum.Material.Sand,
    BoundaryMaterial = Enum.Material.Rock,
    ClockTime = 16.3,
    Brightness = 3,
    Ambient = Color3.fromRGB(155, 145, 129),
    OutdoorAmbient = Color3.fromRGB(180, 165, 145),
    Atmosphere = {
        Color = Color3.fromRGB(224, 205, 174),
        Decay = Color3.fromRGB(148, 127, 102),
        Density = 0.22,
        Haze = 1.2,
        Glare = 0.2,
    },
    Tone = {TintColor = Color3.fromRGB(255, 237, 211), Saturation = -0.12, Contrast = 0.05},
}
