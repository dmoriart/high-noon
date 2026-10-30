--!strict
-- Synthetic fixtures only: real artist-owned source models are never changed.
return function(): number
    assert(game:GetService("RunService"):IsStudio(), "Studio only")
    local shared = game.ReplicatedStorage.HighNoon
    local Art = require(shared.Art)
    local Assets = require(game.ReplicatedStorage.Config.AssetConfig)
    local folder = game.ReplicatedStorage:WaitForChild("Art")
    local savedWeapon, savedCrate = Assets.Models.Revolver, Assets.Models.Crate
    local fixtures: {Instance} = {}
    local checks = 0
    local function check(condition: boolean, name: string)
        assert(condition, name)
        checks += 1
        print("[HighNoon ART PASS]", name)
    end
    local function fixture(name: string): Model
        assert(not folder:FindFirstChild(name), "Test fixture name already in use")
        local model = Instance.new("Model")
        model.Name, model.Parent = name, folder
        table.insert(fixtures, model)
        return model
    end
    local ok, reason = pcall(function()
        Assets.Models.Revolver = ""
        local fallback = Art.weapon(true)
        check(fallback.PrimaryPart ~= nil and fallback.PrimaryPart.Anchored, "blank slot makes an anchored camera greybox")
        fallback:Destroy()
        local source = fixture("QA_Weapon")
        local handle = Instance.new("Part")
        handle.Name, handle.Position, handle.Parent = "Handle", Vector3.new(100, 20, 0), source
        local cylinder = Instance.new("Part")
        cylinder.Name, cylinder.Position, cylinder.Parent = "Cylinder", Vector3.new(100, 21, 0), source
        local motor = Instance.new("Motor6D")
        motor.Name, motor.Part0, motor.Part1, motor.Parent = "CylinderJoint", handle, cylinder, handle
        source.PrimaryPart = handle
        local originalPosition, originalCount = handle.Position, #source:GetDescendants()
        Assets.Models.Revolver = source.Name
        local camera = Art.weapon(true)
        local cameraCylinder = camera:FindFirstChild("Cylinder") :: BasePart
        check(camera.PrimaryPart.Anchored and not cameraCylinder.Anchored, "camera anchors only the rig root")
        check(camera.PrimaryPart:FindFirstChild("CylinderJoint") ~= nil, "authored animation joint is preserved")
        local world = Art.weapon(false)
        check(not world.PrimaryPart.Anchored and not world.PrimaryPart.CanQuery, "world visual is movable and cannot absorb shots")
        check(handle.Position == originalPosition and not handle.Anchored and #source:GetDescendants() == originalCount, "mounting leaves source art untouched")
        camera:Destroy(); world:Destroy()
        local crate = fixture("QA_Crate")
        local body = Instance.new("Part")
        body.Size, body.Position, body.PivotOffset = Vector3.new(6, 4, 5), Vector3.new(100, 2, 0), CFrame.new(0, -2, 0)
        body.Parent, crate.PrimaryPart = crate, body
        Assets.Models.Crate = crate.Name
        local container = Instance.new("Folder")
        container.Name, container.Parent = "QA_ArtMount", workspace
        table.insert(fixtures, container)
        local collider = Instance.new("Part")
        collider.Size, collider.Position, collider.Anchored, collider.Parent = body.Size, Vector3.new(20, 2, 20), true, container
        local target = CFrame.new(20, 0, 20)
        local mounted = Art.mount("Crate", container, target, {collider})
        check(mounted ~= nil and (mounted:GetPivot().Position - target.Position).Magnitude < 0.01, "static art uses its authored base pivot")
        check(collider.Transparency == 1 and collider.CanCollide and collider.CanQuery, "cosmetic swap preserves tested collision")
        check(not mounted.PrimaryPart.CanCollide and not mounted.PrimaryPart.CanQuery, "cosmetic meshes do not change collision or raycasts")
        Assets.Models.Crate = "QA_Missing"
        check(not pcall(function() Art.clone("Crate") end), "configured missing models fail clearly")
        local scriptObject = Instance.new("Script")
        scriptObject.Enabled, scriptObject.Parent = false, source
        check(not pcall(function() Art.clone("Revolver") end), "embedded scripts are rejected")
        scriptObject:Destroy()
        local bad = fixture("QA_NoHandle")
        local piece = Instance.new("Part"); piece.Parent = bad
        Assets.Models.Revolver = bad.Name
        check(not pcall(function() Art.weapon(true) end), "weapon without Handle is rejected")
    end)
    Assets.Models.Revolver, Assets.Models.Crate = savedWeapon, savedCrate
    for _, object in fixtures do object:Destroy() end
    assert(ok, reason)
    print("[HighNoon] Art integration checks passed:", checks)
    return checks
end
