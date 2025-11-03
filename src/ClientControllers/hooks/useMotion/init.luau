local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Ripple = require(ReplicatedStorage.Packages.Ripple)
local motionLoop = require(script.MotionLoop)

local function useMotion(initialValue)
	-- Use the React Memo To Return the Motion Memo Present As A Map
	local motion = React.useMemo(function()
		return Ripple.createMotion(initialValue)
	end, {})

	-- Bind it as initialValue
	local binding, setValue = React.useBinding(initialValue)

	-- Render it Using the .useEffect
	React.useEffect(function()
		local stepConnection = motion:onStep(setValue)
		motionLoop.registry[motion] = true

		return function()
			-- Calling stepConection
			stepConnection()
			-- Pass Nil to Prevent Memory Leak
			motionLoop.registry[motion] = nil
			-- Also Destroyed it
			motion:destroy()
		end
	end, { motion, setValue })

	return binding, motion
end

return useMotion
