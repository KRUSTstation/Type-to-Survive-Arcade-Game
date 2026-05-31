local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Modules = ReplicatedStorage.Modules
local UIHelper = require(Modules:WaitForChild("UIHelper"))

local SFX = ReplicatedStorage.Assets.SFX

local Constants = require(ReplicatedStorage.Data:WaitForChild("GameConstants"))

local PointsHandler = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("PointsHandler"))
local EffectsHandler = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("EffectsHandler"))

local StatController = require(ReplicatedStorage.Game.Client.Controllers:WaitForChild("UIController"):WaitForChild("StatController"))

local MusicService = require(ReplicatedStorage.Game.Client.Systems:WaitForChild("MusicService"))

local Typer = require(script:WaitForChild("Typer"))
local MoveHelper = require(script:WaitForChild("MoveHelper"))
local Asteroid = require(script:WaitForChild("Asteroid"))
local SpaceShipMover = require(script:WaitForChild("SpaceShipMover"))

local AsteroidTypes = require(ReplicatedStorage.Data.Asteroids:WaitForChild("AsteroidTypes"))
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
local BASE_MAX_INTERVAL = 3
local MAX_HEALTH = 5

local cam = workspace.CurrentCamera
while not cam do
	task.wait()
	cam = workspace.CurrentCamera
end

local rng = Random.new()

local MainGameHandler = {}
MainGameHandler.__index = MainGameHandler

local function deepCopy(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		copy[k] = (type(v) == "table") and deepCopy(v) or v
	end
	return copy
end

local valid_words = {}

local asteroidKeys = {}
for k in pairs(AsteroidTypes) do
	table.insert(asteroidKeys, k)
end

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
	
function MainGameHandler.new()
	local self = setmetatable({}, MainGameHandler)
	
	self.Lives = Constants.Lives
	self.Speed = BASE_SPEED
	self.Interval = BASE_MAX_INTERVAL
	self.TimerCount = 0
	
	self.WordsGuessed = {}
	self.WordsGenerated = {}
	
	self.spaceship = SpaceShipMover.new()
	self.TimePassed = 0
	
	self.IsDead = false
	
	self._waiting = false
	
	return self
end

--function MainGameHandler:GetRandomWord(timer)
--	if #valid_words == 0 then return end
	
--	while true do
--		local valid = true
--		local word : string = valid_words[rng:NextInteger(1, #valid_words)]
--		for _, entry in pairs(self.WordsGenerated) do
--			if word:sub(1, 1) == entry.AsteroidObject.Words[1]:sub(1, 1) then
--				valid = false
--			end
--		end

--		if valid then
--			return word
--		end
--	end
--end

function MainGameHandler:GetRandomWord(timer)
	if #valid_words == 0 then
		return nil
	end

	local usedFirstLetters = {}

	for _, entry in pairs(self.WordsGenerated) do
		local asteroid = entry.AsteroidObject
		local words = asteroid and asteroid.Words
		if not words then return end
		
		for _, word in pairs(words) do
			usedFirstLetters[word:sub(1, 1)] = true
		end
	end

	local possibleWords = {}

	for _, word in ipairs(valid_words) do
		local firstLetter = word:sub(1, 1)

		if not usedFirstLetters[firstLetter] then
			table.insert(possibleWords, word)
		end
	end

	if #possibleWords == 0 then
		return nil
	end

	return possibleWords[rng:NextInteger(1, #possibleWords)]
end

function MainGameHandler:AddLives(lives)
	if lives <= 0 or self.Lives >= MAX_HEALTH then return end

	self.Lives += lives

	for i = 1, lives do
		StatController.Health.AddHeart()
	end
end

function MainGameHandler:RemoveLives(lives)
	if lives <= 0 then return end

	local actualRemove = math.min(lives, self.Lives)
	self.Lives -= actualRemove

	for i = 1, actualRemove do
		StatController.Health.RemoveHeart()
	end
	
	SFX:WaitForChild("Damage4"):Play()
	local tweenTime = 1.3
	local distance = 7
	
	self._waiting = true
	
	EffectsHandler.Emit("SpaceshipExplode", self.spaceship.Model.StartPoint.WorldCFrame)
	
	for index, entry in ipairs(self.WordsGenerated) do
		MoveHelper.JitterUpwards(entry.Part, cam, tweenTime, distance)
	end
	
	--for index, entry in ipairs(self.WordsGenerated) do
	--	TweenService:Create(entry.AsteroidObject)
	--end
		
	--self.TimerCount = math.max(self.TimerCount - 2, 0)
	task.wait(tweenTime)
	self._waiting = false
end

local DestroyingAll = false

function MainGameHandler:DestroyAllAsteroids()
	if DestroyingAll then return end
	
	DestroyingAll = true
	for i = #self.WordsGenerated, 1, -1 do
		local entry = self.WordsGenerated[i]

		entry.AsteroidObject:Destroy()

		table.remove(self.WordsGenerated, i)
	end
	DestroyingAll = false
end

local function playTypeSound()
	local typeSound = SFX:WaitForChild("Typing"):Clone()
	typeSound.Parent = workspace
	typeSound:Play()
	typeSound.Ended:Connect(function()
		typeSound:Destroy()
	end)
end

function MainGameHandler:StartGame()
	local typer = Typer.new()
	
	StatController.Display("Word", '')
	
	PointsHandler.ResetPoints()
	PointsHandler.ResetCombo()
	PointsHandler.ResetMaxCombo()
	
	StatController.Update("Points", PointsHandler.GetPoints())
	StatController.Update("Combo", PointsHandler.GetCombo())
	
	StatController.Enable("PrevPoints")
	StatController.Enable("Points")
	StatController.Enable("Combo")
	StatController.Enable("Word")
	StatController.Enable("Health")
	
	StatController.Health.SetHealth(self.Lives, MAX_HEALTH)
	
	local pos =
		cam.CFrame.Position
		+ cam.CFrame.LookVector * 26
		+ cam.CFrame.UpVector * -14
		+ cam.CFrame.RightVector

	local cf = CFrame.new(pos)

	self.spaceship:MoveTo(cf)
	self.spaceship:SetSize(0.1)
	
	local speedTimer = 0
	local wordTimer = 0
	
	local timePassed = 0
	
	local max_word_length = 5
	
	local selectedWord
	local selectedEntry
	local selectedLabel
	local selectedIndex
	
	local comboMusic = "Intense"
	local comboFire
	
	UpdateWordList(max_word_length)
	local speedConnection = RunService.RenderStepped:Connect(function(dt)
		speedTimer+=dt
		timePassed+=dt
		if speedTimer >= Constants.SpeedUpdateTimer then
			speedTimer = 0
			self.TimerCount+=1
			
			local speed_addition = (BASE_SPEED * Constants.SpeedMultiplier) - BASE_SPEED
			local new_speed = BASE_SPEED + (speed_addition*self.TimerCount)
			self.Speed = math.clamp(new_speed, BASE_SPEED, (Constants.MaxSpeed*BASE_SPEED))
			
			local interval_addition = BASE_MAX_INTERVAL - (BASE_MAX_INTERVAL * Constants.IntervalMultiplier)
			local new_interval = BASE_MAX_INTERVAL - (interval_addition*self.TimerCount)
			self.Interval = math.clamp(new_interval, (Constants.MinInterval*BASE_MAX_INTERVAL), BASE_MAX_INTERVAL)
			print(string.format("Speed: %.2f Interval: %.2f", self.Speed, self.Interval))
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
			for index, entry in ipairs(self.WordsGenerated) do
				if not selectedWord then
					local word = entry.AsteroidObject.Words[1]
					if not word then
						entry.AsteroidObject:Destroy()
						table.remove(self.WordsGenerated, index)
					end
					
					if word:sub(1, 1) == text:sub(1, 1) then
						selectedIndex = index
						selectedWord = word
						selectedEntry = entry
						selectedLabel = entry.Part.Title:FindFirstChild(word)
						EffectsHandler.ApplyHighlight("Targetted", entry.Part)
						break
					end
					--MoveHelper.JitterUpwards(entry.Part, cam, 0.1, 0.5)
				end
			end
			
			if selectedWord and text == selectedWord then
				--//Correct//			
				--EffectsHandler.Emit("Explosion", selectedEntry.Part.CFrame)
				local found
				for _, entry in pairs(self.WordsGenerated) do
					if entry.AsteroidObject.Model == selectedEntry.AsteroidObject.Model then
						found = true
						break
					end
				end
				if not found then return end
				
				local destroyed = false
				
				selectedLabel = nil
				
				table.insert(self.WordsGuessed, {Word = selectedWord, Correct = true})
				PointsHandler.IncrementPoints(selectedWord, selectedEntry.Type.PointMultiplier)
			
				selectedEntry.AsteroidObject:DeleteFirstWord()
				
				if not next(selectedEntry.AsteroidObject.Words) then
					table.remove(self.WordsGenerated, selectedIndex)
					
					--//Emit//
					local a1 = Instance.new("Attachment", workspace.Emits)
					a1.WorldCFrame = selectedEntry.AsteroidObject.Model.CFrame
					Debris:AddItem(a1, 5)
					EffectsHandler.Emit("ElectricBurst", selectedEntry.AsteroidObject.Model.CFrame)
					EffectsHandler.EmitBeam("ElectricBeams", self.spaceship.Model.StartPoint, a1)
					EffectsHandler.Emit("GunEmit", self.spaceship.Model.StartPoint.WorldCFrame)
					
					--//Destroy//
					selectedEntry.AsteroidObject:Destroy()
					destroyed = true
				end
				
				selectedWord = nil
				selectedIndex = nil
				selectedEntry = nil
				
				playTypeSound()	
				typer:Reset()
				EffectsHandler.ResetHighlight("Targetted")
				
				local combo = PointsHandler.GetCombo()

				if destroyed then
					PointsHandler.IncrementCombo()
					combo = PointsHandler.GetCombo()
					
					StatController.Update("Points", PointsHandler.GetPoints())
					StatController.Update("Combo", combo)
				end

				--SFX:WaitForChild("grenade explosion"):Play()

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
				playTypeSound()				
				
				self.spaceship:LookAt(selectedEntry.AsteroidObject.Model.Position)
				
				local correctText, incorrectText, remainingText, excessText, noncorrectText = UIHelper.GetCorrectnessOfText(selectedWord, text)
				
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
	task.spawn(function()
		while self.Lives > 0 do
			task.wait()
		end
		
		self.IsDead = true
		typer:Stop()
		speedConnection:Disconnect()

		self:DestroyAllAsteroids()

		SFX:WaitForChild("gta-v-death-sound-effect-102"):Play()
		
		StatController.Update("PrevPoints", "Best Score: "..tostring(PointsHandler.GetBestScore()))
		StatController.Disable("Points")
		StatController.Disable("Combo")
		StatController.Disable("Word")
		StatController.Disable("Health")
		
		self.spaceship:Destroy()
		return true
	end)

	while self.Lives > 0 do
		if self.IsDead then
			break
		end
		
		while self._waiting do
			task.wait()
		end
		--local part = Instance.new("Part")
		--part.Size = Vector3.new(1, 1, 1)
		--part.Anchored = true
		--part.CanCollide = false
		--part.Material = Enum.Material.Neon
		--part.Color = Color3.fromRGB(255, 255, 255)
		--part.Parent = workspace
		
		local asteroid = Asteroid.new(self)
		
		local part = asteroid.Model
		
		part.Parent = workspace
		
		local billboard = game.ReplicatedStorage.Assets.UI.Title:Clone()
		billboard.StudsOffset = Vector3.new(0, part.Size.Y + 1, 0)
		billboard.Parent = part
		
		local words = asteroid.Words
		local word = words[1]
		
		local textBox = billboard.Name2:Clone()
		textBox.Text = word
		textBox.Name = word
		textBox.Parent = billboard
		
		billboard.Name2:Destroy()

		local xOffset = rng:NextNumber(-40, 40)

		local spawnPos =
			cam.CFrame.Position
			+ cam.CFrame.LookVector * 30
			+ cam.CFrame.UpVector * 22
			+ cam.CFrame.RightVector * xOffset
		
		--if self._waiting then
		--	Asteroid.ReachedBottom()
		--	continue
		--end
		
		part.CFrame = CFrame.new(spawnPos)
		
		local longest = ""
		for _, item in pairs(words) do
			if #item > #longest then
				longest = item
			end
		end
		
		local letterDiff = Constants.MeanSpeedWordLength - longest:len()
		local speedChange = (Constants.SpeedChangePerLetter * self.Speed) - self.Speed
		
		local correctSpeed = (self.Speed + (letterDiff * speedChange)) * asteroid.SpeedMultiplier

		correctSpeed = math.max(correctSpeed, 1)
		
		task.spawn(function()
			local reachedBottom = MoveHelper.MoveUntilOffScreen(asteroid, cam, correctSpeed)
			
			if reachedBottom then
				--//Incorrect//

				self._waiting = true
				PointsHandler.ResetCombo()
				StatController.Update("Combo", PointsHandler.GetCombo())
				EffectsHandler.RemoveParticle("Combo")
				task.spawn(function()
					self:RemoveLives(asteroid.Damage)
				end)
				
				for index, entry in ipairs(self.WordsGenerated) do
					if asteroid == entry.AsteroidObject then
						if selectedWord == word then
							selectedWord = nil
							selectedEntry = nil
							selectedLabel = nil
							selectedIndex = nil
							typer:Reset()
						end
						
						table.insert(self.WordsGuessed, {Word = entry.Word, Correct = false})
						table.remove(self.WordsGenerated, index)
						if selectedIndex then selectedIndex-=1 end
						
						entry.AsteroidObject:ReachedBottom()
						
						break
					end
				end
				
				--SFX:WaitForChild("Damage4"):Play()
				MusicService.PlayMainGameMusic()
				--StatController.Update("Points", PointsHandler.GetPoints())
				--connection:Disconnect()
			end
		end)
		
		table.insert(self.WordsGenerated, {
			Part = part,
			AsteroidObject = asteroid,
			Type = asteroid.Config
		})
		
		task.wait(rng:NextNumber(if self.Interval < BASE_MIN_INTERVAL then self.Interval else BASE_MIN_INTERVAL, self.Interval))
	end
end

function MainGameHandler.Init()
	print("[MainGameHandler] Initialised")
end

return MainGameHandler