local Players = game:GetService("Players")

local MainCam = workspace.PrePlaced:WaitForChild("Camera")

local CameraHelper = {}

function CameraHelper.Init()
	local player = Players.LocalPlayer
	local cam = workspace.CurrentCamera
	
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = MainCam.CFrame
	
	print("[CameraHelper] Initialised")
end

return CameraHelper
