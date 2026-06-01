local RunService = game:GetService("RunService")

local RepeatingLine = {}
RepeatingLine.__index = RepeatingLine

function RepeatingLine.new(textFrame: Instance)
	local self = setmetatable({}, RepeatingLine)
	
	self.Enabled = false
	self.Frame = textFrame
	self.Conn = nil
	
	self._running = false
	self._typeLine = true
	
	return self
end

function RepeatingLine:Enable()
	if self.Enabled then return end
	self._running = true
	self.Enabled = true
	
	task.spawn(function()
		while self._running do
			while not self.Enabled do
				task.wait()
			end

			self._typeLine = not self._typeLine
			if self._typeLine then
				self.Frame.Text..='|'	
			else
				if self.Frame.Text:sub(-1) == '|' then
					self.Frame.Text = self.Frame.Text:sub(1, -2)
				end
			end
			task.wait(0.5)
		end
	end)
end

function RepeatingLine:Disable()
	self._running = false
	self.Enabled = false
end

function RepeatingLine:Pause()
	self.Enabled = false
	self._typeLine = false
end

function RepeatingLine:Resume()
	self.Enabled = true
end

return RepeatingLine
