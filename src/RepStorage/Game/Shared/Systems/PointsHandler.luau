local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Constants = require(ReplicatedStorage.Data:WaitForChild("GameConstants"))
local WordsList = require(ReplicatedStorage.Data:WaitForChild("WordList"))

local PointsHandler = {}
PointsHandler.Points = 0
PointsHandler.CurrentCombo = 0
PointsHandler.MaxCombo = 0

PointsHandler.BestScore = 0

function PointsHandler.GetPoints()
	return PointsHandler.Points
end

function PointsHandler.GetCombo()
	return PointsHandler.CurrentCombo
end

function PointsHandler.GetMaxCombo()
	return PointsHandler.MaxCombo
end

function PointsHandler.GetBestScore()
	return PointsHandler.BestScore
end

function PointsHandler.GetComboMultiplier()
	return (math.floor(PointsHandler.CurrentCombo / Constants.WordsForCombo) * (Constants.ComboMultiplier - 1)) + 1
end

function PointsHandler.IncrementPoints(Word : string, multiplier : number)
	PointsHandler.Points += (Word:len() * Constants.PointsPerLetter * PointsHandler.GetComboMultiplier()) * multiplier
	
	if PointsHandler.Points > PointsHandler.BestScore then
		PointsHandler.BestScore = PointsHandler.Points
	end
end

function PointsHandler.IncrementCombo()
	PointsHandler.CurrentCombo += 1
	if PointsHandler.CurrentCombo > PointsHandler.MaxCombo then PointsHandler.MaxCombo = PointsHandler.CurrentCombo end
end

function PointsHandler.ResetPoints()
	PointsHandler.Points = 0
end

function PointsHandler.ResetCombo()
	PointsHandler.CurrentCombo = 0
end

function PointsHandler.ResetMaxCombo()
	PointsHandler.MaxCombo = 0
end

local function EventsInit()
	local GetPointsEvent = Instance.new("RemoteFunction")
	GetPointsEvent.Name = "GetPoints"
	GetPointsEvent.Parent = ReplicatedStorage.Remotes.PointsEvents
	GetPointsEvent.OnServerInvoke = PointsHandler.GetPoints
end

function PointsHandler.Init()
	EventsInit()
	
	print("[PointsHandler] Initialised")
end

return PointsHandler
