local GameFinished = {}
GameFinished.__index = GameFinished

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage.Game.Client:FindFirstChild("Controllers")
local Systems = ReplicatedStorage.Game.Client:FindFirstChild("Systems")

local UIController

local originalStates = {}

local onClickConn

function GameFinished.InsertValues(maxCombo: number, points: number)
	GameFinished.MaxComboFrame.Value.Text = maxCombo..'x'
	GameFinished.PointsFrame.Value.Text = points
end

local frameState = false
local toggleCd = false
function GameFinished.Toggle()
	--if toggleCd then return end
	toggleCd = true
	
	local frame = GameFinished.Frame
	local OGState = originalStates[frame]
	
	if not frameState then
		frameState = true
		
		frame.Position = UDim2.new(OGState.Position.X.Scale, 0, -OGState.Size.Y.Scale, 0)
		frame.Visible = true
		local t = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), OGState)
		t:Play()
		t.Completed:Wait()
		
	else
		frameState = false
		
		local t = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(OGState.Position.X.Scale, 0, -OGState.Size.Y.Scale, 0)})
		t:Play()
		t.Completed:Wait()
		frame.Visible = false
	end
	
	toggleCd = false
end

function GameFinished.Init(uiController)
	if not uiController then return end

	UIController = uiController

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("Game")
	local main = gameUI:WaitForChild("Main")

	local frame = main:WaitForChild("GameFinished")
	local maxCombo = frame:WaitForChild("MaxCombo")
	local points = frame:WaitForChild("Points")
	
	local continueButton = frame:WaitForChild("Continue")

	GameFinished.ContinueButton = continueButton
	GameFinished.Frame = frame
	
	GameFinished.MaxComboFrame = maxCombo
	GameFinished.PointsFrame = points

	GameFinished.Frame.Visible = false

	for _, item in pairs(main:GetChildren()) do
		originalStates[item] = {Size = item.Size, Position = item.Position}
	end

	if onClickConn then onClickConn:Disconnect() end

	onClickConn = GameFinished.ContinueButton.MouseButton1Click:Connect(function()
		GameFinished.Toggle()
	end)

	print("[GameFinished] Initialised")
end

return GameFinished