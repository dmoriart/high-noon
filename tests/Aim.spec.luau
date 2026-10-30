--!strict
-- Run on a Studio client; call again after a viewport/device resize.
return function(): number
    assert(game:GetService("RunService"):IsStudio(), "Studio only")
    local player = game:GetService("Players").LocalPlayer
    local aim = player.PlayerGui:WaitForChild("HighNoonAim", 10)
    assert(aim, "Missing viewport-aligned aim layer")
    local crosshair = aim:WaitForChild("Crosshair") :: TextLabel
    for _ = 1, 3 do game:GetService("RunService").RenderStepped:Wait() end
    local inset = game:GetService("GuiService"):GetGuiInset()
    local center = crosshair.AbsolutePosition + crosshair.AbsoluteSize / 2 + inset
    local viewportCenter = workspace.CurrentCamera.ViewportSize / 2
    local errorPixels = (center - viewportCenter).Magnitude
    assert(errorPixels <= 1, "Crosshair misses camera aim by " .. errorPixels .. " pixels")
    print("[HighNoon AIM PASS]", workspace.CurrentCamera.ViewportSize, "error pixels", errorPixels)
    return errorPixels
end
