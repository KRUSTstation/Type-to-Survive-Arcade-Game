local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local UIController = {}

UIController.CurrentlyOpenUI = nil

local function initialiseUI()
	for _, moduleScript in script:GetDescendants() do
		if moduleScript:IsA("ModuleScript") then
			local module = require(moduleScript)
			if type(module.Init) == "function" then
				module.Init(UIController)
			end
		end
	end

	for _, moduleScript in script:GetDescendants() do
		if moduleScript:IsA("ModuleScript") then
			local module = require(moduleScript)
			if type(module.Start) == "function" then
				module.Start() 
			end
		end
	end
end

function UIController.Init()
	initialiseUI()
	player.CharacterAdded:Connect(initialiseUI)

	print('[UIController] UIController initialised')
end

return UIController
