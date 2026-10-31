--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Art = require(ReplicatedStorage.HighNoon.Art)
local Presentation = require(script.Parent.Presentation)
local Assets = require(ReplicatedStorage.Config.AssetConfig)
local Config = require(ReplicatedStorage.HighNoon.Config)
local Controller = {}

function Controller.start()
    local player = Players.LocalPlayer
    local shared = ReplicatedStorage:WaitForChild("HighNoon")
    local remote = shared:WaitForChild("Combat") :: RemoteEvent
    local sequence = 0
    local lastShot = -math.huge
    local nextFire = 0
    local compact = false
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = "HighNoonHUD", false, false
    gui.Parent = player:WaitForChild("PlayerGui")
    local aim = Instance.new("ScreenGui")
    aim.Name, aim.ResetOnSpawn = "HighNoonAim", false
    aim.ScreenInsets = Enum.ScreenInsets.None
    aim.DisplayOrder = gui.DisplayOrder + 1
    aim.Parent = player.PlayerGui
    local hooks = Instance.new("BindableEvent")
    hooks.Name, hooks.Parent = "WeaponPresentation", gui

    local function label(name: string, size: UDim2, position: UDim2, text: string): TextLabel
        local object = Instance.new("TextLabel")
        object.Name, object.Size, object.Position = name, size, position
        object.BackgroundColor3 = Color3.fromRGB(28, 23, 20)
        object.BackgroundTransparency = 0.15
        object.TextColor3 = Color3.fromRGB(241, 220, 182)
        object.TextSize, object.Font = 18, Enum.Font.Antique
        object.Text, object.TextWrapped = text, true
        object.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius, corner.Parent = UDim.new(0, 4), object
        return object
    end
    local title = label("Title", UDim2.new(0.32, 0, 0, 36), UDim2.fromScale(0.34, 0), Config.Title)
    local status = label("Match", UDim2.new(0.8, 0, 0, 46), UDim2.new(0.1, 0, 0, 40), "Waiting for a second gunslinger")
    local crosshair = label("Crosshair", UDim2.fromOffset(24, 24), UDim2.new(0.5, -12, 0.5, -12), "+")
    crosshair.Parent = aim
    crosshair.BackgroundTransparency = 1
    local ammo = label("Ammo", UDim2.new(0.48, 0, 0, 44), UDim2.new(0.5, 0, 1, -52), "REVOLVER  6 / 6")
    local reloadBar = Instance.new("Frame")
    reloadBar.Name, reloadBar.Size, reloadBar.Position = "ReloadProgress", UDim2.fromScale(0, 0.08), UDim2.fromScale(0, 0.92)
    reloadBar.BackgroundColor3, reloadBar.BorderSizePixel = Color3.fromRGB(218, 172, 98), 0
    reloadBar.Parent = ammo
    local reloadTween: Tween? = nil
    local presentation: Presentation.WeaponPresentation? = nil
    local function stopReload()
        if reloadTween then reloadTween:Cancel(); reloadTween = nil end
        reloadBar.Size = UDim2.fromScale(0, 0.08)
        if presentation then presentation.cancelReload() end
    end
    local health = label("Health", UDim2.new(0.46, 0, 0, 44), UDim2.new(0.02, 0, 1, -52), "HEALTH  100")
    local toast = label("Feedback", UDim2.new(0.7, 0, 0, 34), UDim2.fromScale(0.15, 0.65), "")
    toast.Visible = false
    local board = label("Scores", UDim2.new(0.3, 0, 0, 180), UDim2.new(0.69, 0, 0, 96), "")
    board.TextSize, board.TextYAlignment = 15, Enum.TextYAlignment.Top
    local controls = label("Controls", UDim2.new(0.65, 0, 0, 38), UDim2.new(0.02, 0, 1, -94), "Click / Fire / RT: shoot • R / X: reload • WASD / stick: move")
    local toastId = 0
    local function message(text: string)
        toastId += 1
        local id = toastId
        toast.Text, toast.Visible = text, true
        task.delay(Config.ToastSeconds, function() if toastId == id then toast.Visible = false end end)
    end

    local function updateAmmo()
        if not player:GetAttribute("Reloading") then stopReload() end
        ammo.Text = if player:GetAttribute("Reloading") then "RELOADING…" else "REVOLVER  " .. tostring(player:GetAttribute("Ammo") or Config.Magazine) .. " / " .. Config.Magazine
    end
    player:GetAttributeChangedSignal("Ammo"):Connect(updateAmmo)
    player:GetAttributeChangedSignal("Reloading"):Connect(updateAmmo)
    updateAmmo()
    local function updateMatch()
        local phase = shared:GetAttribute("Phase") or "Waiting"
        local seconds = shared:GetAttribute("Seconds") or 0
        if phase ~= "Shootout" and phase ~= "Waiting" then stopReload() end
        if phase == "Waiting" then status.Text = "PRACTICE • Hits " .. tostring(player:GetAttribute("PracticeHits") or 0) .. " • Shoot targets and reload • Waiting for a rival"
        elseif phase == "Preparing" then status.Text = "Preparing the shootout…"
        elseif phase == "Intermission" then status.Text = (shared:GetAttribute("Result") or "Round over") .. " • Next shootout in " .. seconds
        else status.Text = "SHOOTOUT • " .. string.format("%d:%02d", math.floor(seconds / 60), seconds % 60) .. " • First to " .. Config.ScoreToWin end
    end
    player:GetAttributeChangedSignal("PracticeHits"):Connect(updateMatch)
    shared.AttributeChanged:Connect(updateMatch)
    updateMatch()

    local function updateScores()
        local list = Players:GetPlayers()
        local function value(p: Player): number
            local stats = p:FindFirstChild("leaderstats")
            local score = if stats then stats:FindFirstChild("Score") else nil
            return if score and score:IsA("IntValue") then score.Value else 0
        end
        table.sort(list, function(a, b)
            if value(a) == value(b) then return a.UserId < b.UserId end
            return value(a) > value(b)
        end)
        local lines = {"GUNSLINGERS"}
        for i = 1, math.min(#list, 7) do
            table.insert(lines, string.sub(list[i].DisplayName, 1, 18) .. "   " .. value(list[i]))
        end
        board.Text = table.concat(lines, "\n")
        title.Text = if compact then Config.Title .. " • " .. value(player) else Config.Title
    end
    local function updateLayout()
        compact = gui.AbsoluteSize.Y < 450 or gui.AbsoluteSize.X < 600
        board.Visible, controls.Visible = not compact, not compact
        health.Position = if compact then UDim2.new(0.02, 0, 0, 90) else UDim2.new(0.02, 0, 1, -52)
        ammo.Position = if compact then UDim2.new(0.5, 0, 0, 90) else UDim2.new(0.5, 0, 1, -52)
        health.Size = UDim2.new(0.46, 0, 0, if compact then 28 else 44)
        ammo.Size = UDim2.new(0.48, 0, 0, if compact then 28 else 44)
        health.TextSize, ammo.TextSize = if compact then 14 else 18, if compact then 14 else 18
        title.Size = UDim2.new(if compact then 0.5 else 0.32, 0, 0, 36)
        title.Position = UDim2.fromScale(if compact then 0.25 else 0.34, 0)
        updateScores()
    end
    gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout)
    updateLayout()
    local scoreConnections: {[Player]: RBXScriptConnection} = {}
    local function watchScore(p: Player)
        task.spawn(function()
            local stats = p:WaitForChild("leaderstats", 10)
            local score = if stats then stats:WaitForChild("Score", 10) else nil
            if score and score:IsA("IntValue") and p.Parent == Players then
                scoreConnections[p] = score.Changed:Connect(updateScores)
            end
            updateScores()
        end)
    end
    Players.PlayerAdded:Connect(watchScore)
    Players.PlayerRemoving:Connect(function(p)
        if scoreConnections[p] then scoreConnections[p]:Disconnect(); scoreConnections[p] = nil end
        task.defer(updateScores)
    end)
    for _, p in Players:GetPlayers() do watchScore(p) end

    local function request(action: string)
        if GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then return end
        local character = player.Character
        local tool = if character then character:FindFirstChildOfClass("Tool") else nil
        if not tool or not tool:GetAttribute("HighNoonWeapon") then return end
        local phase = shared:GetAttribute("Phase")
        if phase ~= "Shootout" and phase ~= "Waiting" then
            message(if phase == "Intermission" then "Round over • Next shootout starts shortly" elseif phase == "Preparing" then "Preparing the shootout…" else "Waiting for another gunslinger")
            return
        end
        if player:GetAttribute("Reloading") then return end
        if action == "Fire" and (player:GetAttribute("Ammo") or 0) <= 0 then message("Reload your revolver • R / X / Reload"); return end
        local camera = workspace.CurrentCamera
        if not camera then return end
        if action == "Fire" then
            if os.clock() < nextFire then return end
            nextFire = os.clock() + Config.FireInterval
        end
        sequence += 1
        local ray = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        remote:FireServer(action, sequence, ray.Origin, ray.Direction.Unit)
    end
    ContextActionService:BindActionAtPriority("HighNoonFire", function(_, state, input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if input.Position.Y < GuiService:GetGuiInset().Y then return Enum.ContextActionResult.Pass end
            for _, object in player.PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y) do
                if object:IsA("GuiButton") or object:FindFirstAncestorWhichIsA("GuiButton") then
                    return Enum.ContextActionResult.Pass
                end
            end
        end
        if state == Enum.UserInputState.Begin then request("Fire") end
        return Enum.ContextActionResult.Sink
    end, true, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
    ContextActionService:SetTitle("HighNoonFire", "Fire")
    ContextActionService:BindAction("HighNoonReload", function(_, state)
        if state == Enum.UserInputState.Begin then request("Reload") end
        return Enum.ContextActionResult.Sink
    end, true, Enum.KeyCode.R, Enum.KeyCode.ButtonX)
    ContextActionService:SetTitle("HighNoonReload", "Reload")
    local function positionTouchButtons()
        ContextActionService:SetPosition("HighNoonFire", UDim2.fromScale(0.55, -0.3))
        ContextActionService:SetPosition("HighNoonReload", UDim2.fromScale(0.1, 0.35))
    end
    -- Core controls create the buttons after binding and assign their initial positions.
    local touchLayoutConnection = player.PlayerGui.DescendantAdded:Connect(function(child)
        if child:IsA("GuiButton") and child.Parent and child.Parent.Name == "ContextButtonFrame" then
            task.defer(positionTouchButtons)
        end
    end)
    task.defer(positionTouchButtons)

    local healthConnection: RBXScriptConnection? = nil
    local viewmodel = Art.weapon(true)
    if not viewmodel:GetAttribute("SourceArt") then viewmodel.Name = "PLACEHOLDER_RevolverViewmodel" end
    viewmodel:ScaleTo(Assets.ViewmodelScale)
    local weaponPresentation = Presentation.new(viewmodel)
    presentation = weaponPresentation
    local visible = false
    -- A camera-attached model must follow the rendered camera each frame.
    RunService:BindToRenderStep("HighNoonViewmodel", Enum.RenderPriority.Camera.Value + 1, function()
        local camera = workspace.CurrentCamera
        local character = player.Character
        local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
        local tool = if character then character:FindFirstChildOfClass("Tool") else nil
        local equipped = camera ~= nil and humanoid ~= nil and humanoid.Health > 0 and tool ~= nil and tool:GetAttribute("HighNoonWeapon") == true
        if equipped ~= visible then
            visible = equipped
            viewmodel.Parent = if visible then camera else nil
        end
        if camera and visible then
            if viewmodel.Parent ~= camera then viewmodel.Parent = camera end
            local kick = math.max(0, 1 - (os.clock() - lastShot) / Config.ViewmodelRecovery)
            viewmodel:PivotTo(camera.CFrame * Assets.ViewmodelOffset * CFrame.new(0, 0, kick * Config.ViewmodelKick))
        end
    end)
    gui.Destroying:Connect(function()
        touchLayoutConnection:Disconnect()
        RunService:UnbindFromRenderStep("HighNoonViewmodel")
        ContextActionService:UnbindAction("HighNoonReload")
        ContextActionService:UnbindAction("HighNoonFire")
        weaponPresentation.destroy()
        viewmodel:Destroy()
        aim:Destroy()
        if healthConnection then healthConnection:Disconnect() end
        for _, connection in scoreConnections do connection:Disconnect() end
    end)
    local function characterAdded(character: Model)
        nextFire = 0
        stopReload()
        if healthConnection then healthConnection:Disconnect() end
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        local function updateHealth()
            if humanoid.Health <= 0 then stopReload() end
            health.Text = if humanoid.Health <= 0 then "DOWN • Returning to the street…" else "HEALTH  " .. math.ceil(humanoid.Health)
        end
        healthConnection = humanoid.HealthChanged:Connect(updateHealth)
        updateHealth()
        local function equipped(child: Instance)
            if child:IsA("Tool") and child:GetAttribute("HighNoonWeapon") and not child:GetAttribute("ClientBound") then
                child:SetAttribute("ClientBound", true)
                child.Activated:Connect(function() request("Fire") end)
                child.Unequipped:Connect(stopReload)
            end
        end
        character.ChildAdded:Connect(equipped)
        for _, child in character:GetChildren() do equipped(child) end
        local camera = workspace.CurrentCamera
        if camera then camera.FieldOfView = Config.FieldOfView end
    end
    player.CharacterAdded:Connect(characterAdded)
    if player.Character then task.spawn(characterAdded, player.Character) end

    remote.OnClientEvent:Connect(function(action: string, a: any, b: any, c: any)
        if action == "Shot" then
            local distance = (c - b).Magnitude
            if distance < 0.01 then return end
            local beam = Instance.new("Part")
            beam.Name, beam.Anchored, beam.CanCollide, beam.CanQuery, beam.CanTouch = "ShotTracer", true, false, false, false
            beam.Material, beam.Color = Enum.Material.Neon, Color3.fromRGB(245, 204, 126)
            beam.Size, beam.CFrame = Vector3.new(Config.TracerWidth, Config.TracerWidth, distance), CFrame.lookAt((b + c) / 2, c)
            beam.Parent = workspace
            Debris:AddItem(beam, Config.TracerSeconds)
            weaponPresentation.fire(a, b)
            hooks:Fire("Fire", a)
        elseif action == "Reload" then
            if shared:GetAttribute("Phase") ~= "Shootout" and shared:GetAttribute("Phase") ~= "Waiting" then return end
            local character = player.Character
            if not character or not character:FindFirstChildOfClass("Tool") then return end
            stopReload()
            local remaining = math.max(0, a - workspace:GetServerTimeNow())
            reloadTween = TweenService:Create(reloadBar, TweenInfo.new(remaining, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(1, 0.08)})
            reloadTween:Play()
            weaponPresentation.reload()
            hooks:Fire("Reload", player)
        elseif action == "ReloadCancelled" then
            stopReload()
            hooks:Fire("ReloadCancelled", player)
            message("Reload interrupted")
        elseif action == "Fired" then
            if a then weaponPresentation.hit() end
            lastShot = os.clock()
            local camera = workspace.CurrentCamera
            if camera then camera.CFrame *= CFrame.Angles(math.rad(Config.RecoilDegrees), 0, 0) end
            crosshair.Text = if a then "×" else "+"
            crosshair.TextColor3 = if a then Color3.fromRGB(255, 120, 85) else Color3.fromRGB(241, 220, 182)
            task.delay(Config.FeedbackSeconds, function()
                crosshair.Text, crosshair.TextColor3 = "+", Color3.fromRGB(241, 220, 182)
            end)
        end
    end)
end

return Controller
