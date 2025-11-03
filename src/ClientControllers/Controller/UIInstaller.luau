local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local React = require(Packages.React)
local ReactRoblox = require(Packages["react-roblox"])
local DialogueUI = require(ReplicatedStorage.Client.components.screen.DialougeUI)
local ScaleProvider = require(ReplicatedStorage.Client.Modules.ScaleProvider)

local e = React.createElement

local function App()
	local screenGuiRef = React.useRef(nil)

	return e("ScreenGui", {
		ref = screenGuiRef,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
	}, {
		SafeFrameProvider = e(ScaleProvider.Provider, {}, {
			Dialogue = e(DialogueUI, {}),
		}),
	})
end

local UIInstaller = Knit.CreateController({
	Name = "UIInstaller",
})

function UIInstaller:KnitStart()
	local posesFolder = ReplicatedStorage:WaitForChild("Asset"):WaitForChild("Animations"):WaitForChild("Poses")
	local animationsToLoad = {}

	for _, anim in ipairs(posesFolder:GetChildren()) do
		if anim:IsA("Animation") then
			table.insert(animationsToLoad, anim)
		end
	end
	pcall(ContentProvider.PreloadAsync, ContentProvider, animationsToLoad)

	self.root = ReactRoblox.createRoot(Instance.new("Folder"))
	self.root:render(ReactRoblox.createPortal(e(App), playerGui))
end

function UIInstaller:KnitStop()
	if self.root then
		self.root:unmount()
	end
end

return UIInstaller
