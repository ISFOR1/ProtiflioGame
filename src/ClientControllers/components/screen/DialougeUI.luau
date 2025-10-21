local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local useMotion = require(ReplicatedStorage.Client.hooks.useMotion)

local e = React.createElement

local function DialogueUI(props)
	local motionBinding, motion = useMotion(props.IsVisible and 1 or 0)

	React.useEffect(function()
		local goal = props.IsVisible and 1 or 0
		motion:spring(goal, { frequency = .43, dampingRatio = 1 })
	end, { props.IsVisible, motion })

	local dialogueBoxPosition = motionBinding:map(function(val)
		return UDim2.fromScale(0.5, .7 - 0.2 * val)
	end)
	
	local groupTransparency = motionBinding:map(function(val)
		return 1 - val
	end)

	return e("Frame", {
		Size = UDim2.fromScale(.5, .5),
		Position = dialogueBoxPosition,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = groupTransparency,
		BorderSizePixel = 0,
	}, {})
end

return DialogueUI