local ReplicatedStorage = game:GetService("ReplicatedStorage")

local soundsFolder = ReplicatedStorage:WaitForChild("Asset"):WaitForChild("Sounds")

local SoundService = {}
SoundService.sounds = {}

for _, sound in ipairs(soundsFolder:GetChildren()) do
	if not sound:IsA("Sound") then
		continue
	end

	local action = sound:GetAttribute("SoundAction")
	if action then
		SoundService.sounds[action] = sound
	end
end

function SoundService:play(actionName: string)
	local sound = self.sounds[actionName]
	if not sound then
		return
	end

	task.spawn(function()
		local soundClone = sound:Clone()
		soundClone.Parent = workspace

		soundClone:Play()
		soundClone.Ended:Wait()
		soundClone:Destroy()
	end)
end

return SoundService
