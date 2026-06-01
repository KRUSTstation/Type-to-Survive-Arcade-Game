local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AsteroidChances = require(ReplicatedStorage.Data.Asteroids:WaitForChild("AsteroidChances"))
local AsteroidTypes = require(ReplicatedStorage.Data.Asteroids:WaitForChild("AsteroidTypes"))

local Asteroid = {}
Asteroid.__index = Asteroid

local rng = Random.new()

local function SelectRandomAsteroid()
	local total = 0
	for _, rarity in pairs(AsteroidChances) do
		total += 1 / rarity
	end

	local n = rng:NextNumber()
	local counter = 0
	
	local last -- just incase cuz floating numbers suck

	for asteroid, rarity in pairs(AsteroidChances) do
		last = asteroid
		counter += 1 / rarity / total
		if n <= counter then
			return asteroid
		end
	end
	
	return last
end

function Asteroid.new(gameObject)
	local self = setmetatable({}, Asteroid)
	
	local asteroidName = SelectRandomAsteroid()
	local config = AsteroidTypes[asteroidName]
	
	self.Words = {}
	for _ = 1, config.Words do
		table.insert(self.Words, gameObject:GetRandomWord())
	end
	
	self._destroyed = false
	
	self.Game = gameObject
	
	self.Model = ReplicatedStorage.Assets.Models.Asteroids:WaitForChild(config.Model):Clone()
	self.Model.Parent = workspace
	
	self.Type = config.Type
	self.SpeedMultiplier = config.SpeedMultiplier or 1
	self.Damage = config.Damage or 1
	self.Config = config
	
	self.DistanceTravelled = 0

	return self
end

function Asteroid:DeleteFirstWord()
	if self._destroyed then return end
	
	local oldWord = self.Words[1]
	table.remove(self.Words, 1)
	
	local label = self.Model.Title[oldWord]
	if self.Words[1] then
		label.Name = self.Words[1]
		label.Text = self.Words[1]
	end
end

function Asteroid:OnReachedBottom()
	if not self.Config.OnReachedBottom or self._destroyed then return end
	
	self._destroyed = true
	self.Config.OnReachedBottom(self, self.Game)
end

function Asteroid:OnDestroyed()
	if not self.Config.OnDestroyed or self._destroyed then return end
	
	self._destroyed = true
	self.Config.OnDestroyed(self, self.Game)
end

function Asteroid:ReachedBottom()
	if self._destroyed then return end
	
	self:OnReachedBottom()
	self.Model:Destroy()
end

function Asteroid:Destroy()
	if self._destroyed then return end
	
	self:OnDestroyed()
	self.Model:Destroy()
end

return Asteroid
