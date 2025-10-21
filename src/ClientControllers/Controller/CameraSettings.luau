local Knit = require(game.ReplicatedStorage.Packages.Knit)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local CameraController = Knit.CreateController({
	Name = "CameraController",
})

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local hrp = nil
local renderConn: RBXScriptConnection? = nil

local cameraOffset = Vector3.new(0, 20, 0)

function CameraController:_onRenderStepped()
	if not hrp or not hrp.Parent then
		return
	end
	local hrpPos = hrp.Position
	local cameraPos = hrpPos + cameraOffset

	camera.CFrame = CFrame.lookAt(cameraPos, hrpPos)
end

function CameraController:_onCharacterAdded(character: Model)
	--styelua: ingore
	hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")

	camera.CameraSubject = humanoid
	self:enableFixedCam()
end

function CameraController:enableFixedCam()
	camera.CameraType = Enum.CameraType.Scriptable

	renderConn = RunService.RenderStepped:Connect(function()
		self:_onRenderStepped()
	end)
end

function CameraController:disableFixedCam()
	if not renderConn then
		return
	end
	renderConn:Disconnect()
	renderConn = nil

	camera.CameraType = Enum.CameraType.Custom
end

function CameraController:KnitStart()
	player.CharacterAdded:Connect(function(character)
		self:_onCharacterAdded(character)
	end)

	player.CharacterRemoving:Connect(function()
		hrp = nil
	end)

	if player.Character then
		self:_onCharacterAdded(player.Character)
	end
end

function CameraController:KnitInit() end

return CameraController
