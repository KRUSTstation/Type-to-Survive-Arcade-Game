local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local MoveHelper = {}
local pausedParts = {}

function MoveHelper.MoveUntilOffScreen(obj, cam, speed)
	local part = obj.Model
	
	local viewport = cam.ViewportSize

	local startPos = part.Position

	local ray = cam:ViewportPointToRay(
		viewport.X / 2,
		viewport.Y + 5
	)

	local endPos = ray.Origin + ray.Direction * 50
	local totalDistance = (endPos - startPos).Magnitude

	local distanceTravelled = 0
	
	local rotationAxis = Vector3.new(
		math.random(-100,100)/100,
		math.random(-100,100)/100,
		math.random(-100,100)/100
	).Unit

	local rotationSpeed = math.random(30,120)

	while part and part.Parent do
		local dt = RunService.RenderStepped:Wait()

		if pausedParts[part] then
			continue
		end

		local direction = (endPos - part.Position).Unit
		local step = speed * dt
		part.CFrame = part.CFrame * CFrame.fromAxisAngle(rotationAxis, math.rad(rotationSpeed * dt)) + direction * step

		local currentDistance = (part.Position - startPos).Magnitude
		local percent = math.clamp(currentDistance / totalDistance, 0, 1)

		obj.DistanceTravelled = percent

		local screenPos = cam:WorldToViewportPoint(part.Position)
		if screenPos.Y > viewport.Y + 5 then
			return true
		end
	end

	return false
end

function MoveHelper.Pause(part)
	if part then
		pausedParts[part] = true
	end
end

function MoveHelper.Resume(part)
	if part then
		pausedParts[part] = nil
	end
end

function MoveHelper.JitterUpwards(part, cam, tweenTime, distance)
	local viewport = cam.ViewportSize
	local ray = cam:ViewportPointToRay(
		viewport.X / 2,
		viewport.Y + 5
	)
	local bottomScreenPos = ray.Origin + ray.Direction * 50

	local downDirection = (bottomScreenPos - part.Position).Unit

	local targetPosition = part.Position + (-downDirection * distance)

	TweenService:Create(part, TweenInfo.new(tweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = targetPosition}):Play()
end

return MoveHelper
