--!strict
-- Run in a Studio server after the frontier arena has been built.
return function(): {parts: number, spawns: number}
    assert(game:GetService("RunService"):IsStudio(), "Studio only")
    local arena = assert(workspace:FindFirstChild("HighNoonArena"), "Missing arena")
    local assets = require(game.ReplicatedStorage.Config.AssetConfig)
    local tags = game:GetService("CollectionService")
    local count = 0
    for _, object in arena:GetDescendants() do
        if object:IsA("BasePart") then
            count += 1
            assert(object.Anchored, "Loose scenery: " .. object.Name)
            assert(tags:HasTag(object, "NeedsArt"), "Untagged scenery: " .. object.Name)
            assert(string.sub(object.Name, 1, 12) == "PLACEHOLDER_", "Unlabelled scenery: " .. object.Name)
        end
    end
    assert(count < 400, "Arena exceeds the part budget")
    local rays = RaycastParams.new()
    rays.FilterType, rays.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {arena}
    assert(not workspace:Raycast(Vector3.new(0, 6, -60), Vector3.new(0, 0, 120), rays), "Main firing lane blocked")
    local cover = workspace:Raycast(Vector3.new(0, 2, -15), Vector3.new(-15, 0, 0), rays)
    assert(cover and string.find(cover.Instance.Name, "Crate"), "Original crate no longer blocks shots")
    local ground = workspace:Raycast(Vector3.new(0, 5, 0), Vector3.new(0, -10, 0), rays)
    assert(ground and ground.Instance.Name == "PLACEHOLDER_FrontierGround", "Ground missing")
    local boundary = workspace:Raycast(Vector3.new(0, 6, 65), Vector3.new(0, 0, 20), rays)
    assert(boundary and boundary.Instance.CanCollide, "Fenced perimeter no longer blocks escape/shots")
    local overlap = OverlapParams.new()
    overlap.FilterType, overlap.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {arena}
    local function clear(center: CFrame, size: Vector3, label: string)
        for _, object in workspace:GetPartBoundsInBox(center, size, overlap) do
            assert(not object.CanCollide, label .. " blocked by " .. object:GetFullName())
        end
    end
    local spawns = 0
    for _, object in arena:GetChildren() do
        if object:IsA("SpawnLocation") then
            spawns += 1
            clear(object.CFrame + Vector3.new(0, 4, 0), Vector3.new(4, 6, 4), object.Name)
        end
    end
    assert(spawns == #assets.SpawnPositions, "Spawn count changed")
    for _, b in assets.Buildings do
        local facing = if b.Position.X < 0 then 1 else -1
        clear(CFrame.new(b.Position + Vector3.new(facing * b.Width / 2, 3.5, 0)), Vector3.new(3, 6, 5), b.Name .. " doorway")
    end
    local tones = 0
    for _, object in game:GetService("Lighting"):GetChildren() do
        if object.Name == "HighNoonWesternTone" then tones += 1 end
    end
    assert(tones == 1, "Western colour grading stacked or missing")
    print("[HighNoon ARENA PASS]", count, "parts;", spawns, "clear spawns; clear doors/lane; cover and bounds block shots")
    return {parts = count, spawns = spawns}
end
