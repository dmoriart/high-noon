--!strict
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Assets = require(game:GetService("ReplicatedStorage").Config.AssetConfig)
local Arena = {}

local function part(parent: Instance, name: string, size: Vector3, position: Vector3): Part
    local p = Instance.new("Part")
    p.Name = "PLACEHOLDER_" .. name
    p.Size, p.Position = size, position
    p.Anchored = true
    p.Color = Assets.Grey
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    CollectionService:AddTag(p, "NeedsArt")
    p.Parent = parent
    return p
end

function Arena.build(): {SpawnLocation}
    assert(not workspace:FindFirstChild("HighNoonArena"), "High Noon arena already exists")
    local arena = Instance.new("Folder")
    arena.Name = "HighNoonArena"
    arena.Parent = workspace
    local ground = part(arena, "FrontierGround", Assets.ArenaSize, Vector3.new(0, -1, 0))
    ground.Color = Assets.Ground
    for _, b in Assets.Buildings do
        local model = Instance.new("Model")
        model.Name = "PLACEHOLDER_" .. b.Name
        CollectionService:AddTag(model, "NeedsArt")
        model.Parent = arena
        local facing = if b.Position.X < 0 then 1 else -1
        part(model, "RearWall", Vector3.new(1, b.Height, b.Depth), b.Position + Vector3.new(-facing * b.Width / 2, b.Height / 2, 0))
        for _, side in {-1, 1} do
            part(model, "SideWall", Vector3.new(b.Width, b.Height, 1), b.Position + Vector3.new(0, b.Height / 2, side * b.Depth / 2))
            part(model, "PorchPost", Vector3.new(1, b.Height * 0.6, 1), b.Position + Vector3.new(facing * (b.Width / 2 + 4), b.Height * 0.3, side * b.Depth / 2))
        end
        part(model, "Roof", Vector3.new(b.Width + 2, 1, b.Depth + 2), b.Position + Vector3.new(0, b.Height, 0))
        part(model, "Awning", Vector3.new(6, 1, b.Depth + 2), b.Position + Vector3.new(facing * (b.Width / 2 + 2), b.Height * 0.6, 0))
        local sign = part(model, "Sign", Vector3.new(1, 3, b.Depth - 2), b.Position + Vector3.new(facing * (b.Width / 2), b.Height - 2, 0))
        local gui = Instance.new("SurfaceGui")
        gui.Face = if facing > 0 then Enum.NormalId.Right else Enum.NormalId.Left
        gui.Parent = sign
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text, label.TextScaled = b.Sign, true
        label.TextColor3 = Color3.fromRGB(30, 30, 30)
        label.Font = Enum.Font.Antique
        label.Parent = gui
    end
    for i, position in Assets.Cover do
        part(arena, "Crate" .. i, Assets.CoverSize, position)
    end
    local x, z, h = Assets.ArenaSize.X / 2, Assets.ArenaSize.Z / 2, Assets.WallHeight
    for _, side in {-1, 1} do
        part(arena, "Boundary", Vector3.new(2, h, z * 2), Vector3.new(side * x, h / 2, 0))
        part(arena, "Boundary", Vector3.new(x * 2, h, 2), Vector3.new(0, h / 2, side * z))
    end
    local spawns: {SpawnLocation} = {}
    for i, position in Assets.SpawnPositions do
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "PLACEHOLDER_Spawn" .. i
        spawn.Size, spawn.Position = Vector3.new(5, 1, 5), position
        spawn.Anchored, spawn.Neutral, spawn.Transparency = true, true, 1
        spawn.CanCollide, spawn.Duration = false, 0
        CollectionService:AddTag(spawn, "NeedsArt")
        spawn.Parent = arena
        table.insert(spawns, spawn)
    end
    Lighting.ClockTime, Lighting.Brightness, Lighting.Ambient = Assets.ClockTime, Assets.Brightness, Assets.Ambient
    return spawns
end

function Arena.revolver(): Tool
    local tool = Instance.new("Tool")
    tool.Name, tool.CanBeDropped = "Revolver", false
    tool:SetAttribute("HighNoonWeapon", true)
    for _, shape in Assets.Revolver do
        local p = part(tool, shape.Name, shape.Size, Vector3.zero)
        p.Name = if shape.Name == "Handle" then "Handle" else "PLACEHOLDER_" .. shape.Name
        p.CFrame, p.Anchored, p.CanCollide, p.Massless = shape.Offset, false, false, true
    end
    local handle = tool:FindFirstChild("Handle") :: BasePart
    for _, child in tool:GetChildren() do
        if child:IsA("BasePart") and child ~= handle then
            local weld = Instance.new("WeldConstraint")
            weld.Part0, weld.Part1, weld.Parent = handle, child, handle
        end
    end
    return tool
end

return Arena
