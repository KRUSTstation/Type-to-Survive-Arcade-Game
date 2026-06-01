local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local musicFolder = SoundService:WaitForChild("BackgroundMusic")

local MusicService = {}

local tweenTime = 1

MusicService.ActiveSong = nil
MusicService.Paused = false

local changingSong = false

function MusicService.GetSoundByName(name)
	return musicFolder:FindFirstChild(name)
end

function MusicService.PlaySong(song)
	song = (typeof(song) == "Instance" and song:IsA("Sound")) and song or MusicService.GetSoundByName(song)
	
	if not song or not song:IsA("Sound") then
		warn("[MusicService] PlaySong expected a Sound")
		return
	end

	while changingSong do
		task.wait(0.1)
	end

	if MusicService.ActiveSong == song then
		return
	end

	changingSong = true
	if MusicService.ActiveSong then
		local oldSong = MusicService.ActiveSong
		local tween = TweenService:Create(oldSong, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Volume = 0})
		tween:Play()
		task.wait(tweenTime/2)
		task.spawn(function()
			tween.Completed:Wait()
			oldSong:Stop()
		end)
	end

	MusicService.ActiveSong = song
	local tween = TweenService:Create(song, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Volume = 1})
	song.Volume = 0
	song:Play()
	tween:Play()
	changingSong = false
end

function MusicService.Pause()
	while changingSong do
		task.wait(0.1)
	end

	if not MusicService.ActiveSong or MusicService.Paused then
		return
	end

	changingSong = true

	task.spawn(function()
		local song = MusicService.ActiveSong
		local tween = TweenService:Create(song, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Volume = 0})
		tween:Play()
		tween.Completed:Wait()
		song:Stop()

		MusicService.Paused = true
		changingSong = false
	end)
	return
end

function MusicService.Resume()
	while changingSong do
		task.wait(0.1)
	end

	if not MusicService.ActiveSong or not MusicService.Paused then
		return
	end

	changingSong = true

	task.spawn(function()
		local song = MusicService.ActiveSong
		song:Play()
		local tween = TweenService:Create(song, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Volume = 1})
		tween:Play()
		tween.Completed:Wait()

		MusicService.Paused = false
		changingSong = false
	end)
	return
end

function MusicService.PlayMenuMusic()
	MusicService.PlaySong("Intense Darkness")
end

function MusicService.PlayMainGameMusic()
	MusicService.PlaySong("Calm Morning")
end

function MusicService.Init()
	for _, sound in ipairs(musicFolder:GetChildren()) do
		if sound:IsA("Sound") then
			sound.Looped = true
			sound:Stop()
		end
	end
	
	MusicService.PlayMenuMusic()

	print("[MusicService] Initialised")
end

return MusicService
