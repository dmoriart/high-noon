--!strict
-- Run as a server Script with the temporary client driver and short Studio-only config.
return function()
    local Players = game:GetService("Players")
    local shared = game:GetService("ReplicatedStorage").HighNoon
    local Config = require(shared.Config)
    local Combat = require(game.ServerScriptService.HighNoon.Combat)
    assert(game:GetService("RunService"):IsStudio(), "Studio only")
    assert(Config.ScoreToWin == 1 and Config.MatchSeconds == 12 and Config.IntermissionSeconds == 3, "Use the test config")
    local checks = 0
    local function check(condition: boolean, name: string)
        assert(condition, name)
        checks += 1
        print("[HighNoon MATCH PASS]", name)
    end
    local function awaitCondition(predicate: () -> boolean, seconds: number)
        local deadline = os.clock() + seconds
        repeat task.wait(0.1) until predicate() or os.clock() >= deadline
        assert(predicate(), "Timed out waiting for match condition")
    end
    awaitCondition(function() return #Players:GetPlayers() == 2 and shared:GetAttribute("Phase") == "Shootout" end, 20)
    local players = Players:GetPlayers()
    local shooter, victim = players[1], players[2]
    awaitCondition(function()
        return shooter.Character ~= nil and victim.Character ~= nil and shooter:GetAttribute("Ammo") == Config.Magazine
            and shooter.Character:FindFirstChildOfClass("Tool") ~= nil and victim.Character:FindFirstChildOfClass("Tool") ~= nil
    end, 8)
    task.wait(1)
    local a, v = shooter.Character, victim.Character
    a.HumanoidRootPart.Anchored, v.HumanoidRootPart.Anchored = true, true
    a:PivotTo(CFrame.new(0, 5, -55))
    v:PivotTo(CFrame.new(0, 5, -35))
    for _, character in {a, v} do
        character:SetAttribute("ProtectedUntil", 0)
        local shield = character:FindFirstChildOfClass("ForceField")
        if shield then shield:Destroy() end
    end
    v.Humanoid.Health = 1
    local firstMatch = shared:GetAttribute("MatchId")
    shared:SetAttribute("TestShooter", shooter.Name)
    shared:SetAttribute("TestTarget", victim.Name)
    shared:SetAttribute("TestShotSequence", 1)
    awaitCondition(function() return shared:GetAttribute("Phase") == "Intermission" end, 4)
    check(shooter.leaderstats.Score.Value == 1 and v.Humanoid.Health <= 0, "real client remote delivers lethal shot")
    check(string.find(shared:GetAttribute("Result"), "wins") ~= nil, "score limit produces winner")
    check(Combat.request(shooter, "Fire", 20000, a.Head.Position, Vector3.zAxis) == "inactive", "combat stops at match end")
    a.HumanoidRootPart.Anchored, v.HumanoidRootPart.Anchored = false, false
    awaitCondition(function() return shared:GetAttribute("Phase") == "Shootout" and shared:GetAttribute("MatchId") == firstMatch + 1 end, 8)
    awaitCondition(function() return shooter.Character ~= a and shooter:GetAttribute("Ammo") == Config.Magazine end, 5)
    check(shooter.leaderstats.Score.Value == 0 and victim.leaderstats.Score.Value == 0, "replay resets scores")
    check(shooter.Character.Humanoid.Health == Config.MaxHealth, "replay resets health and ammo")
    awaitCondition(function() return shared:GetAttribute("Phase") == "Intermission" end, 16)
    check(string.find(shared:GetAttribute("Result"), "time limit") ~= nil, "timer ends shootout")
    check(string.find(shared:GetAttribute("Result"), "No winner") ~= nil, "zero score round has no false winner")
    awaitCondition(function() return shared:GetAttribute("Phase") == "Shootout" end, 8)
    shared:SetAttribute("TestLeave", victim.Name)
    awaitCondition(function() return #Players:GetPlayers() == 1 end, 5)
    awaitCondition(function() return shared:GetAttribute("Phase") == "Intermission" end, 3)
    check(string.find(shared:GetAttribute("Result"), "not enough players") ~= nil, "leaving player ends active match")
    awaitCondition(function() return shared:GetAttribute("Phase") == "Waiting" end, 6)
    check(shared:GetAttribute("Seconds") == 0, "one remaining player returns to waiting")
    print("[HighNoon] Match lifecycle checks passed:", checks)
    return checks
end
