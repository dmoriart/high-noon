--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Assets = require(ReplicatedStorage.Config.AssetConfig)
local Art = require(ReplicatedStorage.HighNoon.Art)
local Practice = {}
local targets: Model? = nil
local enabled = false

function Practice.build(parent: Instance): ()
    local model = Instance.new("Model")
    model.Name = "PLACEHOLDER_PracticeRange"
    CollectionService:AddTag(model, "NeedsArt")
    for i, position in Assets.Practice.Targets do
        local target = Instance.new("Part")
        target.Name = "PLACEHOLDER_PracticeTarget" .. i
        target.Size, target.Position = Assets.Practice.TargetSize, position
        target.Anchored, target.CanCollide, target.CanTouch = true, false, false
        target.Color, target.Material = Assets.Grey, Enum.Material.WoodPlanks
        target:SetAttribute("PracticeTarget", true)
        CollectionService:AddTag(target, "NeedsArt")
        target.Parent = model
        local visual = Art.mount("PracticeTarget", target, CFrame.new(position - Vector3.new(0, target.Size.Y / 2, 0)), {target})
        if not visual then
            local gui = Instance.new("SurfaceGui")
            gui.Face, gui.CanvasSize = Enum.NormalId.Back, Assets.Practice.TargetCanvas
            local label = Instance.new("TextLabel")
            label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
            label.Font, label.TextScaled = Enum.Font.Antique, true
            label.Text, label.TextColor3 = "◎\n" .. i, Color3.fromRGB(30, 30, 30)
            label.Parent, gui.Parent = gui, target
        end
    end
    targets, model.Parent = model, parent
end

function Practice.setEnabled(value: boolean): ()
    enabled = value
    if not targets then return end
    for _, object in targets:GetDescendants() do
        if object:IsA("BasePart") then
            if object:GetAttribute("VisibleTransparency") == nil then object:SetAttribute("VisibleTransparency", object.Transparency) end
            object.Transparency = if value then object:GetAttribute("VisibleTransparency") else 1
            object.CanQuery = value and object:GetAttribute("PracticeTarget") == true
        elseif object:IsA("SurfaceGui") then object.Enabled = value end
    end
end

function Practice.hit(object: Instance, player: Player): boolean
    if not enabled or not targets or not object:IsDescendantOf(targets) or object:GetAttribute("PracticeTarget") ~= true then return false end
    player:SetAttribute("PracticeHits", (player:GetAttribute("PracticeHits") or 0) + 1)
    return true
end

return Practice
