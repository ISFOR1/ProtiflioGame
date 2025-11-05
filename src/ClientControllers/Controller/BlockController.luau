local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

--Require Script
local Knit = require(ReplicatedStorage.Packages.Knit)

--Veribales
local player = Players.LocalPlayer

local actionRotateLeft = "PushBlockRotateLeft"
local actionRotateRight = "PushBlockRotateRight"
local rotationSpeed = 180 -- Degrees per second

local BlockController = Knit.CreateController({
	Name = "BlockController",
	animTracks = {},

	-- Keep track of state
	isAttached = false,
	humanoid = nil,
	hrp = nil,
	rotateDirection = 0,
	currentRotation = 0,
	updateConnection = nil,
})

function BlockController:GetCharacterParts()
	if self.humanoid and self.hrp then
		return -- Already have them
	end

	local character = player.Character or player.CharacterAdded:Wait()
	self.humanoid = character:WaitForChild("Humanoid")
	self.hrp = character:WaitForChild("HumanoidRootPart")
end

function BlockController:PlayPushAnim(animationInstance)
	self:GetCharacterParts()
	local animator = self.humanoid:WaitForChild("Animator")

	if not animator then
		return
	end

	self:StopPushAnim() -- Stop previous, just in case

	local track
	if self.animTracks[animationInstance] then
		track = self.animTracks[animationInstance]
	else
		track = animator:LoadAnimation(animationInstance)
		self.animTracks[animationInstance] = track
	end

	track:Play()

	self.humanoid.AutoRotate = false
	self.isAttached = true
	self.currentRotation = 0 -- Reset total rotation

	-- Bind the new rotation actions
	self:BindRotationActions()

	-- Connect the update loop
	self.updateConnection = RunService.RenderStepped:Connect(function(dt)
		self:OnUpdate(dt)
	end)
end

function BlockController:StopPushAnim()
	for _, track in pairs(self.animTracks) do
		track:Stop()
	end

	if self.humanoid then
		self.humanoid.AutoRotate = true
	end
	self.isAttached = false

	-- Unbind the actions
	ContextActionService:UnbindAction(actionRotateLeft)
	ContextActionService:UnbindAction(actionRotateRight)

	-- Disconnect the update loop
	if self.updateConnection then
		self.updateConnection:Disconnect()
		self.updateConnection = nil
	end

	self.rotateDirection = 0
end

function BlockController:OnUpdate(dt)
	if self.rotateDirection == 0 or not self.hrp then
		return
	end

	-- Calculate how much to rotate this frame
	local rotateAmount = rotationSpeed * self.rotateDirection * dt
	local newRotation = self.currentRotation + rotateAmount

	-- Check if we are trying to rotate past the limit
	if newRotation > 180 or newRotation < -180 then
		-- We are at the limit, so clamp to the max and get the small remainder
		rotateAmount = math.clamp(newRotation, -180, 180) - self.currentRotation
		if rotateAmount == 0 then
			return
		end -- No rotation allowed
	end

	self.currentRotation = self.currentRotation + rotateAmount
	self.hrp.CFrame = self.hrp.CFrame * CFrame.Angles(0, math.rad(rotateAmount), 0)
end

function BlockController:BindRotationActions()
	-- Bind Left Rotation (Q, Gamepad L1, Touch Button)
	ContextActionService:BindAction(actionRotateLeft, function(_, inputState, _)
		if inputState == Enum.UserInputState.Begin then
			self.rotateDirection = 1 -- Rotate Left
		elseif inputState == Enum.UserInputState.End then
			if self.rotateDirection == 1 then
				self.rotateDirection = 0
			end
		end
	end, true, Enum.KeyCode.Q, Enum.KeyCode.ButtonL1)

	-- Bind Right Rotation (E, Gamepad R1, Touch Button)
	ContextActionService:BindAction(actionRotateRight, function(_, inputState, _)
		if inputState == Enum.UserInputState.Begin then
			self.rotateDirection = -1
		elseif inputState == Enum.UserInputState.End then
			if self.rotateDirection == -1 then
				self.rotateDirection = 0
			end
		end
	end, true, Enum.KeyCode.E, Enum.KeyCode.ButtonR1)
end

function BlockController:KnitStart()
	local MainService = Knit.GetService("MainService")

	MainService.Animate:Connect(function(command, animationInstance)
		if command == "Play" then
			self:PlayPushAnim(animationInstance)
		elseif command == "Stop" then
			self:StopPushAnim()
		end
	end)
end

function BlockController:KnitInit() end

return BlockController
