local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ServerStorage.Game)
local TimeService = require(ReplicatedStorage.Game.Shared.Systems.TimeService)

print("[BOOT] Starting game initialization...")

Game.Init()

task.spawn(function()
	while true do
		task.wait(30)
		print("[BOOT] Heartbeat check at", TimeService.GetTime())
	end
end)

game:BindToClose(function()
	print("[BOOT] Server shutting down...")
	Game.Shutdown()
end)

print("[BOOT] Initialization complete.")
