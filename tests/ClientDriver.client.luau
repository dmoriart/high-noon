--!strict
-- Temporary Studio-only client driver; excluded from the shipped project mapping.
local Players = game:GetService("Players")
assert(game:GetService("RunService"):IsStudio(), "Studio only")
local shared = game:GetService("ReplicatedStorage"):WaitForChild("HighNoon")
local player = Players.LocalPlayer
shared:GetAttributeChangedSignal("TestShotSequence"):Connect(function()
    if shared:GetAttribute("TestShooter") ~= player.Name then return end
    local target = Players:FindFirstChild(shared:GetAttribute("TestTarget")) :: Player
    local origin = player.Character.Head.Position
    local direction = (target.Character.HumanoidRootPart.Position - origin).Unit
    shared.Combat:FireServer("Fire", 10000 + shared:GetAttribute("TestShotSequence"), origin, direction)
end)
shared:GetAttributeChangedSignal("TestLeave"):Connect(function()
    if shared:GetAttribute("TestLeave") == player.Name then
        local service = game:GetService("StudioTestService")
        assert(service:CanLeaveTest(), "Client cannot leave test")
        service:LeaveTest()
    end
end)
