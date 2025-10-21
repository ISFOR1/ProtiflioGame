local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])
local DialogueUI = require(ReplicatedStorage.Client.components.screen.DialougeUI)

local e = React.createElement

return function(target)
	local function StoryWrapper()
		local visible, setVisible = React.useState(false)

		return e(React.Fragment, {}, {
			ToggleButton = e("TextButton", {
				Size = UDim2.fromOffset(150, 50),
				Position = UDim2.fromScale(0.1, 0.1),
				AnchorPoint = Vector2.new(0, 0),
				Text = "Toggle Dialogue",
				[React.Event.MouseButton1Click] = function()
					setVisible(not visible)
				end,
			}),
			Dialogue = e(DialogueUI, {
				IsVisible = visible,
				OnButtonClicked = function()
					print("DialogueUI internal button clicked!")
				end,
			}),
		})
	end

	local root = ReactRoblox.createRoot(Instance.new("Folder"))

	root:render(ReactRoblox.createPortal(e(StoryWrapper), target))

	return function()
		root:unmount()
	end
end

