local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local VFX = ReplicatedStorage.Assets.VFX

local EffectsHandler = {}

--//Emits//
function EffectsHandler.Emit(name, cframe)
	local effect = VFX.Emits:FindFirstChild(name)
	if not effect then return end
	
	local clone = effect:Clone()
	clone.CFrame = cframe
	clone.Parent = workspace.Emits
	
	Debris:AddItem(clone, 5)
	for i, v in ipairs(clone:GetDescendants()) do
		if not v:IsA("ParticleEmitter") then continue end
	
		task.spawn(function()
			task.wait(v:GetAttribute("EmitDelay"))

			v.Enabled = true

			task.delay(v:GetAttribute("EmitDuration"), function()
				v.Enabled = false
			end)

			v:Emit(v:GetAttribute("EmitCount"))
		end)
	end
end

function EffectsHandler.EmitBeam(folderName, a0, a1)
	local folder = VFX.Emits:FindFirstChild(folderName)
	if not folder then return end
	
	local beams = folder:GetDescendants()
	for _, beam in pairs(beams) do
		if beam:IsA("Beam") then
			task.spawn(function()
				local clone = beam:Clone()
				clone.Parent = workspace.Emits
				Debris:AddItem(clone, 5)
				
				clone.Attachment0 = a0
				clone.Attachment1 = a1
				
				task.wait(clone:GetAttribute("EmitDelay"))

				clone.Enabled = true

				task.delay(clone:GetAttribute("EmitDuration"), function()
					clone.Enabled = false
				end)
			end)
		end
	end
end

--//Particles//
function EffectsHandler.DebrisParticle(name, timePlayed)
	local effect = VFX.Particles:FindFirstChild(name)
	if not effect then return end
	
	local clone = effect:Clone()
	clone.Parent = workspace
	
	Debris:AddItem(clone, timePlayed)
end

function EffectsHandler.ChangeParticleSpeed(model: Model, speed)
	for _, attachment in pairs(model:GetChildren()) do
		for _, particle in pairs(attachment:GetChildren()) do
			if particle:IsA("ParticleEmitter") then
				particle.TimeScale = speed
			end
		end
	end
end

function EffectsHandler.ApplyParticle(name)
	local particle = VFX.Particles:FindFirstChild(name)
	if not particle then return end
	
	local clone = particle:Clone()
	
	clone.Parent = workspace.Particles
end

function EffectsHandler.RemoveParticle(name)
	local particle = workspace.Particles:FindFirstChild(name)
	if not particle then return end
	
	particle:Destroy()
end

--//Highlights//
function EffectsHandler.ApplyHighlight(name, part)
	local highlight = VFX.Highlights:FindFirstChild(name)
	if not highlight then return end
	
	highlight.Adornee = part
end

function EffectsHandler.ResetHighlight(name)
	local highlight = VFX.Highlights:FindFirstChild(name)
	if not highlight then return end

	highlight.Adornee = nil
end

return EffectsHandler
