local SpawnsFolder = workspace.MainMap:WaitForChild("Spawns")
local knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")

local SpawningManager = knit.CreateService({
	Name = "SpawningManager",
})
function SpawningManager:KnitStart()
	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function(character)
			local Hrp = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.JumpHeight = 0
			end
			if not Hrp then
				return
			end
			local spawnPoints = SpawnsFolder:GetChildren()
			if #spawnPoints == 0 then
				return
			end
			local chosenSpawn = spawnPoints[math.random(1, #spawnPoints)]
			Hrp.CFrame = chosenSpawn.CFrame + Vector3.new(0, 5, 0)
		end)
	end)
end

function SpawningManager:KnitInit() end

return SpawningManager
