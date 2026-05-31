local UIHelper = {}

function UIHelper.GetCorrectnessOfText(correctWord: string, currentText: string)
	local correctText = ""
	local index = 1
	while index <= correctWord:len() and correctWord:sub(index, index) == currentText:sub(index, index) do
		correctText ..= correctWord:sub(index, index)
		index += 1
	end

	local incorrectText = (index <= currentText:len() and correctWord:sub(index, currentText:len()) or "")
	local remainingText = (currentText:len() < correctWord:len() and correctWord:sub(currentText:len() + 1, -1) or "")
	local excessText = (currentText:len() > correctWord:len() and currentText:sub(correctWord:len() + 1, -1) or "")
	local noncorrectText = (index <= currentText:len() and currentText:sub(index, -1) or "")

	return correctText, incorrectText, remainingText, excessText, noncorrectText
end

return UIHelper
