local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Ripple = require(ReplicatedStorage.Packages.Ripple)
local motionLoop = require(script.MotionLoop)

local function useMotion(initialValue)
	local motion = React.useMemo(function()
		return Ripple.createMotion(initialValue)
	end, {})

	local binding, setValue = React.useBinding(initialValue)

	React.useEffect(function()
		local stepConnection = motion:onStep(setValue)
		motionLoop.registry[motion] = true

		return function()
			stepConnection:Disconnect()
			motionLoop.registry[motion] = nil
			motion:destroy()
		end
	end, { motion, setValue })

	return binding, motion
end

return useMotion