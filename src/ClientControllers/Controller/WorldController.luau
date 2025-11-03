local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local SoundService = require(ReplicatedStorage.Client.Utility.SoundUtility)

local WorldController = Knit.CreateController({
	Name = "WorldController",
})

local doorStates = {} -- Keep track of doors that are already open
local doorGoals = {} -- Store original CFrame

function WorldController:AnimateDoor(door, soundName)
	if doorStates[door] then
		return
	end
	doorStates[door] = true

	SoundService:play(soundName)

	if not doorGoals[door] then
		doorGoals[door] = door.CFrame
	end

	local goalCFrame = doorGoals[door] * CFrame.new(0, 10, 0)

	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(door, tweenInfo, { CFrame = goalCFrame })
	tween:Play()
end

function WorldController:AnimateBlockPlacement(block, targetPosition, soundName)
	block.Anchored = true
	block.CanCollide = false

	local spinUpPos = targetPosition + Vector3.new(0, 8, 0)
	local spinAngle = CFrame.Angles(0, math.rad(360), 0)

	local tweenInfoUp = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenUp = TweenService:Create(block, tweenInfoUp, {
		CFrame = CFrame.new(spinUpPos) * spinAngle,
	})

	local tweenInfoDown = TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	local tweenDown = TweenService:Create(block, tweenInfoDown, {
		CFrame = CFrame.new(targetPosition),
	})

	-- Play the sound when it's about to slam
	tweenUp.Completed:Connect(function()
		SoundService:play(soundName)
		tweenDown:Play()
	end)

	tweenDown.Completed:Connect(function()
		-- Set final properties
		block.CFrame = CFrame.new(targetPosition)
		block.CanCollide = true
	end)

	tweenUp:Play()
end

function WorldController:OnEndGame()
	print("Client received EndGame signal!")
	SoundService:play("GameCompleteSound")
end

function WorldController:KnitStart()
	local MainService = Knit.GetService("MainService")

	-- Listen for the signal from the server
	MainService.AnimateObject:Connect(function(object, animationName, arg1, arg2)
		if animationName == "DoorOpen" and object:IsA("BasePart") then
			-- arg1 is soundName
			self:AnimateDoor(object, arg1)
		elseif animationName == "PlaceBlock" and object:IsA("BasePart") then
			-- arg1 is targetPosition (Vector3)
			-- arg2 is soundName
			self:AnimateBlockPlacement(object, arg1, arg2)
		end
	end)

	-- Listen for the end game signal
	MainService.EndGame:Connect(function()
		self:OnEndGame()
	end)
end

return WorldController
