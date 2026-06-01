local TimeService = {}

function TimeService.GetTime()
	return os.clock()
end

function TimeService.WaitFor(seconds)
	task.wait(seconds)
end

return TimeService
