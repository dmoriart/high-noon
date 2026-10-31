--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Assets = require(ReplicatedStorage.Config.AssetConfig)
local Art = {}

function Art.clone(slot: string): Model?
    local name = Assets.Models[slot]
    assert(name ~= nil, "Unknown art slot: " .. slot)
    if name == "" then return nil end
    local folder = ReplicatedStorage:FindFirstChild("Art")
    local source = if folder then folder:FindFirstChild(name) else nil
    assert(source and source:IsA("Model"), "Art slot " .. slot .. " needs Model ReplicatedStorage.Art." .. name)
    assert(source.Archivable, "Art model must be Archivable: " .. name)
    for _, object in source:GetDescendants() do
        assert(not object:IsA("LuaSourceContainer"), "Art must not contain scripts: " .. name)
    end
    local model = source:Clone() :: Model
    model.Name = "ART_" .. slot
    model:SetAttribute("SourceArt", name)
    CollectionService:AddTag(model, "MountedArt")
    return model
end

function Art.mount(slot: string, parent: Instance, frame: CFrame, colliders: {BasePart}): Model?
    local model = Art.clone(slot)
    if not model then return nil end
    for _, object in model:GetDescendants() do
        if object:IsA("BasePart") then
            object.Anchored, object.CanCollide, object.CanQuery, object.CanTouch = true, false, false, false
        end
    end
    model:PivotTo(frame)
    model.Parent = parent
    for _, collider in colliders do collider.Transparency = 1 end
    return model
end

function Art.weapon(anchoredRoot: boolean): Model
    local model = Art.clone("Revolver")
    if model then model:ScaleTo(model:GetScale() * Assets.RevolverScale) end
    if not model then
        model = Instance.new("Model")
        model.Name = "PLACEHOLDER_RevolverVisual"
        CollectionService:AddTag(model, "NeedsArt")
        for _, shape in Assets.Revolver do
            local piece = Instance.new("Part")
            piece.Name, piece.Size, piece.CFrame = shape.Name, shape.Size, shape.Offset
            piece.Color = Assets.Grey
            piece.TopSurface, piece.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
            CollectionService:AddTag(piece, "NeedsArt")
            piece.Parent = model
        end
    end
    local handle = model:FindFirstChild("Handle", true)
    if not handle or not handle:IsA("BasePart") then
        model:Destroy()
        error("Revolver art needs a BasePart named Handle")
    end
    model.PrimaryPart = handle
    local connected: {[BasePart]: boolean} = {}
    for _, object in model:GetDescendants() do
        if object:IsA("JointInstance") and object.Part1 then connected[object.Part1] = true
        elseif object:IsA("WeldConstraint") and object.Part1 then connected[object.Part1] = true end
    end
    for _, object in model:GetDescendants() do
        if object:IsA("BasePart") then
            object.Anchored = object == handle and anchoredRoot
            object.CanCollide, object.CanQuery, object.CanTouch, object.Massless, object.CastShadow = false, false, false, true, not anchoredRoot
            if object ~= handle and not connected[object] then
                local weld = Instance.new("WeldConstraint")
                weld.Part0, weld.Part1, weld.Parent = handle, object, handle
            end
        end
    end
    model:PivotTo(CFrame.new())
    return model
end

return Art
