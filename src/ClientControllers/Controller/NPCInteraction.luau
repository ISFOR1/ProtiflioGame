local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local DialogueSignal = require(game:GetService("ReplicatedStorage").Client.hooks.DialogueSignal)

local NPCInteractionController = Knit.CreateController({
	Name = "NPCInteractionController",
})

function NPCInteractionController:KnitStart()
	local npcModel = workspace:WaitForChild("DialogueNPC")

	local highlight = Instance.new("Highlight")
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0.1
	highlight.Enabled = false
	highlight.Parent = npcModel

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Talk"
	prompt.ObjectText = "ISFOR"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = 5
	prompt.RequiresLineOfSight = false
	prompt.Parent = npcModel

	self.promptShownConn = prompt.PromptShown:Connect(function()
		highlight.Enabled = true
	end)

	self.promptHiddenConn = prompt.PromptHidden:Connect(function()
		highlight.Enabled = false
	end)

	self.promptTriggeredConn = prompt.Triggered:Connect(function(playerWhoTriggered)
		if playerWhoTriggered == Knit.Player then
			self:OnNPCInteracted()
		end
	end)
end

function NPCInteractionController:OnNPCInteracted()
	DialogueSignal:Fire(true)
	return true
end

function NPCInteractionController:KnitStop()
	if self.promptTriggeredConn then
		self.promptTriggeredConn:Disconnect()
		self.promptTriggeredConn = nil
	end
	if self.promptShownConn then
		self.promptShownConn:Disconnect()
		self.promptShownConn = nil
	end
	if self.promptHiddenConn then
		self.promptHiddenConn:Disconnect()
		self.promptHiddenConn = nil
	end
end

return NPCInteractionController
