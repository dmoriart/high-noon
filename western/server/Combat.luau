--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.HighNoon.Config)
local Ballistics = require(ReplicatedStorage.HighNoon.Ballistics)
local Combat = {}

type State = {character: Model, ammo: number, reloadUntil: number, lastShot: number, lastRequest: number, lastId: number, reloadId: number, reloadConnection: RBXScriptConnection?}
local states: {[Player]: State} = {}
local remote: RemoteEvent
local onKill: (Player, Player) -> ()
local onAction: (Player, string) -> ()
local active = false

local function publish(player: Player, state: State)
    player:SetAttribute("Ammo", state.ammo)
    player:SetAttribute("Reloading", state.reloadUntil > 0)
end

local function clearReload(state: State)
    state.reloadUntil, state.reloadId = 0, 0
    if state.reloadConnection then
        state.reloadConnection:Disconnect()
        state.reloadConnection = nil
    end
end

function Combat.reset(player: Player, character: Model)
    if states[player] then clearReload(states[player]) end
    states[player] = {character = character, ammo = Config.Magazine, reloadUntil = 0, lastShot = -math.huge, lastRequest = -math.huge, lastId = 0, reloadId = 0, reloadConnection = nil}
    publish(player, states[player])
end

function Combat.setActive(value: boolean)
    active = value
    if not value then
        for player, state in states do
            clearReload(state)
            publish(player, state)
        end
    end
end

function Combat.remove(player: Player)
    if states[player] then clearReload(states[player]) end
    states[player] = nil
end

function Combat.request(player: Player, action: any, requestId: any, origin: any, direction: any): string
    local state = states[player]
    if not state or not active then return "inactive" end
    local now = os.clock()
    if now - state.lastRequest < Config.RequestInterval then return "rate limited" end
    state.lastRequest = now
    if action ~= "Fire" and action ~= "Reload" then return "invalid action" end
    if typeof(requestId) ~= "number" or requestId ~= requestId or requestId % 1 ~= 0
        or requestId <= state.lastId or requestId > Config.MaxRequestId then return "invalid requestId" end
    state.lastId = requestId
    local character = player.Character
    if not character or character ~= state.character then return "stale character" end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    local tool = character:FindFirstChildOfClass("Tool")
    if not humanoid or humanoid.Health <= 0 or not head or not head:IsA("BasePart")
        or not tool or not tool:GetAttribute("HighNoonWeapon") then return "not equipped or alive" end
    if state.reloadUntil > 0 then return "reloading" end
    if action == "Reload" then
        if state.ammo >= Config.Magazine then return "full" end
        state.reloadUntil, state.reloadId = now + Config.ReloadSeconds, requestId
        state.reloadConnection = tool.Unequipped:Connect(function()
            if states[player] ~= state or state.reloadId ~= requestId then return end
            clearReload(state)
            publish(player, state)
            remote:FireClient(player, "ReloadCancelled")
        end)
        publish(player, state)
        remote:FireClient(player, "Reload", workspace:GetServerTimeNow() + Config.ReloadSeconds)
        task.delay(Config.ReloadSeconds, function()
            if states[player] ~= state or state.reloadId ~= requestId then return end
            clearReload(state)
            if not active or player.Character ~= character or humanoid.Health <= 0 or tool.Parent ~= character then
                publish(player, state)
                return
            end
            state.ammo = Config.Magazine
            publish(player, state)
            onAction(player, "WesternFirstReload")
        end)
        return "reload started"
    end
    if not Ballistics.validVector(origin) or not Ballistics.validVector(direction)
        or math.abs(direction.Magnitude - 1) > 0.01 or (origin - head.Position).Magnitude > Config.MaxOriginOffset then
        return "invalid aim"
    end
    if state.ammo <= 0 then return "empty" end
    if now - state.lastShot < Config.FireInterval then return "fire cooldown" end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    -- The camera cannot move the shot origin through nearby cover.
    if workspace:Raycast(head.Position, origin - head.Position, params) then return "origin obstructed" end
    state.lastShot, state.ammo = now, state.ammo - 1
    publish(player, state)
    local shield = character:FindFirstChildOfClass("ForceField")
    if shield then shield:Destroy() end
    character:SetAttribute("ProtectedUntil", 0)
    local result = workspace:Raycast(origin, direction * Config.Range, params)
    local endPosition = if result then result.Position else origin + direction * Config.Range
    local hit = false
    if result then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        local victim = if model then Players:GetPlayerFromCharacter(model) else nil
        local target = if model then model:FindFirstChildOfClass("Humanoid") else nil
        if target and model and target.Health > 0 and not model:FindFirstChildOfClass("ForceField")
            and (model:GetAttribute("ProtectedUntil") or 0) <= now then
            hit = true
            local damage = Ballistics.damage(result.Instance.Name, result.Distance)
            local killed = target.Health <= damage
            target:TakeDamage(damage)
            if killed and target.Health <= 0 and victim then onKill(player, victim) end
        end
    end
    remote:FireAllClients("Shot", player, head.Position, endPosition)
    remote:FireClient(player, "Fired", hit)
    onAction(player, "WesternFirstShot")
    return "fired"
end

function Combat.start(event: RemoteEvent, killCallback: (Player, Player) -> (), actionCallback: (Player, string) -> ())
    remote, onKill, onAction = event, killCallback, actionCallback
    remote.OnServerEvent:Connect(function(player: Player, action: any, requestId: any, origin: any, direction: any)
        Combat.request(player, action, requestId, origin, direction)
    end)
end

return Combat
