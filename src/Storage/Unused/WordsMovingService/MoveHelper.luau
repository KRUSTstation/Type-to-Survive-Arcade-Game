local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local MoveHelper = {}
local pausedParts = {}

function MoveHelper.MoveUntilOffScreen(part, cam, speed)
	local viewport = cam.ViewportSize

	local startPos = part.Position

	local ray = cam:ViewportPointToRay(
		viewport.X / 2,
		viewport.Y + 5
	)

	local endPos = ray.Origin + ray.Direction * 50
	local totalDistance = (endPos - startPos).Magnitude

	local distanceTravelled = 0

	while part and part.Parent do
		local dt = RunService.RenderStepped:Wait()

		if pausedParts[part] then
			continue
		end

		local direction = (endPos - part.Position).Unit
		local step = speed * dt
		part.Position += direction * step

		distanceTravelled += step

		local percent = math.clamp(distanceTravelled / totalDistance, 0, 1)

		print(percent)

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
