local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local React = require(Packages.React)

local e = React.createElement

-- Define your "design" aspect ratio. 16:9 is a good standard.
local DESIGN_ASPECT_RATIO = 16 / 9
-- Define a "base" height for scaling pixel values
local BASE_HEIGHT = 720

local ScaleContext = React.createContext({
	uiScaleFactor = 1,
})

local function ScaleProvider(props)
	local children = props.children

	local safeFrameRef = React.useRef(nil) -- Create a ref for the SafeFrame
	local uiScaleFactor, setUiScaleFactor = React.useState(1)

	-- Effect to watch the SafeFrame's size
	React.useEffect(function()
		local safeFrame = safeFrameRef.current
		if not safeFrame then
			return
		end

		local function updateScale()
			local safeFrameHeight = safeFrame.AbsoluteSize.Y
			if safeFrameHeight > 0 then
				setUiScaleFactor(safeFrameHeight / BASE_HEIGHT)
			else
				setUiScaleFactor(1) -- Default to 1 if not rendered
			end
		end

		updateScale() -- Run once on mount
		local connection = safeFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale)

		return function()
			connection:Disconnect()
		end
	end, { safeFrameRef })

	-- The value to be provided by the context
	local providerValue = {
		uiScaleFactor = uiScaleFactor,
	}

	-- Render the SafeFrame that provides the scaling
	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1, -- Make it invisible
		ref = safeFrameRef, -- Assign the ref
	}, {
		AspectConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = DESIGN_ASPECT_RATIO,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width,
		}),

		-- Provide the scale factor to all children
		Provider = e(ScaleContext.Provider, {
			value = providerValue,
		}, children),
	})
end

local function useUiScale()
	return React.useContext(ScaleContext)
end

return {
	Provider = ScaleProvider,
	useUiScale = useUiScale,
}
