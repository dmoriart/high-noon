--!strict
-- Start with one client and add a second when PracticeTransitionStage becomes Reloading.
-- Requires the existing shortened Match.spec configuration and client driver.
return function(): number
    local Players = game:GetService("Players")
    local shared = game.ReplicatedStorage.HighNoon
    local Config = require(shared.Config)
    local Combat = require(game.ServerScriptService.HighNoon.Combat)
    local function awaitCondition(predicate: () -> boolean, seconds: number, name: string)
        local deadline = os.clock() + seconds
        repeat task.wait(0.1) until predicate() or os.clock() >= deadline
        assert(predicate(), "Timed out: " .. name)
    end
    awaitCondition(function()
        local p = Players:GetPlayers()[1]
        return #Players:GetPlayers() == 1 and p.Character ~= nil and p.Character:GetAttribute("SpawnMatchId") ~= nil
    end, 40, "first waiting player")
    assert(shared:GetAttribute("Phase") == "Waiting")
    local player = Players:GetPlayers()[1]
    local old = assert(player.Character)
    Combat.reset(player, old)
    assert(Combat.request(player, "Fire", 1, old.Head.Position, Vector3.yAxis) == "fired")
    task.wait(Config.RequestInterval + 0.02)
    assert(Combat.request(player, "Reload", 2) == "reload started")
    local arrivedDuringReload = false
    local arrival = Players.PlayerAdded:Once(function()
        arrivedDuringReload = player:GetAttribute("Reloading") == true
    end)
    shared:SetAttribute("PracticeTransitionStage", "Reloading")
    awaitCondition(function() return shared:GetAttribute("Phase") == "Shootout" end, 45, "second client and shootout")
    arrival:Disconnect()
    assert(arrivedDuringReload, "second client arrived after practice reload; use a longer Studio-only ReloadSeconds")
    assert(player.Character ~= old and player:GetAttribute("Ammo") == Config.Magazine and not player:GetAttribute("Reloading"), "practice state leaked")
    task.wait(0.1)
    assert(player:GetAttribute("Ammo") == Config.Magazine and not player:GetAttribute("Reloading"), "practice reload remained active in match")
    for _, object in workspace.HighNoonArena.PLACEHOLDER_PracticeRange:GetDescendants() do
        if object:IsA("BasePart") then assert(object.Transparency == 1 and not object.CanQuery, "range still active in match") end
    end
    print("[HighNoon PRACTICE PASS] fresh match, cancelled reload and disabled targets")
    return 3
end
