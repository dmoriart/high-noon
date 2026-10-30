--!strict
local Config = require(script.Parent.Config)
local Ballistics = {}

-- Adapted from Evostrike's util_getDamageFromHumResult: body multipliers and distance falloff.
function Ballistics.damage(partName: string, distance: number): number
    local multiplier = 1
    if partName == "Head" then
        multiplier = Config.HeadMultiplier
    elseif string.find(partName, "Leg") or string.find(partName, "Foot") then
        multiplier = Config.LegMultiplier
    end
    local base = math.max(Config.MinDamage, Config.Damage - math.max(0, distance - Config.FalloffStart) * Config.FalloffPerStud)
    return math.round(base * multiplier)
end

function Ballistics.validVector(value: any): boolean
    return typeof(value) == "Vector3" and value.X == value.X and value.Y == value.Y and value.Z == value.Z
        and math.abs(value.X) < 1e6 and math.abs(value.Y) < 1e6 and math.abs(value.Z) < 1e6
end

return Ballistics
