local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)
local ReactRoblox = require(Packages["react-roblox"])
local DialogueUI = require(ReplicatedStorage.Client.components.screen.DialougeUI)
local DialogueSignal = require(ReplicatedStorage.Client.hooks.DialogueSignal)
local ScaleProvider = require(ReplicatedStorage.Client.Modules.ScaleProvider)

local e = React.createElement

return function(target)
	local function StoryWrapper()
		React.useEffect(function()
			DialogueSignal:Fire(true)
			return function()
				DialogueSignal:Fire(false)
			end
		end, {})

		return e(ScaleProvider.Provider, {}, {
			Dialogue = e(DialogueUI, {
				disableSound = true,
			}),
		})
	end

	--Mount the story to the target
	local root = ReactRoblox.createRoot(Instance.new("Folder"))

	-- Render it on the screen of the target
	root:render(ReactRoblox.createPortal(e(StoryWrapper), target))

	-- somethings goes wrong unmount it
	return function()
		root:unmount()
	end
end

