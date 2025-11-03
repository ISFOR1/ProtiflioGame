--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--Require Modules
local TextLabel = require(ReplicatedStorage.Client.components.elements.TextLabel)
local ViewPortFrame = require(ReplicatedStorage.Client.components.elements.ViewPortFrame)
local React = require(ReplicatedStorage.Packages.React)
local SoundUtility = require(ReplicatedStorage.Client.Utility.SoundUtility)
local DialogueSignal = require(ReplicatedStorage.Client.hooks.DialogueSignal)
local useTypewriter = require(ReplicatedStorage.Client.hooks.TypingAnimations)
local useMotion = require(ReplicatedStorage.Client.hooks.useMotion)
local useUiScale = require(ReplicatedStorage.Client.Modules.ScaleProvider).useUiScale

-- Create element shorthand
local e = React.createElement

-- Dialogue Text Data
local DIALOGUE_SEQUENCE = {
	{
		text = "Hi, I'm ISFOR. I've been scripting on Roblox for 2 years and using Studio since 2021.",
		animation = "Pose1",
	},
	{
		text = "I really enjoy scripting, especially debugging and figuring out how everything works.",
		animation = "Pose2",
	},
	{
		text = "I built this map you're in for fun and as part of my portfolio. This UI you're seeing was made with React and Ripple!",
		animation = "Pose1",
	},
	{
		text = "I also prefer scripting in VS Code over Roblox Studio. I'm always learning, so who knows what I'll build next!",
		animation = "Pose2",
	},
	{
		text = "By the way, all the animations, models, and assets you see were made by me, all on my own hand.",
		animation = "Pose1",
	},
	{
		text = "This is all still just the start. I'll keep adding new things in the future... it might look totally different next time you see it!",
		animation = "Pose2",
	},
}

-- Dummy SoundService for when sound is disabled
local DummySoundService = {
	play = function() end,
	stop = function() end,
}

local function DialogueUI(props)
	-- Scaled Data from the Module Scaled Provider
	local scaleData = useUiScale()
	local scaleFactor = scaleData.uiScaleFactor

	-- SoundService from my Sound Utility
	local SoundService = props.disableSound and DummySoundService or SoundUtility

	-- Create an Motion for later use will retun 2 values: binding and motion
	local motionBinding, motion = useMotion(0)
	local dialogueIndex, setDialogueIndex = React.useState(1)
	local currentDialogue = DIALOGUE_SEQUENCE[dialogueIndex]

	-- Set the React Value
	local isVisible, setIsVisible = React.useState(false)

	local textToType = isVisible and currentDialogue.text or ""
	local soundServiceForTypewriter = isVisible and SoundService or nil
	local displayedText, isTyping, skipTyping = useTypewriter(textToType, soundServiceForTypewriter)

	local blinkBinding, setBlinkBinding = React.useBinding(1)

	-- Effect for the dialogue visible or not
	React.useEffect(function()
		local connection = DialogueSignal:Connect(function(shouldBeVisible)
			setIsVisible(shouldBeVisible)

			if shouldBeVisible then
				setDialogueIndex(1)
			end
		end)

		return function()
			if connection then
				connection:Disconnect()
			end
		end
	end, {})

	-- for the blinking text
	React.useEffect(function()
		local connection = RunService.Heartbeat:Connect(function()
			local speed = 5
			local sine = math.sin(os.clock() * speed)
			local alpha = (sine + 1) / 2
			local transparency = 0.3 + (alpha * 0.7)
			setBlinkBinding(transparency)
		end)
		return function()
			connection:Disconnect()
		end
	end, {})

	-- Animation for the PLaying opening and closing
	React.useEffect(function()
		local goal = isVisible and 1 or 0
		motion:spring(goal, { frequency = 0.43, dampingRatio = 1 })
		if isVisible then
			SoundService:play("Opening")
		end
	end, { isVisible, motion, SoundService })

	local dialogueBoxPosition = motionBinding:map(function(val)
		return UDim2.fromScale(0.5, 1.1 - 0.3 * val)
	end)
	local groupTransparency = motionBinding:map(function(val)
		return 1 - val
	end)
	local dialogueBoxRotation = motionBinding:map(function(val)
		return (1 - val) * -15
	end)

	-- CLicked function
	local function handleClick()
		SoundService:play("Clicked")
		if isTyping then
			skipTyping()
		else
			local nextIndex = dialogueIndex + 1
			if nextIndex > #DIALOGUE_SEQUENCE then
				DialogueSignal:Fire(false)
			else
				setDialogueIndex(nextIndex)
			end
		end
	end

	if not isVisible then
		return nil
	end

	return e("TextButton", {
		Size = UDim2.fromScale(0.47, 0.27),
		Position = dialogueBoxPosition,
		Rotation = dialogueBoxRotation,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("#000000"),
		BackgroundTransparency = groupTransparency:map(function(val)
			return 0.32 + val
		end),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		[React.Event.MouseButton1Click] = handleClick,
	}, {
		UICorner = e("UICorner", { CornerRadius = UDim.new(0.04, 0) }),
		UIStroke = e("UIStroke", {
			Color = Color3.fromHex("#181818"),
			Thickness = 25 * scaleFactor,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = groupTransparency,
			BorderOffset = UDim.new(0, -20 * scaleFactor),
		}),
		UIStroke2 = e("UIStroke", {
			Color = Color3.fromHex("#dadada"),
			Thickness = 6.5 * scaleFactor,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			BorderOffset = UDim.new(0, -10 * scaleFactor),
			ZIndex = 2,
			Transparency = groupTransparency,
		}),
		DilaougeText = e(TextLabel, {
			Size = UDim2.fromScale(0.5, 0.6),
			Position = UDim2.fromScale(0.57, 0.4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = displayedText,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextTransparency = groupTransparency,
			Font = Enum.Font.Gotham,
			IsStorked = false,
		}),
		ContinnueText = (not isTyping) and e(TextLabel, {
			Size = UDim2.fromScale(0.23, 0.13),
			Position = UDim2.fromScale(0.57, 0.83),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = "Click to continue...",
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextScaled = true,
			TextTransparency = blinkBinding,
			IsStorked = false,
		}) or nil,
		PortFrame = e(ViewPortFrame, {
			Size = UDim2.fromScale(0.6, 1.2),
			Position = UDim2.fromScale(0.12, 0.41),
			animationName = isVisible and currentDialogue.animation or nil,
		}),
	})
end

return DialogueUI
