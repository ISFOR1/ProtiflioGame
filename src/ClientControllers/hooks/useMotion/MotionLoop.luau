local RunService = game:GetService("RunService")

local loop = {}
-- Registry is weak-keyed. If a motion object is GC'd unexpectedly,
-- it won't be held in memory by this table.
loop.registry = setmetatable({}, { __mode = "k" })

RunService.Heartbeat:Connect(function(dt)
	if not next(loop.registry) then return end

	for motion in pairs(loop.registry) do
		motion:step(dt)
	end
end)

return loop