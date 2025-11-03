local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Rig = ReplicatedStorage.Asset.Models.Rig
local Poses = ReplicatedStorage:WaitForChild("Asset"):WaitForChild("Animations"):WaitForChild("Poses")

local e: typeof(React.createElement) = React.createElement

-- Viewport Elments and also the animation Names
export type VierPortFrameProps = {
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundColor3: Color3?,
	BackgroundTransparency: number?,
	BorderSizePixel: number?,
	AmbientColor: Color3?,
	LighColor: Color3?,
	LightDirection: Vector3?,
	IsCorner: boolean?,
	CornerRadius: UDim?,
	animationName: string?,
}

local function ViewPortFrame(props: VierPortFrameProps)
	-- initialValue with nil
	local viewportRef = React.useRef(nil)
	local rigClone, setRigClone = React.useState(nil)
	local isRigReady, setIsRigReady = React.useState(false)
	local animTrackRef = React.useRef(nil)
	local stoppedConnectionRef = React.useRef(nil)

	local camera = React.useMemo(function()
		return Instance.new("Camera")
	end, {})

	-- for the dummy to showed up and playing the animations
	React.useEffect(function()
		local viewportInstance = viewportRef.current
		if not viewportInstance then
			return
		end

		-- if the rig ready or not
		setIsRigReady(false)

		local clonedRigInstance = Rig:Clone()
		local rootPart = clonedRigInstance:FindFirstChild("HumanoidRootPart")
		local humanoid = clonedRigInstance:FindFirstChildOfClass("Humanoid")

		if not rootPart or not humanoid then
			clonedRigInstance:Destroy()
			return
		end

		local worldModel = Instance.new("WorldModel")
		worldModel.Parent = viewportInstance
		clonedRigInstance.Parent = worldModel

		setRigClone(clonedRigInstance)
		setIsRigReady(true)

		local _, size = clonedRigInstance:GetBoundingBox()
		local cameraOffset = size.Magnitude + -3.2
		local rootPos = rootPart.Position

		local cameraPos = rootPos + Vector3.new(0, -0.9, cameraOffset)
		camera.CFrame = CFrame.lookAt(cameraPos, rootPos)
		clonedRigInstance:SetPrimaryPartCFrame(rootPart.CFrame * CFrame.Angles(0, math.rad(112), 0))

		return function()
			if stoppedConnectionRef.current then
				stoppedConnectionRef.current:Disconnect()
				stoppedConnectionRef.current = nil
			end
			if animTrackRef.current then
				animTrackRef.current:Stop()
				animTrackRef.current = nil
			end
			if clonedRigInstance then
				clonedRigInstance:Destroy()
			end
			setRigClone(nil)
			setIsRigReady(false)
		end
	end, { viewportRef, camera })

	React.useEffect(function()
		if stoppedConnectionRef.current then
			stoppedConnectionRef.current:Disconnect()
			stoppedConnectionRef.current = nil
		end

		-- nothings?? retun nothings
		if not isRigReady or not props.animationName or not rigClone then
			return
		end

		local humanoid = rigClone:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

		if animTrackRef.current then
			animTrackRef.current:Stop()
		end
		animTrackRef.current = nil

		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			track:Stop()
		end

		local anim = Poses:FindFirstChild(props.animationName)

		if anim and anim:IsA("Animation") then
			local track = animator:LoadAnimation(anim)
			animTrackRef.current = track
			track.Looped = false
			track:AdjustSpeed(1)
			track:Play()

			stoppedConnectionRef.current = track.Stopped:Connect(function()
				if animTrackRef.current ~= track then
					return
				end

				local endAnimName
				if props.animationName == "Pose1" then
					endAnimName = "End1"
				elseif props.animationName == "Pose2" then
					endAnimName = "End2"
				end
				if endAnimName then
					local endAnim = Poses:FindFirstChild(endAnimName)
					if endAnim and endAnim:IsA("Animation") then
						track:Stop()

						local endTrack = animator:LoadAnimation(endAnim)
						animTrackRef.current = endTrack
						endTrack.Looped = true
						endTrack:Play()
					else
						-- warn message for debuing
						warn("Could not find end animation:", endAnimName)
					end
				end
			end)
		else
			-- warn message for debuing
			warn("Could not find animation:", props.animationName)
		end
	end, { props.animationName, rigClone, isRigReady })

	return e("ViewportFrame", {
		ref = viewportRef,
		Size = props.Size or UDim2.fromScale(0, 0),
		Position = props.Position or UDim2.fromScale(0, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = props.BackgroundTransparency or 1,
		BorderSizePixel = props.BorderSizePixel or 0,
		CurrentCamera = camera,
		Ambient = props.AmbientColor or Color3.fromRGB(255, 255, 255),
		LightColor = props.LighColor or Color3.fromRGB(255, 255, 255),
		LightDirection = props.LightDirection or Vector3.new(-1, -1, -1),
	}, {
		UICorner = if props.IsCorner
			then e("UICorner", {
				CornerRadius = props.CornerRadius or UDim.new(0.04, 0),
			})
			else nil,
	})
end

return ViewPortFrame
