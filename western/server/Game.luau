--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AnalyticsService = game:GetService("AnalyticsService")
local Config = require(ReplicatedStorage.HighNoon.Config)
local Arena = require(script.Parent.Arena)
local Combat = require(script.Parent.Combat)
local Practice = require(script.Parent.Practice)
local Assets = require(ReplicatedStorage.Config.AssetConfig)
local Game = {}
local matchId = 0
local phase = "Waiting"
local deadline = 0
local scores: {[Player]: number} = {}
local joined: {[Player]: boolean} = {}
local practiceSteps: {[Player]: {[string]: boolean}} = {}
local steps: {[Player]: {[string]: boolean}} = {}
local matchesJoined: {[Player]: number} = {}
local spawns: {SpawnLocation} = {}
local spawnIndex = 0
local pendingSpawn: {[Player]: boolean} = {}

local function analytics(player: Player, name: string)
    if RunService:IsStudio() then
        print("[HighNoon analytics]", name, player.Name, matchId)
        return
    end
    local ok, reason = pcall(function()
        AnalyticsService:LogCustomEvent(player, name, 1)
    end)
    if not ok then warn("High Noon analytics failed:", name, reason) end
end

local function setPhase(value: string)
    phase = value
    ReplicatedStorage.HighNoon:SetAttribute("Phase", phase)
    Combat.setActive(false)
    Combat.setPractice(phase == "Waiting")
    Practice.setEnabled(phase == "Waiting")
    for i, spawn in spawns do
        spawn.CFrame = if phase == "Waiting" then Assets.Practice.Spawn - Vector3.new(0, 4, 0) else CFrame.new(Assets.SpawnPositions[i])
    end
    if phase == "Waiting" then
        for _, player in Players:GetPlayers() do
            if player.Character then player.Character:PivotTo(Assets.Practice.Spawn) end
        end
    end
    Combat.setActive(phase == "Shootout" or phase == "Waiting")
end

local function joinMatch(player: Player)
    if joined[player] then return end
    joined[player] = true
    matchesJoined[player] = (matchesJoined[player] or 0) + 1
    analytics(player, "WesternMatchJoined")
    if matchesJoined[player] == 2 then analytics(player, "WesternSecondMatchJoined") end
end

local function recordAction(player: Player, name: string)
    local records = if phase == "Waiting" then practiceSteps else steps
    if phase ~= "Waiting" and not joined[player] then return end
    local recorded = records[player]
    if not recorded then recorded = {}; records[player] = recorded end
    if recorded[name] then return end
    recorded[name] = true
    task.defer(analytics, player, name)
end

local function score(player: Player): IntValue
    return player:FindFirstChild("leaderstats"):FindFirstChild("Score") :: IntValue
end

local function finish(reason: string)
    if phase ~= "Shootout" then return end
    setPhase("Intermission")
    deadline = os.clock() + Config.IntermissionSeconds
    local high = 0
    local winners: {string} = {}
    for player, value in scores do
        if player.Parent == Players then
            if value > high then high, winners = value, {player.DisplayName}
            elseif value == high and value > 0 then table.insert(winners, player.DisplayName) end
            if joined[player] then analytics(player, "WesternMatchCompleted") end
        end
    end
    local result = if #winners == 0 then "No winner" elseif #winners == 1 then winners[1] .. " wins" else "Draw"
    ReplicatedStorage.HighNoon:SetAttribute("Result", result .. " • " .. reason)
    print("[HighNoon] Match ended:", reason, result)
end

local function kill(attacker: Player, victim: Player)
    if phase ~= "Shootout" or attacker == victim or scores[attacker] == nil then return end
    scores[attacker] += 1
    score(attacker).Value = scores[attacker]
    if scores[attacker] >= Config.ScoreToWin then finish("score limit") end
end

local function spawnCharacter(player: Player, character: Model)
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    character:WaitForChild("HumanoidRootPart")
    if player.Character ~= character then return end
    spawnIndex = spawnIndex % #spawns + 1
    character:PivotTo(if phase == "Waiting" then Assets.Practice.Spawn else spawns[spawnIndex].CFrame + Vector3.new(0, 4, 0))
    humanoid.MaxHealth, humanoid.Health = Config.MaxHealth, Config.MaxHealth
    humanoid.WalkSpeed, humanoid.UseJumpPower, humanoid.JumpPower = Config.WalkSpeed, true, Config.JumpPower
    character:SetAttribute("ProtectedUntil", os.clock() + Config.SpawnProtectionSeconds)
    local shield = Instance.new("ForceField")
    shield.Parent = character
    task.delay(Config.SpawnProtectionSeconds, function() shield:Destroy() end)
    local backpack = player:WaitForChild("Backpack")
    for _, item in backpack:GetChildren() do
        if item:IsA("Tool") and item:GetAttribute("HighNoonWeapon") then item:Destroy() end
    end
    local tool = Arena.revolver()
    tool.Parent = backpack
    Combat.reset(player, character)
    humanoid:EquipTool(tool)
    humanoid.Died:Once(function()
        local deaths = player:FindFirstChild("leaderstats"):FindFirstChild("Deaths") :: IntValue
        deaths.Value += 1
    end)
    character:SetAttribute("SpawnMatchId", matchId)
    if phase == "Waiting" then recordAction(player, "WesternPracticeEntered") end
end

local function addPlayer(player: Player)
    if scores[player] ~= nil then return end
    scores[player] = 0
    player:SetAttribute("PracticeHits", 0)
    local stats = Instance.new("Folder")
    stats.Name, stats.Parent = "leaderstats", player
    for _, name in {"Score", "Deaths"} do
        local value = Instance.new("IntValue")
        value.Name, value.Parent = name, stats
    end
    player.CharacterAdded:Connect(function(character) spawnCharacter(player, character) end)
    if player.Character then task.spawn(spawnCharacter, player, player.Character) end
    if phase == "Shootout" then joinMatch(player) end
end

function Game.update()
    local now = os.clock()
    local count = #Players:GetPlayers()
    for _, player in Players:GetPlayers() do
        local character = player.Character
        local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
        local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
        if root and root:IsA("BasePart") and humanoid and root.Position.Y < Config.KillPlane then humanoid.Health = 0 end
    end
    if phase == "Waiting" and count >= Config.MinPlayers then
        matchId += 1
        joined = {}
        steps = {}
        pendingSpawn = {}
        local preparingMatch = matchId
        ReplicatedStorage.HighNoon:SetAttribute("MatchId", matchId)
        ReplicatedStorage.HighNoon:SetAttribute("Result", "")
        deadline = now + Config.SpawnTimeoutSeconds
        setPhase("Preparing")
        for _, player in Players:GetPlayers() do
            scores[player] = 0
            score(player).Value = 0
            local deaths = player.leaderstats.Deaths :: IntValue
            deaths.Value = 0
            -- Fresh characters reset health, ammo, position and outstanding reloads.
            pendingSpawn[player] = true
            task.spawn(function()
                if player.Parent ~= Players then return end
                local ok, reason = pcall(function() player:LoadCharacterAsync() end)
                if not ok then warn("High Noon respawn failed:", player.Name, reason) end
                if ok and matchId == preparingMatch then pendingSpawn[player] = nil end
            end)
        end
    elseif phase == "Preparing" then
        local ready = true
        for _, player in Players:GetPlayers() do
            if pendingSpawn[player] or not player.Character or player.Character:GetAttribute("SpawnMatchId") ~= matchId then ready = false end
        end
        if count < Config.MinPlayers then
            setPhase("Waiting")
        elseif ready then
            for _, player in Players:GetPlayers() do joinMatch(player) end
            deadline = now + Config.MatchSeconds
            setPhase("Shootout")
        elseif now >= deadline then
            warn("High Noon could not prepare all characters; retrying from waiting")
            setPhase("Waiting")
        end
    elseif phase == "Shootout" then
        if count < Config.MinPlayers then finish("not enough players")
        elseif now >= deadline then finish("time limit") end
    elseif phase == "Intermission" and now >= deadline then
        setPhase("Waiting")
        for _, player in Players:GetPlayers() do
            recordAction(player, "WesternPracticeEntered")
        end
    end
    ReplicatedStorage.HighNoon:SetAttribute("Seconds", if phase == "Waiting" then 0 else math.max(0, math.ceil(deadline - now)))
end

function Game.start()
    Players.RespawnTime = Config.RespawnSeconds
    spawns = Arena.build()
    local remote = Instance.new("RemoteEvent")
    remote.Name, remote.Parent = "Combat", ReplicatedStorage.HighNoon
    Combat.start(remote, kill, recordAction)
    setPhase("Waiting")
    ReplicatedStorage.HighNoon:SetAttribute("Result", "")
    Players.PlayerAdded:Connect(addPlayer)
    Players.PlayerRemoving:Connect(function(player)
        scores[player], joined[player], matchesJoined[player], pendingSpawn[player] = nil, nil, nil, nil
        steps[player], practiceSteps[player] = nil, nil
        Combat.remove(player)
    end)
    for _, player in Players:GetPlayers() do addPlayer(player) end
    print("[HighNoon] Ready — frontier shootout")
    task.spawn(function()
        while true do
            Game.update()
            task.wait(1)
        end
    end)
end

return Game
