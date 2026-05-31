local PointsHandler = require(game.ReplicatedStorage.Game.Shared.Systems.PointsHandler)
local StatController = {}
StatController.__index = StatController

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage.Game.Client:FindFirstChild("Controllers")

local UIController

function StatController.Update(statName, value)
	if not StatController.UI then return end

	local stat = StatController.UI:FindFirstChild(statName)
	if not stat or not stat:IsA("Frame") then return end
	
	local textLabel = stat:FindFirstChild("Value")
	if not textLabel or not textLabel:IsA("TextLabel") then return end
	
	if statName == 'PrevPoints' then
		textLabel.Text = value
		return
	end
	
	textLabel.Text = tostring(value)..(statName ~= "Combo" and " " .. statName or "x" .. ' <font transparency="0.5"><font color="#777777">(' .. PointsHandler.GetComboMultiplier() .. 'x pts)</font></font>')
end

function StatController.Display(a : string, b : string)
	StatController.UI[a].Value.Text = b
end

function StatController.Disable(stat)
	if not StatController.UI then return end

	local stat = StatController.UI:FindFirstChild(stat)
	if not stat or not stat:IsA("Frame") then return end

	stat.Visible = false
end

function StatController.Enable(stat)
	if not StatController.UI then return end
	
	local stat = StatController.UI:FindFirstChild(stat)
	if not stat or not stat:IsA("Frame") then return end
	
	stat.Visible = true
end

function StatController.Init(uiController)
	if not uiController then return end

	UIController = uiController
	
	for _, script in pairs(script:GetChildren()) do
		if script:IsA("ModuleScript") then
			local module = require(script)
			StatController[script.Name] = module
		end
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("Game")
	local ui = gameUI:WaitForChild("Stats")

	StatController.UI = ui

	for _, frame in pairs(StatController.UI:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end

	--StatController.CloseButton.MouseButton1Click:Connect(function()
	--	StatController.close()
	--end)
	print("[StatController] Initialised")
end

return StatController