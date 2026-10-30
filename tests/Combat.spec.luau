--!strict
-- Run this module on the server in a two-player Studio shootout.
return function()
    local Players = game:GetService("Players")
    local Shared = game:GetService("ReplicatedStorage").HighNoon
    local Combat = require(game.ServerScriptService.HighNoon.Combat)
    local Ballistics = require(Shared.Ballistics)
    local Config = require(Shared.Config)
    assert(game:GetService("RunService"):IsStudio(), "Studio only")
    assert(Shared:GetAttribute("Phase") == "Shootout", "Start a shootout first")
    local players = Players:GetPlayers()
    assert(#players == 2, "Exactly two test players required")
    local attacker, victim = players[1], players[2]
    local a, v = assert(attacker.Character), assert(victim.Character)
    local ah = a:FindFirstChildOfClass("Humanoid") :: Humanoid
    local vh = v:FindFirstChildOfClass("Humanoid") :: Humanoid
    local ar, vr = a.HumanoidRootPart :: BasePart, v.HumanoidRootPart :: BasePart
    ar.Anchored, vr.Anchored = true, true
    a:PivotTo(CFrame.new(0, 5, -55))
    v:PivotTo(CFrame.new(0, 5, -35))
    for _, character in {a, v} do
        character:SetAttribute("ProtectedUntil", 0)
        local shield = character:FindFirstChildOfClass("ForceField")
        if shield then shield:Destroy() end
    end
    ah.Health, vh.Health = Config.MaxHealth, Config.MaxHealth
    Combat.reset(attacker, a)
    local tool = a:FindFirstChildOfClass("Tool") :: Tool
    assert(tool and tool.Name == "Revolver", "Revolver equipped")
    local checks = 0
    local function check(condition: boolean, name: string)
        assert(condition, name)
        checks += 1
        print("[HighNoon PASS]", name)
    end
    local id = 0
    local function request(action: any, origin: any?, direction: any?): string
        task.wait(Config.RequestInterval + 0.02)
        id += 1
        return Combat.request(attacker, action, id, origin or a.Head.Position, direction or (vr.Position - a.Head.Position).Unit)
    end
    check(Ballistics.damage("Head", 20) == 68 and Ballistics.damage("Torso", 20) == 34, "body and head damage")
    check(Ballistics.damage("Torso", 350) == Config.MinDamage, "distance falloff floor")
    check(not Ballistics.validVector(Vector3.new(0/0, 0, 0)), "NaN rejected")
    check(request("Unknown") == "invalid action", "unknown action rejected")
    check(request("Fire", a.Head.Position + Vector3.new(50, 0, 0)) == "invalid aim", "spoofed origin rejected")
    check(request("Fire", a.Head.Position, Vector3.new(math.huge, 0, 0)) == "invalid aim", "infinite direction rejected")
    local before = vh.Health
    check(request("Fire") == "fired" and vh.Health == before - Config.Damage, "server ray damages opponent")
    check(Combat.request(attacker, "Fire", id + 1, a.Head.Position, Vector3.zAxis) == "rate limited", "request burst rejected")
    task.wait(Config.RequestInterval + 0.02)
    check(Combat.request(attacker, "Fire", id, a.Head.Position, Vector3.zAxis) == "invalid requestId", "duplicate request rejected")
    check(request("Fire") == "fire cooldown", "weapon fire rate enforced")
    check(request("Reload") == "reload started", "reload begins")
    check(request("Fire") == "reloading", "cannot shoot while reloading")
    task.wait(Config.ReloadSeconds + 0.1)
    check(attacker:GetAttribute("Ammo") == Config.Magazine and not attacker:GetAttribute("Reloading"), "reload refills cylinder")
    local wall = Instance.new("Part")
    wall.Name, wall.Anchored, wall.Size, wall.Position = "TEST_Wall", true, Vector3.new(12, 12, 1), Vector3.new(0, 6, -45)
    wall.Parent = workspace
    before = vh.Health
    check(request("Fire") == "fired" and vh.Health >= before, "cover blocks damage")
    wall:Destroy()
    task.wait(Config.FireInterval)
    local shield = Instance.new("ForceField")
    shield.Parent = v
    before = vh.Health
    check(request("Fire") == "fired" and vh.Health >= before, "spawn shield blocks damage")
    shield:Destroy()
    task.wait(Config.FireInterval)
    tool.Parent = attacker.Backpack
    check(request("Fire") == "not equipped or alive", "unequipped weapon rejected")
    ah:EquipTool(tool)
    local scoreBefore = attacker.leaderstats.Score.Value
    local deathsBefore = victim.leaderstats.Deaths.Value
    vh.Health = 1
    local lethalResult = request("Fire")
    task.wait(0.1)
    check(lethalResult == "fired" and vh.Health <= 0, "lethal shot: " .. lethalResult .. " health=" .. vh.Health)
    task.wait(0.1) -- Humanoid.Died dispatches after TakeDamage returns.
    check(attacker.leaderstats.Score.Value == scoreBefore + 1 and victim.leaderstats.Deaths.Value == deathsBefore + 1, "one score and one death awarded")
    ar.Anchored, vr.Anchored = false, false
    task.wait(Config.RespawnSeconds + 2)
    check(victim.Character ~= v and victim.Character.Humanoid.Health == Config.MaxHealth, "dead player respawns")
    check(victim:GetAttribute("Ammo") == Config.Magazine and victim.Character:FindFirstChildOfClass("Tool") ~= nil, "respawn restores revolver and ammo")
    print("[HighNoon] Combat integration checks passed:", checks)
    return checks
end
