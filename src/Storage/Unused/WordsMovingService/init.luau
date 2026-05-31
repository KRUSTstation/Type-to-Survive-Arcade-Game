local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local SFX = ReplicatedStorage.Assets.SFX

local Constants = require(ReplicatedStorage.Data:WaitForChild("GameConstants"))

local PointsHandler = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("PointsHandler"))
local EffectsHandler = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("EffectsHandler"))

local StatController = require(ReplicatedStorage.Game.Client.Controllers:WaitForChild("UIController"):WaitForChild("StatController"))

local MusicService = require(ReplicatedStorage.Game.Client.Systems:WaitForChild("MusicService"))

local Typer = require(script:WaitForChild("Typer"))
local MoveHelper = require(script:WaitForChild("MoveHelper"))

local WordList = require(ReplicatedStorage.Data:WaitForChild("WordList"))
local UpdatedWordList = {}

for _, word in ipairs(WordList) do
	if not UpdatedWordList[#word] then
		UpdatedWordList[#word] = {word}
	else
		table.insert(UpdatedWordList[#word], word)
	end
end

local player = Players.LocalPlayer

local BASE_SPEED = 5 -- studs per second
local BASE_MIN_INTERVAL = 1
local BASE_MAX_INTERVAL = 5

local rng = Random.new(DateTime.now().UnixTimestampMillis)

local WordsHelper = {}

local function deepCopy(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		copy[k] = (type(v) == "table") and deepCopy(v) or v
	end
	return copy
end

local valid_words = {}

local function UpdateWordList(valid_length)
	valid_words = {}
	
	for length, words in pairs(UpdatedWordList) do
		if length <= valid_length and words then
			for _, word in pairs(words) do
				table.insert(valid_words, word)
			end
		end
	end
end

function WordsHelper.GetRandomWord(timer, wordsGenerated)
	while true do
		local valid = true
		local word : string = valid_words[rng:NextInteger(1, #valid_words)]
		for _, entry in pairs(wordsGenerated) do
			if word:sub(1, 1) == entry.Word:sub(1, 1) then
				valid = false
				break
			end
		end
		
		if valid then
			return word
		end
	end
end
	
function WordsHelper.StartGame()
	local typer = Typer.new()
	
	StatController.Display("Word", '')
	
	PointsHandler.ResetPoints()
	PointsHandler.ResetCombo()
	StatController.Update("Points", PointsHandler.GetPoints())
	StatController.Update("Combo", PointsHandler.GetCombo())
	
	StatController.Enable("Points")
	StatController.Enable("Combo")
	StatController.Enable("Word")
	StatController.Enable("Health")
	
	local WordsGuessed = {}
	local WordsGenerated = {}
	
	local lives = Constants.Lives
	
	local speed = BASE_SPEED
	local speedTimer = 0
	local wordTimer = 0
	
	local timePassed = 0
	local timer_count = 0
	
	local max_word_length = 5
	
	local interval = BASE_MAX_INTERVAL
	
	local selectedWord
	local selectedEntry
	local selectedLabel
	local selectedIndex
	
	local comboMusic = "Intense"
	local comboFire
	
	StatController.Health.SetHealth(lives, lives)
	
	local cam = workspace.CurrentCamera
	while not cam do
		task.wait()
		cam = workspace.CurrentCamera
	end
	
	UpdateWordList(max_word_length)
	local speedConnection = RunService.RenderStepped:Connect(function(dt)
		speedTimer+=dt
		timePassed+=dt
		if speedTimer >= Constants.SpeedUpdateTimer then
			speedTimer = 0
			timer_count+=1
			
			local speed_addition = (BASE_SPEED * Constants.SpeedMultiplier) - BASE_SPEED
			local new_speed = BASE_SPEED + (speed_addition*timer_count)
			speed = math.clamp(new_speed, BASE_SPEED, (Constants.MaxSpeed*BASE_SPEED))
			
			local interval_addition = BASE_MAX_INTERVAL - (BASE_MAX_INTERVAL * Constants.IntervalMultiplier)
			local new_interval = BASE_MAX_INTERVAL - (interval_addition*timer_count)
			interval = math.clamp(new_interval, (Constants.MinInterval*BASE_MAX_INTERVAL), BASE_MAX_INTERVAL)
			print(string.format("Speed: %.2f Interval: %.2f", speed, interval))
		end
		
		wordTimer += dt
		if wordTimer >= Constants.WordUpdateTimer then
			wordTimer = 0

			max_word_length += 1
			UpdateWordList(max_word_length)
		end
	end)
	
	typer:Enable()
	
	typer:ConnectOnTextChanged(function(text)
		if text ~= "" then
			for index, entry in ipairs(WordsGenerated) do
				if not selectedWord and entry.Word:sub(1, 1) == text:sub(1, 1) then
					selectedIndex = index
					selectedWord = entry.Word
					selectedEntry = entry
					selectedLabel = entry.Part.Title.Name2
					EffectsHandler.ApplyHighlight("Targetted", entry.Part)
					--MoveHelper.JitterUpwards(entry.Part, cam, 0.1, 0.5)
				end
			end
			
			if selectedWord and text == selectedWord then
				--//Correct//			
				selectedEntry.Part:Destroy()
				EffectsHandler.Emit("Explosion", selectedEntry.Part.CFrame)
				table.remove(WordsGenerated, selectedIndex)
				
				selectedEntry = nil
				selectedLabel = nil
				selectedIndex = nil
				
				table.insert(WordsGuessed, {Word = selectedWord, Correct = true})
				PointsHandler.Increment(selectedWord)
				
				selectedWord = nil
				typer:Reset()
				
				local combo = PointsHandler.GetCombo()
				
				StatController.Update("Points", PointsHandler.GetPoints())
				StatController.Update("Combo", combo)
				
				SFX:WaitForChild("grenade explosion"):Play()
				
				--//Combo Upgrade//
				if combo~=0 and combo % Constants.WordsForCombo == 0 then
					local comboLevel = combo / Constants.WordsForCombo
					
					local billboard = ReplicatedStorage.Assets.UI.Combo:Clone()
					billboard.Parent = player:WaitForChild("PlayerGui")
					billboard.Multiplier.Text = PointsHandler.GetComboMultiplier().."x Points"
					billboard.Adornee = cam

					billboard.StudsOffsetWorldSpace = Vector3.new(0, 20, -20)
					
					task.spawn(function()
						local downTween = TweenService:Create(
							billboard,
							TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{StudsOffsetWorldSpace = Vector3.new(0, 5, -20)}
						)

						downTween:Play()
						downTween.Completed:Wait()

						task.wait(0.8)

						local upTween = TweenService:Create(
							billboard,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{StudsOffsetWorldSpace = Vector3.new(0, 20, -20)}
						)

						upTween:Play()
						upTween.Completed:Wait()

						billboard:Destroy()
					end)
					SFX:WaitForChild("Combo"):Play()
					
					if comboLevel == 1 then
						EffectsHandler.ApplyParticle("Combo")
						EffectsHandler.ChangeParticleSpeed(workspace.Particles:WaitForChild("Combo"), 0.5)

					elseif comboLevel >= 2 then
						EffectsHandler.ChangeParticleSpeed(workspace.Particles:WaitForChild("Combo"), 1)
						MusicService.PlaySong(comboMusic)
					end
				end
				return
			end
			
			if selectedWord then
				local correctText = ""
				local index = 1
				while index <= selectedWord:len() and selectedWord:sub(index, index) == text:sub(index, index) do
					correctText ..= selectedWord:sub(index, index)
					index += 1
				end

				local incorrectText = (index <= text:len() and selectedWord:sub(index, text:len()) or "")
				local remainingText = (text:len() < selectedWord:len() and selectedWord:sub(text:len() + 1, -1) or "")
				local excessText = (text:len() > selectedWord:len() and text:sub(selectedWord:len() + 1, -1) or "")
				local noncorrectText = (index <= text:len() and text:sub(index, -1) or "")
				
				selectedLabel.Text = "<font color=\"#00FF00\">" .. correctText .. "</font>" .. "<font color=\"#FF0000\">" .. incorrectText .. excessText .. "</font>" .. remainingText
				StatController.Display("Word", '<mark color="#000000" transparency="0.7">' .. '<font color=\"#00FF00\">' .. correctText .. '</font>' .. noncorrectText .. '</mark>')
			else
				typer:Reset()
			end
		elseif selectedWord then
			EffectsHandler.ResetHighlight("Targetted")
			selectedLabel.Text = selectedWord
			selectedWord = nil
			StatController.Display("Word", '')
		end
	end)
	
	--//Death// -- added task.spawn so that this is immediately done after the player dies
	-- Copyright 2026 Lance under CC 4.0 BY-NC
	--[[
	points system
	combo system
	ui system
]]
	task.spawn(function()
		while lives > 0 do
			task.wait()
		end
		
		typer:Stop()
		speedConnection:Disconnect()

		for i = #WordsGenerated, 1, -1 do
			WordsGenerated[i].Part:Destroy()
			table.remove(WordsGenerated, i)
		end

		SFX:WaitForChild("gta-v-death-sound-effect-102"):Play()
		
		task.wait(1)
		StatController.Disable("Points")
		StatController.Disable("Combo")
		StatController.Disable("Word")
		StatController.Disable("Health")
		return true
	end)
	
	local waiting = false

	while lives > 0 do
		while waiting do
			task.wait()
		end
		--local part = Instance.new("Part")
		--part.Size = Vector3.new(1, 1, 1)
		--part.Anchored = true
		--part.CanCollide = false
		--part.Material = Enum.Material.Neon
		--part.Color = Color3.fromRGB(255, 255, 255)
		--part.Parent = workspace
		
		local part = game.ReplicatedStorage.Assets.Models:WaitForChild("Asteroid"):Clone()
		part.Parent = workspace
		
		local billboard = game.ReplicatedStorage.Assets.UI.Title:Clone()
		billboard.Parent = part
		
		local word = WordsHelper.GetRandomWord(timePassed, WordsGenerated)
		
		local textBox = billboard.Name2
		textBox.Text = word
		textBox.Parent = billboard

		local xOffset = rng:NextNumber(-40, 40)

		local spawnPos =
			cam.CFrame.Position
			+ cam.CFrame.LookVector * 30
			+ cam.CFrame.UpVector * 25
			+ cam.CFrame.RightVector * xOffset

		part.CFrame = CFrame.new(spawnPos)
		
		local letterDiff = Constants.MeanSpeedWordLength - word:len()
		local speedChange = (Constants.SpeedChangePerLetter * speed) - speed
		
		local correctSpeed = speed + (letterDiff * speedChange)

		correctSpeed = math.max(correctSpeed, 5)
		
		task.spawn(function()
			local reachedBottom = MoveHelper.MoveUntilOffScreen(part, cam, correctSpeed)
			
			if reachedBottom then
				for index, entry in ipairs(WordsGenerated) do
					if entry.Part == part and entry.Word == word then
						entry.Part:Destroy()

						table.insert(WordsGuessed, {Word = entry.Word, Correct = false})
						table.remove(WordsGenerated, index)

						selectedWord = nil
						typer:Reset()
						
						break
					end
				end
				
				--//Incorrect//
				lives-=1
				StatController.Health.RemoveHeart()
				
				local tweenTime = 1
				waiting = true

				for index, entry in ipairs(WordsGenerated) do
					MoveHelper.JitterUpwards(entry.Part, cam, tweenTime, 8)
				end
				
				waiting = false
				
				PointsHandler.ResetCombo()
				StatController.Update("Combo", PointsHandler.GetCombo())
				EffectsHandler.RemoveParticle("Combo")
				SFX:WaitForChild("Damage4"):Play()
				MusicService.PlayMainGameMusic()
				--StatController.Update("Points", PointsHandler.GetPoints())
				--connection:Disconnect()
			end
		end)
		
		table.insert(WordsGenerated, {
			Part = part,
			Word = word,
		})
		
		task.wait(rng:NextNumber(if interval < BASE_MIN_INTERVAL then interval else BASE_MIN_INTERVAL, interval))
	end
end

function WordsHelper.Init()
	print("[WordsHelper] Initialised")
end

return WordsHelper