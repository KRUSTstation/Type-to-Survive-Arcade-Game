-- Rainbow Text Hue Shift for BillboardGui
-- Put this LocalScript inside the BillboardGui

local RunService = game:GetService("RunService")
local billboardGui = script.Parent

local SPEED = 0.6 -- how fast the colors cycle (lower = slower)

-- Collect all TextLabels inside the BillboardGui
local textLabels = {}

for _, obj in ipairs(billboardGui:GetDescendants()) do
	if obj:IsA("TextLabel") then
		table.insert(textLabels, obj)
	end
end

local hue = 0

RunService.RenderStepped:Connect(function(dt)
	hue = (hue + SPEED * dt) % 1
	billboardGui.Brightness = 12
	local color = Color3.fromHSV(hue, 1, 1)

	for _, label in ipairs(textLabels) do
		label.TextColor3 = color
	end
end)
