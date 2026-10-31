--!strict
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Assets = require(game:GetService("ReplicatedStorage").Config.AssetConfig)
local Presentation = {}
export type WeaponPresentation = {
    cancelReload: () -> (), fire: (Player, Vector3) -> (), reload: () -> (), hit: () -> (), destroy: () -> (),
}

function Presentation.new(model: Model): WeaponPresentation
    local tracks: {[string]: AnimationTrack} = {}
    local reloadSound: Sound? = nil
    local function track(name: string): AnimationTrack?
        local id = Assets.Animations[name]
        if id == "" then return nil end
        if tracks[name] then return tracks[name] end
        -- Late shot acknowledgements can arrive after death or unequipping.
        if not model:IsDescendantOf(workspace) then return nil end
        local controller = model:FindFirstChildOfClass("AnimationController") or Instance.new("AnimationController")
        controller.Parent = model
        local animator = controller:FindFirstChildOfClass("Animator") or Instance.new("Animator")
        animator.Parent = controller
        local animation = Instance.new("Animation")
        animation.AnimationId = id
        local loaded = animator:LoadAnimation(animation)
        animation:Destroy()
        loaded.Priority, loaded.Looped = Enum.AnimationPriority.Action, false
        tracks[name] = loaded
        return loaded
    end
    local function sound(name: string, position: Vector3?): Sound?
        local options = Assets.Sounds[name]
        if options.Id == "" then return nil end
        local parent: Instance = SoundService
        if position then
            local emitter = Instance.new("Part")
            emitter.Name, emitter.Anchored, emitter.Transparency = "WeaponAudio", true, 1
            emitter.CanCollide, emitter.CanQuery, emitter.CanTouch = false, false, false
            emitter.Position, emitter.Parent = position, workspace
            Debris:AddItem(emitter, Assets.AudioCleanupSeconds)
            parent = emitter
        end
        local clip = Instance.new("Sound")
        clip.SoundId, clip.Volume, clip.RollOffMaxDistance = options.Id, options.Volume, Assets.AudioMaxDistance
        clip.Parent = parent
        clip.Ended:Once(function() clip:Destroy() end)
        Debris:AddItem(clip, Assets.AudioCleanupSeconds)
        clip:Play()
        return clip
    end
    local api = {}
    function api.cancelReload()
        if tracks.Reload then tracks.Reload:Stop() end
        if reloadSound then reloadSound:Destroy(); reloadSound = nil end
    end
    function api.fire(shooter: Player, origin: Vector3)
        sound("Fire", origin)
        if shooter == Players.LocalPlayer then
            local animation = track("Fire")
            if animation then animation:Play() end
        end
    end
    function api.reload()
        api.cancelReload()
        reloadSound = sound("Reload", nil)
        local animation = track("Reload")
        if animation then animation:Play() end
    end
    function api.hit() sound("Hit", nil) end
    function api.destroy()
        api.cancelReload()
        for _, animation in tracks do animation:Stop(); animation:Destroy() end
    end
    return api
end

return Presentation
