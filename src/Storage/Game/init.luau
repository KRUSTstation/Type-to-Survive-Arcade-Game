local Game = {}

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerModules = ServerStorage.Game
local SharedModules = ReplicatedStorage.Game.Shared

local Running = false
local initialised = {}
local started = {}

function Game.Init()
	print("[Game] Initialization started...")

	--local DataHandlerScript = ServerModules.Systems:WaitForChild("DataHandler")
	--local DataHandler = require(DataHandlerScript)
	--DataHandler.Init()
	--table.insert(initialised, DataHandlerScript)

	for _, moduleScript in pairs(ServerModules:GetDescendants()) do
		if moduleScript:IsA("ModuleScript") and not table.find(initialised, moduleScript) then
			local module = require(moduleScript)

			if typeof(module.Init) == "function" then
				module.Init()
				table.insert(initialised, moduleScript)
			end
		end
	end

	for _, moduleScript in pairs(ServerModules:GetDescendants()) do
		if moduleScript:IsA("ModuleScript") and not table.find(started, moduleScript) then
			local module = require(moduleScript)

			if typeof(module.Start) == "function" then
				module.Start()
				table.insert(started, moduleScript)
			end
		end
	end

	for _, moduleScript in pairs(SharedModules:GetDescendants()) do
		if moduleScript:IsA("ModuleScript") and not table.find(initialised, moduleScript) then
			local module = require(moduleScript)

			if typeof(module.Init) == "function" then
				module.Init()
				table.insert(initialised, moduleScript)
			end
		end
	end

	for _, moduleScript in pairs(SharedModules:GetDescendants()) do
		if moduleScript:IsA("ModuleScript") and not table.find(started, moduleScript) then
			local module = require(moduleScript)

			if typeof(module.Start) == "function" then
				module.Start()
				table.insert(started, moduleScript)
			end
		end
	end

	Running = true

	print("[Game] Ready.")
end

function Game.Shutdown()
	print("[Game] Shutting down...")

	Running = false
end

return Game
