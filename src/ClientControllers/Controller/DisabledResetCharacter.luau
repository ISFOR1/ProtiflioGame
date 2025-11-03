local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local StarterGui = game:GetService("StarterGui")

local DisabledResetCharacter = Knit.CreateController({ Name = "DisabledResetCharacter" })

function DisabledResetCharacter:KnitStart()
	task.spawn(function()
		local success = false
		while not success do
			success = pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", false)
			if not success then
				task.wait(0.1)
			end
		end
	end)
end

function DisabledResetCharacter:KnitInit() end

return DisabledResetCharacter
