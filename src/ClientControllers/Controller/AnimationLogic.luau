local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local IdleAnimation = ReplicatedStorage.Asset.Animations.IdleAnimation
local PlayAnimationOn = workspace.NPC

local AnimationLogic = Knit.CreateController { Name = "AnimationLogic" }

function AnimationLogic:KnitStart()
    local humanoid = PlayAnimationOn:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    local idleAnimTrack = humanoid:LoadAnimation(IdleAnimation)
    idleAnimTrack.Looped = true
    idleAnimTrack:Play()
end

function AnimationLogic:KnitInit()

end

return AnimationLogic