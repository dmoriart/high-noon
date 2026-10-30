--!strict
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Assets = require(game:GetService("ReplicatedStorage").Config.AssetConfig)
local Arena = {}

local function part(parent: Instance, name: string, size: Vector3, position: Vector3, material: Enum.Material?): Part
    local p = Instance.new("Part")
    p.Name = "PLACEHOLDER_" .. name
    p.Size, p.Position = size, position
    p.Anchored = true
    p.Color = if material then Assets.SceneryGrey else Assets.Grey
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    CollectionService:AddTag(p, "NeedsArt")
    p.Parent = parent
    return p
end

type Building = {Name: string, Sign: string, Position: Vector3, Width: number, Depth: number, Height: number, Bars: boolean}

local function building(parent: Instance, b: Building)
    local style = Assets.BuildingStyle
    local model = Instance.new("Model")
    model.Name = "PLACEHOLDER_" .. b.Name
    CollectionService:AddTag(model, "NeedsArt")
    model.Parent = parent
    local facing = if b.Position.X < 0 then 1 else -1
    local front = facing * b.Width / 2
    local function wood(name: string, size: Vector3, offset: Vector3): Part
        return part(model, name, size, b.Position + offset, style.Material)
    end
    wood("RearWall", Vector3.new(1, b.Height, b.Depth), Vector3.new(-front, b.Height / 2, 0))
    local panelWidth = (b.Depth - style.DoorWidth) / 2
    for _, side in {-1, 1} do
        wood("SideWall", Vector3.new(b.Width, b.Height, 1), Vector3.new(0, b.Height / 2, side * b.Depth / 2))
        wood("PorchPost", Vector3.new(1, b.Height * 0.6, 1), Vector3.new(front + facing * style.PorchReach, b.Height * 0.3, side * b.Depth / 2))
        wood("FrontPanel", Vector3.new(style.WallThickness, style.FrontHeight, panelWidth), Vector3.new(front, style.FrontHeight / 2, side * (style.DoorWidth + panelWidth) / 2))
        wood("PorchRail", Vector3.new(style.PorchReach, style.RailThickness, style.RailThickness), Vector3.new(front + facing * style.PorchReach / 2, style.RailHeight, side * b.Depth / 2))
        local windowPosition = Vector3.new(front + facing * (style.WallThickness + style.WindowDepth) / 2, style.WindowHeight, side * style.WindowOffset)
        local pane = wood("Window", Vector3.new(style.WindowDepth, style.WindowSize, style.WindowSize), windowPosition)
        pane.Color = style.WindowGrey
        local trimX = windowPosition.X + facing * style.WindowDepth
        for _, edge in {-1, 1} do
            wood("WindowTrim", Vector3.new(style.Trim, style.Trim, style.WindowSize + style.Trim), Vector3.new(trimX, style.WindowHeight + edge * style.WindowSize / 2, windowPosition.Z))
            wood("WindowTrim", Vector3.new(style.Trim, style.WindowSize, style.Trim), Vector3.new(trimX, style.WindowHeight, windowPosition.Z + edge * style.WindowSize / 2))
        end
        if b.Bars then
            for _, bar in {-1, 0, 1} do
                part(model, "CellWindowBar", Vector3.new(style.Trim, style.WindowSize, style.Trim), b.Position + Vector3.new(trimX + facing * style.Trim, style.WindowHeight, windowPosition.Z + bar * style.WindowSize / 4), Enum.Material.Metal)
            end
        end
    end
    wood("DoorLintel", Vector3.new(style.WallThickness, style.FrontHeight - style.DoorHeight, style.DoorWidth), Vector3.new(front, (style.FrontHeight + style.DoorHeight) / 2, 0))
    wood("UpperFront", Vector3.new(style.WallThickness, b.Height - style.FrontHeight, b.Depth), Vector3.new(front, (b.Height + style.FrontHeight) / 2, 0))
    wood("Roof", Vector3.new(b.Width + 2, 1, b.Depth + 2), Vector3.new(0, b.Height, 0))
    wood("Awning", Vector3.new(6, 1, b.Depth + 2), Vector3.new(front + facing * 2, b.Height * 0.6, 0))
    wood("FalseFront", Vector3.new(style.WallThickness, style.FrontRise, b.Depth + style.SignMargin), Vector3.new(front, b.Height + style.FrontRise / 2, 0))
    wood("FacadeCrown", Vector3.new(style.WallThickness, style.CrownRise, style.CrownWidth), Vector3.new(front, b.Height + style.FrontRise + style.CrownRise / 2, 0))
    local signX = front + facing * (style.WallThickness + style.SignDepth) / 2
    local signY = b.Height - style.SignHeight / 2
    local sign = wood("Sign", Vector3.new(style.SignDepth, style.SignHeight, b.Depth - style.SignMargin), Vector3.new(signX, signY, 0))
    for _, edge in {-1, 1} do
        wood("SignFrame", Vector3.new(style.Trim, style.Trim, b.Depth - style.SignMargin), Vector3.new(signX + facing * style.SignDepth / 2, signY + edge * style.SignHeight / 2, 0))
    end
    local gui = Instance.new("SurfaceGui")
    gui.Face = if facing > 0 then Enum.NormalId.Right else Enum.NormalId.Left
    gui.CanvasSize = style.SignCanvas
    gui.Parent = sign
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text, label.TextScaled = b.Sign, true
    label.TextColor3 = Color3.fromRGB(30, 30, 30)
    label.Font = Enum.Font.Antique
    label.Parent = gui
end

function Arena.build(): {SpawnLocation}
    local preview = workspace:FindFirstChild("HighNoonArena")
    if preview and preview:GetAttribute("StylePreview") == true then
        for _, object in preview:GetDescendants() do
            assert(not CollectionService:HasTag(object, "JoshArt"), "Protected art in the town preview")
            if object:IsA("BasePart") then
                assert(CollectionService:HasTag(object, "NeedsArt"), "Unrecognised art in the town preview")
            end
        end
        preview:Destroy()
    end
    assert(not workspace:FindFirstChild("HighNoonArena"), "High Noon arena already exists")
    local arena = Instance.new("Folder")
    arena.Name = "HighNoonArena"
    arena.Parent = workspace
    local ground = part(arena, "FrontierGround", Assets.GroundSize, Vector3.new(0, -1, 0), Assets.GroundMaterial)
    ground.Color = Assets.Ground
    for _, b in Assets.Buildings do building(arena, b) end
    for _, prop in Assets.Scenery do
        local model = Instance.new("Model")
        model.Name = "PLACEHOLDER_" .. prop.Name
        CollectionService:AddTag(model, "NeedsArt")
        model.Parent = arena
        for _, piece in prop.Parts do
            local p = part(model, piece.Name, piece.Size, piece.Transform.Position, piece.Material)
            p.CFrame = piece.Transform
            if piece.Shape then p.Shape = piece.Shape end
        end
    end
    for i, position in Assets.Cover do
        part(arena, "Crate" .. i, Assets.CoverSize, position, Assets.BuildingStyle.Material)
    end
    local x, z, h = Assets.ArenaSize.X / 2, Assets.ArenaSize.Z / 2, Assets.WallHeight
    for _, side in {-1, 1} do
        part(arena, "Boundary", Vector3.new(2, h, z * 2), Vector3.new(side * x, h / 2, 0), Assets.BoundaryMaterial).Transparency = Assets.BoundaryTransparency
        part(arena, "Boundary", Vector3.new(x * 2, h, 2), Vector3.new(0, h / 2, side * z), Assets.BoundaryMaterial).Transparency = Assets.BoundaryTransparency
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
    Lighting.OutdoorAmbient, Lighting.GlobalShadows = Assets.OutdoorAmbient, true
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
    atmosphere.Color, atmosphere.Decay = Assets.Atmosphere.Color, Assets.Atmosphere.Decay
    atmosphere.Density, atmosphere.Haze, atmosphere.Glare = Assets.Atmosphere.Density, Assets.Atmosphere.Haze, Assets.Atmosphere.Glare
    if not atmosphere.Parent then atmosphere.Name, atmosphere.Parent = "HighNoonDust", Lighting end
    local existingTone = Lighting:FindFirstChild("HighNoonWesternTone")
    assert(not existingTone or existingTone:IsA("ColorCorrectionEffect"), "Unexpected HighNoonWesternTone instance")
    local tone = (existingTone or Instance.new("ColorCorrectionEffect")) :: ColorCorrectionEffect
    tone.Name = "HighNoonWesternTone"
    tone.TintColor, tone.Saturation, tone.Contrast = Assets.Tone.TintColor, Assets.Tone.Saturation, Assets.Tone.Contrast
    tone.Parent = Lighting
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
