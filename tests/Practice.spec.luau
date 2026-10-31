--!strict
-- Run from a normal Studio server Script while Waiting. Two clients also check harmless PvP.
return function(): number
    local Players = game:GetService("Players")
    local shared = game.ReplicatedStorage.HighNoon
    local Config = require(shared.Config)
    local Assets = require(game.ReplicatedStorage.Config.AssetConfig)
    local Combat = require(game.ServerScriptService.HighNoon.Combat)
    assert(game:GetService("RunService"):IsStudio() and shared:GetAttribute("Phase") == "Waiting", "Studio Waiting only")
    local player = Players:GetPlayers()[1]
    local character = assert(player.Character)
    local root = character.HumanoidRootPart :: BasePart
    root.Anchored = true
    character:PivotTo(Assets.Practice.Spawn)
    Combat.reset(player, character)
    local id, checks = 0, 0
    local function check(ok: boolean, name: string)
        assert(ok, name)
        checks += 1
        print("[HighNoon PRACTICE PASS]", name)
    end
    local function fire(at: Vector3): string
        task.wait(Config.FireInterval + Config.RequestInterval)
        id += 1
        return Combat.request(player, "Fire", id, character.Head.Position, (at - character.Head.Position).Unit)
    end
    local target = Assets.Practice.Targets[2]
    local before = player:GetAttribute("PracticeHits") or 0
    check(fire(target) == "fired", "waiting accepts valid fire")
    check(player:GetAttribute("PracticeHits") == before + 1, "ray hit counts once")
    check(player:GetAttribute("Ammo") == Config.Magazine - 1, "practice consumes ammo")
    check(player.leaderstats.Score.Value == 0, "target gives no match score")
    check(Combat.request(player, "Fire", id + 1, character.Head.Position, Vector3.yAxis) == "rate limited", "burst rejected")
    task.wait(Config.RequestInterval + 0.02)
    check(Combat.request(player, "Fire", id, character.Head.Position, Vector3.yAxis) == "invalid requestId", "duplicate rejected")
    task.wait(Config.RequestInterval + 0.02)
    id += 1
    check(Combat.request(player, "Fire", id, character.Head.Position + Vector3.new(20, 0, 0), Vector3.yAxis) == "invalid aim", "spoofed origin rejected")
    local hits = player:GetAttribute("PracticeHits")
    check(fire(character.Head.Position + Vector3.yAxis * 20) == "fired" and player:GetAttribute("PracticeHits") == hits, "miss does not count")
    local wall = Instance.new("Part")
    wall.Size, wall.Position, wall.Anchored = Vector3.new(12, 12, 1), Vector3.new(50, 5, -58), true
    wall.Parent = workspace
    check(fire(target) == "fired" and player:GetAttribute("PracticeHits") == hits, "cover blocks target")
    wall:Destroy()
    while (player:GetAttribute("Ammo") or 0) > 0 do assert(fire(target) == "fired") end
    check(fire(target) == "empty", "empty cylinder rejects shot")
    task.wait(Config.RequestInterval + 0.02)
    id += 1
    check(Combat.request(player, "Reload", id) == "reload started", "waiting reload starts")
    task.wait(Config.ReloadSeconds + 0.1)
    check(player:GetAttribute("Ammo") == Config.Magazine and player:GetAttribute("Reloading") == false, "waiting reload completes")
    local victim = Players:GetPlayers()[2]
    if victim and victim.Character then
        local other = victim.Character
        other.HumanoidRootPart.Anchored = true
        other:PivotTo(CFrame.new(50, 5, -55))
        other:SetAttribute("ProtectedUntil", 0)
        local shield = other:FindFirstChildOfClass("ForceField")
        if shield then shield:Destroy() end
        local health = other.Humanoid.Health
        check(fire(other.HumanoidRootPart.Position) == "fired" and other.Humanoid.Health >= health, "practice cannot damage another player")
        other.HumanoidRootPart.Anchored = false
    end
    Combat.setActive(false)
    check(Combat.request(player, "Fire", id + 1, character.Head.Position, Vector3.yAxis) == "inactive", "inactive phases reject fire")
    Combat.setPractice(true)
    Combat.setActive(true)
    Combat.reset(player, character)
    root.Anchored = false
    print("[HighNoon] Practice checks passed:", checks)
    return checks
end
