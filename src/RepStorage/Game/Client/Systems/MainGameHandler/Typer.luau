local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIS = game:GetService("UserInputService")
local StatController = require(script.Parent.Parent.Parent.Parent.Client.Controllers.UIController.StatController)

local SFX = ReplicatedStorage.Assets.SFX

local Typer = {}
Typer.__index = Typer

function Typer.new()
	local self = setmetatable({}, Typer)

	self.TypedText = ""
	self.InputBeganConnection = nil
	self.InputEndConnection = nil
	self.Enabled = false
	self.OnTextChanged = nil
	
	self.HoldingBackspace = false

	return self
end

function Typer:Enable()
	if self.Enabled then return end
	self.Enabled = true

	self.InputBeganConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if not self.Enabled then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

		self:_HandleInput(input)
	end)
	
	self.InputEndConnection = UIS.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if not self.Enabled then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

		self:_HandleInputEnded(input)
	end)
end

function Typer:Pause()
	self.Enabled = false
end

function Typer:Resume()
	self.Enabled = true
end

function Typer:Stop()
	self.Enabled = false
	if self.InputBeganConnection then
		self.InputBeganConnection:Disconnect()
		self.InputBeganConnection = nil
	end
	
	if self.InputEndConnection then
		self.InputEndConnection:Disconnect()
		self.InputEndConnection = nil
	end
end

function Typer:Reset()
	self.TypedText = ""
	StatController.Display("Word", '')
	if self.OnTextChanged then
		self.OnTextChanged(self.TypedText)
	end
end

function Typer:ConnectOnTextChanged(onTextChanged)
	self.OnTextChanged = onTextChanged
end

function Typer:_DeleteOne()
	if self.TypedText ~= "" then
		self.TypedText = self.TypedText:sub(1, -2)

		if self.OnTextChanged then
			self.OnTextChanged(self.TypedText)
		end
	end
end

function Typer:_HandleInputEnded(input)
	local key = input.KeyCode
	
	if key == Enum.KeyCode.Backspace then
		self.HoldingBackspace = false
		task.cancel(self.BackSpaceHoldThread)
	end
end

function Typer:_HandleInput(input)
	local key = input.KeyCode
	local changed = false
	
	if key == Enum.KeyCode.Backspace then
		self:_DeleteOne()
		self.HoldingBackspace = true
		
		self.BackSpaceHoldThread = task.delay(0.4, function()
			while self.HoldingBackspace do
				self:_DeleteOne()
				task.wait(0.02)
			end
		end)
		
	elseif key == Enum.KeyCode.Space then
		self:Reset()
		
	elseif key.Value >= Enum.KeyCode.A.Value and key.Value <= Enum.KeyCode.Z.Value then
		local letter = string.char(key.Value)
		self.TypedText ..= letter
		changed = true
	end

	if changed and self.OnTextChanged then
		self.OnTextChanged(self.TypedText)
	end
end

return Typer
