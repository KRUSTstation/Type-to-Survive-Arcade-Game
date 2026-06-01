local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local SpaceShipMover = {}
SpaceShipMover.__index = SpaceShipMover

function SpaceShipMover.new()
	local self = setmetatable({}, SpaceShipMover)
	
	self.Model = ReplicatedStorage.Assets.Models:WaitForChild("SpaceShip"):Clone()
	self.Model.Parent = workspace
	
	self._destroyed = false
	
	return self
end

function SpaceShipMover:TweenTo(cframe, time)
	if self._destroyed then return end
	
	local cfValue = Instance.new("CFrameValue")
	cfValue.Value = self.Model:GetPivot()
	cfValue.Parent = self.Model

	cfValue:GetPropertyChangedSignal("Value"):Connect(function()
		self.Model:PivotTo(cfValue.Value)
	end)

	local tween = TweenService:Create(
		cfValue,
		TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Value = cframe }
	)

	tween:Play()
end

function SpaceShipMover:MoveTo(cframe)
	if self._destroyed then return end
	
	self.Model:PivotTo(cframe)
end

function SpaceShipMover:SetSize(scale)
	if self._destroyed then return end
	
	self.Model.Size *= scale
end

function SpaceShipMover:LookAt(targetPos)
	if self._destroyed then return end
	
	local pos = self.Model:GetPivot().Position
	local lookCF = CFrame.lookAt(pos, targetPos)
	
	local correction = CFrame.Angles(math.rad(-90), 0, 0)

	self:TweenTo(lookCF * correction, 0.2)
end

function SpaceShipMover:Destroy()
	self._destroyed = true
	self.Model:Destroy()
end

return SpaceShipMover
