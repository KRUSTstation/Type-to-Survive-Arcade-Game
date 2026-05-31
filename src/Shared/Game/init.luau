local Game = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local LoadingServiceScript = ReplicatedStorage.Game.Client.Services:WaitForChild("LoadingService")
--local LoadingService = require(LoadingServiceScript)

local Initialized = {}
local Started = {}

function Game.Init()

	--LoadingService.Start()
	--table.insert(Started, LoadingServiceScript)

	local folders = ReplicatedStorage.Game.Client:GetDescendants()

	for _, moduleScript in pairs(folders) do
		if moduleScript:IsA("ModuleScript") then
			local module = require(moduleScript)
			if type(module.Init) == "function" and not table.find(Initialized, moduleScript) then
				module.Init()
				table.insert(Initialized, moduleScript)
			end
		end
	end

	for _, moduleScript in pairs(folders) do
		if moduleScript:IsA("ModuleScript") then
			local module = require(moduleScript)
			if type(module.Start) == "function" and not table.find(Started, moduleScript) then
				module.Start()
				table.insert(Started, moduleScript)
			end
		end
	end

	print("[Game (Client)] Game initialized")
end

return Game
