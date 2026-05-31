local StartButton = {}
StartButton.__index = StartButton

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage.Game.Client:FindFirstChild("Controllers")
local Systems = ReplicatedStorage.Game.Client:FindFirstChild("Systems")
local Modules = ReplicatedStorage.Modules

local UIHelper = require(Modules:WaitForChild("UIHelper"))
local RepeatingLine = require(Modules.UIHelper.RepeatingLine)

local PointsHandler = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("PointsHandler"))

local MainGameHandler = require(Systems.MainGameHandler)
local MusicService = require(Systems.MusicService)
local Typer = require(Systems.MainGameHandler.Typer)

local GameFinished = require(Controllers.UIController.MainMenuController.GameFinished)

local UIController

local originalStates = {}

local pauseConn = false

local typer = Typer.new()
local repeatingLine

local onClickConn
local onHoverConn
local onHoverEndConn

local function MoveFrames(out)
	for frame, info in pairs(originalStates) do
		if frame:IsA("Frame") and frame ~= StartButton.Frame then
			if out then
				TweenService:Create(frame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(info.Position.X.Scale, 0, -info.Size.Y.Scale, 0)}):Play()
			else
				TweenService:Create(frame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), info):Play()
			end
		end
	end
end

function StartButton.PlayGame()
	MoveFrames(true)
	MusicService.PlayMainGameMusic()
	StartButton.Frame.Visible = false
	
	local currGame = MainGameHandler.new()
	
	local ended = currGame:StartGame()
	
	GameFinished.InsertValues(PointsHandler.GetMaxCombo(), PointsHandler.GetPoints())
	GameFinished.Toggle()
	
	local onclick
	
	MusicService.PlayMenuMusic()
	onclick = GameFinished.ContinueButton.MouseButton1Click:Connect(function()
		StartButton.Frame.Visible = true
		MoveFrames(false)
		onclick:Disconnect()
		typer:Resume()
		typer:Reset()
		repeatingLine:Resume()
	end)
end

function StartButton.Init(uiController)
	if not uiController then return end

	UIController = uiController

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("Game")
	local main = gameUI:WaitForChild("Main")

	local frame = main.Info:WaitForChild("StartButton")
	local button = frame:WaitForChild("Label")

	StartButton.Button = button
	StartButton.Frame = frame
	
	StartButton.Frame.Visible = true
	
	repeatingLine = RepeatingLine.new(StartButton.Button)
	
	for _, item in pairs(main:GetChildren()) do
		if item:IsA("Frame") then
			originalStates[item] = {Size = item.Size, Position = item.Position, BackgroundTransparency = item.BackgroundTransparency}
		end
		originalStates[button] = {Size = button.Size, Position = button.Position, --[[ImageColor3 = button.ImageColor3]]}
	end
	
	local selectedWord = 'start'
	StartButton.Button.Text = ''
	repeatingLine:Enable()
	
	typer:Enable()
	
	StartButton.Button.Text = '<font color="rgb(117, 117, 117)">TYPE START TO START</font>'
	typer:ConnectOnTextChanged(function(text)
		if text == "" then
			StartButton.Button.Text = '<font color="rgb(117, 117, 117)">TYPE START TO START</font>'
			return	
		end
		
		repeatingLine:Pause()
		local correctText, incorrectText, remainingText, excessText, noncorrectText = UIHelper.GetCorrectnessOfText(selectedWord, text)
		StartButton.Button.Text = '<b><font color=\"#00FF00\">' .. string.upper(correctText) .. '</font>' .. string.upper(noncorrectText)..'</b>'
		
		if text == selectedWord then
			typer:Pause()
			repeatingLine:Pause()
			StartButton.PlayGame()
		end
		
		repeatingLine:Resume()
	end)
	

	--if onClickConn then onClickConn:Disconnect() end
	--if onHoverConn then onHoverConn:Disconnect() end
	--if onHoverEndConn then onHoverEndConn:Disconnect() end

	--onClickConn = StartButton.Button.MouseButton1Click:Connect(function()
	--	if pauseConn then return end
		
	--	pauseConn = true
	--	local t = TweenService:Create(StartButton.Button, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
	--	t:Play()
	--	MoveFrames(true)
	--	t.Completed:Wait()
		
	--	StartButton.PlayGame()
	--	t = TweenService:Create(StartButton.Button, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), originalStates[StartButton.Button])
	--	t:Play()
	--	t.Completed:Wait()
	--	pauseConn = false
	--end)
	
	--onHoverConn = StartButton.Button.MouseEnter:Connect(function()
	--	if pauseConn then return end
		
	--	TweenService:Create(StartButton.Button, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(originalStates[StartButton.Button].Size.X.Scale*1.2, 0, originalStates[StartButton.Button].Size.Y.Scale*1.2, 0), ImageColor3 = Color3.new(0.568627, 0.568627, 0.568627)}):Play()
	--end)
	
	--onHoverEndConn = StartButton.Button.MouseLeave:Connect(function()
	--	if pauseConn then return end
		
	--	TweenService:Create(StartButton.Button, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), originalStates[StartButton.Button]):Play()
	--end)

	print("[StartButton] Initialised")
end

return StartButton