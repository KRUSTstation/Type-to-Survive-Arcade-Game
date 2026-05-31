local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Game = require(ReplicatedStorage.Game)
local CAS = game:GetService("ContextActionService")

task.spawn(function()
	local success = false

	while not success do
		success = pcall(function()
			StarterGui:SetCore("ResetButtonCallback", false)
			CAS:UnbindAction("BaseCameraKeyboardZoom")
		end)

		if not success then
			task.wait()
		end
	end
end)

Game.Init()