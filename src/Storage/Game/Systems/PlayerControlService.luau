local PlayerControlService = {}

function PlayerControlService.OnPlayerAdded(player)
	local char = player.Character or player.CharacterAdded:Wait()
	
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.CanCollide then
			part.CanCollide = false
		end
	end
	
	local hum = char:WaitForChild("Humanoid")
	local hrp = char:WaitForChild("HumanoidRootPart")
	
	hrp.Anchored = true
	hum.WalkSpeed = 0
	hum.JumpHeight = 0
end

function PlayerControlService.Init()
	game.Players.PlayerAdded:Connect(PlayerControlService.OnPlayerAdded)
	
	for _, player in game.Players:GetPlayers() do
		PlayerControlService.OnPlayerAdded(player)
	end
	
	print("[PlayerControlService] Initialised")
end

return PlayerControlService
