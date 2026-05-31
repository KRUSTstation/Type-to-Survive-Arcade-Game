local UIS = game:GetService("UserInputService")
local StatController = require(script.Parent.Parent.Parent.Parent.Client.Controllers.UIController.StatController)

local Typer = {}
Typer.__index = Typer

function Typer.new()
	local self = setmetatable({}, Typer)

	self.TypedText = ""
	self.Connection = nil
	self.Enabled = false
	self.OnTextChanged = nil

	return self
end

function Typer:Enable()
	if self.Enabled then return end
	self.Enabled = true

	self.Connection = UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if not self.Enabled then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

		self:_HandleInput(input)
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
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
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

function Typer:_HandleInput(input)
	local key = input.KeyCode
	local changed = false

	if key == Enum.KeyCode.Backspace then
		if self.TypedText ~= "" then
			self.TypedText = self.TypedText:sub(1, -2)
			changed = true
		end
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
