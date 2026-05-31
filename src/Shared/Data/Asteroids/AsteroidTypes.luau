local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectsHandler = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("EffectsHandler"))

local SFX = ReplicatedStorage.Assets.SFX

local function DefaultDestroy(model, gameObj, noVFX)
	
	if not noVFX then EffectsHandler.Emit("Explosion", model.CFrame) end
	SFX:WaitForChild("grenade explosion"):Play()
end

local function DefaultReachedBottom(model, gameObj)
	
end

local AsteroidTypes = {
	Normal = {	-- example data
		Model = "Normal",
		Damage = 1, -- the damage when it reaches the bottom
		Words = 1,
		SpeedMultiplier = 1,
		PointMultiplier = 1,
		OnDestroyed = function(asteroid, gameObj)
			DefaultDestroy(asteroid.Model, gameObj)
		end,
		OnReachedBottom = function(asteroid, gameObj)
			DefaultReachedBottom(asteroid.Model, gameObj)
		end,
	},
	
	Cash = {
		Model = "Cash",
		Damage = 1,
		Words = 1,
		SpeedMultiplier = 1,
		PointMultiplier = 3,
		OnDestroyed = function(asteroid, gameObj)
			EffectsHandler.Emit('CashExplosion', asteroid.Model.CFrame)
			SFX:WaitForChild("Cash"):Play()
			DefaultDestroy(asteroid.Model, gameObj, true)
		end,
		OnReachedBottom = function(asteroid, gameObj)
			DefaultReachedBottom(asteroid.Model, gameObj)
		end,
	},
	
	Big = {
		Model = "Big",
		Damage = 1,
		Words = 2,
		SpeedMultiplier = 0.7,
		PointMultiplier = 1,
		OnDestroyed = function(asteroid, gameObj)
			DefaultDestroy(asteroid.Model, gameObj)
		end,
		OnReachedBottom = function(asteroid, gameObj)
			DefaultReachedBottom(asteroid.Model, gameObj)
		end,
	},
	
	Speedy = {
		Model = "Speedy",
		Damage = 1,
		Words = 1,
		SpeedMultiplier = 1.5,
		PointMultiplier = 2,
		OnDestroyed = function(asteroid, gameObj)
			EffectsHandler.Emit('SpeedExplosion', asteroid.Model.CFrame)
			SFX:WaitForChild("Speedy"):Play()
			DefaultDestroy(asteroid.Model, gameObj, true)
		end,
		OnReachedBottom = function(asteroid, gameObj)
			DefaultReachedBottom(asteroid.Model, gameObj)
		end,
	},
	
	Health = {
		Model = "Health",
		Damage = 1,
		Words = 1,
		SpeedMultiplier = 0.8,
		PointMultiplier = 1,
		OnDestroyed = function(asteroid, gameObj)
			EffectsHandler.Emit('HealthExplosion', asteroid.Model.CFrame)
			SFX:WaitForChild("Health"):Play()
			DefaultDestroy(asteroid.Model, gameObj, true)
			gameObj:AddLives(1)
		end,
		OnReachedBottom = function(asteroid, gameObj)
			DefaultReachedBottom(asteroid.Model, gameObj)
		end,
	},
	
	Explosive = {
		Model = "Explosive",
		Damage = 2,
		Words = 2,
		SpeedMultiplier = 0.5,
		PointMultiplier = 1,
		OnDestroyed = function(asteroid, gameObj)
			EffectsHandler.Emit("BigExplosion", asteroid.Model.CFrame)
			SFX:WaitForChild("big explosion"):Play()
			
			gameObj:DestroyAllAsteroids()
			if asteroid.DistanceTravelled > 0.7 then
				gameObj:RemoveLives(1)
			end
		end,
		OnReachedBottom = function(asteroid, gameObj)
			DefaultReachedBottom(asteroid.Model, gameObj)
		end,
	},
	
	God = {
		Model = "God",
		Damage = 2,
		Words = 3,
		SpeedMultiplier = 0.3,
		PointMultiplier = 5,
		OnDestroyed = function(asteroid, gameObj)
			DefaultDestroy(asteroid.Model, gameObj)
			gameObj:AddLives(1)
		end,
		OnReachedBottom = function(asteroid, gameObj)
			DefaultReachedBottom(asteroid.Model, gameObj)
		end,
	},
}

return AsteroidTypes
