local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local IdleAnimation = ReplicatedStorage.Asset.Animations.IdleAnimation
local PlayAnimationOn = workspace.DialogueNPC

local AnimationLogic = Knit.CreateController({ Name = "AnimationLogic" })

function AnimationLogic:KnitStart()
	local humanoid = PlayAnimationOn:FindFirstChildOfClass("Humanoid")
	local Animator = humanoid:FindFirstChild("Animator")
	if not Animator then
		return
	end

	local idleAnimTrack = Animator:LoadAnimation(IdleAnimation)
	idleAnimTrack.Looped = true
	idleAnimTrack:Play()
end

function AnimationLogic:KnitInit() end

return AnimationLogic
