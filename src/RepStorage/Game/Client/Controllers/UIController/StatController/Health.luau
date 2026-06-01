local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local frame = playerGui:WaitForChild("Game").Stats:WaitForChild("Health")

local UITemplates = ReplicatedStorage.Assets.UI.Hearts

local Health = {}

function Health.ClearHearts()
	for _, heart in pairs(frame:GetChildren()) do
		if heart:IsA("ImageLabel") then
			heart:Destroy()
		end
	end
end

function Health.SetHealth(currHealth: number, maxHealth: number)
	Health.ClearHearts()
	
	local deadHearts = maxHealth - currHealth
	
	for i = 1, currHealth do
		local heart = UITemplates.AliveHeart:Clone()
		heart.Parent = frame
	end
	
	if deadHearts > 0 then
		for i = 1, deadHearts do
			local heart = UITemplates.DeadHeart:Clone()
			heart.Parent = frame
		end
	end
end

function Health.AddHeart()
	local DeadHeart = frame:FindFirstChild("DeadHeart")
	if DeadHeart then
		local scale = DeadHeart:FindFirstChildOfClass("UIScale")
		DeadHeart.Name = "AliveHeart"
		DeadHeart.Image = UITemplates.AliveHeart.Image
		DeadHeart.LayoutOrder = UITemplates.AliveHeart.LayoutOrder
		
		TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = UITemplates.AliveHeart.UIScale.Scale}):Play()
		return
	end
	
	local heart = UITemplates.AliveHeart:Clone()
	heart.Parent = frame
end

function Health.RemoveHeart()
	local AliveHeart = frame:FindFirstChild("AliveHeart")
	if AliveHeart then
		local scale = AliveHeart:FindFirstChildOfClass("UIScale")
		AliveHeart.Name = "DeadHeart"
		AliveHeart.Image = UITemplates.DeadHeart.Image
		AliveHeart.LayoutOrder = UITemplates.DeadHeart.LayoutOrder

		TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = UITemplates.DeadHeart.UIScale.Scale}):Play()
		return
	end

end

function Health.Init(uicontroller)
	if not uicontroller then return end
	
	for _, heart in UITemplates:GetChildren() do
		local scale = heart:FindFirstChildOfClass("UIScale")
		if not scale then
			scale = Instance.new("UIScale")
			scale.Parent = heart
		end
	end
	
	print("[Health] Initialised")
end

return Health
