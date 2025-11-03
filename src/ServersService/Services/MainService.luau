--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

--Require Script
local Knit = require(ReplicatedStorage.Packages.Knit)

--Veribales
local MainMap = workspace.MainMap
local Blocks = MainMap.Blocks
local BlocksHitboxes = MainMap.BlocksHitBoxes
local BlockAnimFolder = ReplicatedStorage.Asset.Animations.BlockAnimations
local PushAnimation = BlockAnimFolder.PushAnimations

local PlacingStands = MainMap.PlacingStand

local MainService = Knit.CreateService({
	Name = "MainService",
	Client = {
		Animate = Knit.CreateSignal(),
		AnimateObject = Knit.CreateSignal(),
		EndGame = Knit.CreateSignal(),
	},

	blockMap = {},
	hitboxMap = {},
	doorMap = {},
	doorHitboxMap = {},
	endDoors = {},

	placementHitboxMap = {},
	placementStandMap = {},

	placedBlocks = {},
	totalBlocksToPlace = 0,

	playerAttachments = {},
	overlapParams = OverlapParams.new(),
})

function MainService:MapAssets()
	for _, part in pairs(Blocks:GetChildren()) do
		local order = part:GetAttribute("Order")
		if order then
			self.blockMap[order] = part
		end
	end

	for _, part in pairs(BlocksHitboxes:GetChildren()) do
		local order = part:GetAttribute("Order")
		if order and part:HasTag("DetectedHitboxes") then
			self.hitboxMap[order] = part
		end
	end

	for _, door in pairs(CollectionService:GetTagged("Doors")) do
		local order = door:GetAttribute("DetectedCharacterOrder")
		if order then
			self.doorMap[order] = door
		end
	end

	for _, hitbox in pairs(CollectionService:GetTagged("DetectedCharacter")) do
		local order = hitbox:GetAttribute("DetectedCharacterOrder")
		if order then
			self.doorHitboxMap[order] = hitbox
		end
	end

	for _, door in pairs(CollectionService:GetTagged("EndDoor")) do
		table.insert(self.endDoors, door)
	end

	print("Mapping placement zones...")
	for _, stand in pairs(PlacingStands:GetChildren()) do
		local order = stand:GetAttribute("PlaceOrder")
		if order then
			self.placementStandMap[order] = stand
		end
	end

	for _, hitbox in pairs(CollectionService:GetTagged("PlacementHitboxes")) do
		local order = hitbox:GetAttribute("PlaceOrder")
		if order then
			self.placementHitboxMap[order] = hitbox
			self.totalBlocksToPlace += 1
		end
	end
	print("Total blocks to place:", self.totalBlocksToPlace)

	local playerCharacters = {}
	self.overlapParams.FilterType = Enum.RaycastFilterType.Include
	self.overlapParams.FilterDescendantsInstances = playerCharacters
end

function MainService:OnHeartbeat()
	local players = Players:GetPlayers()

	local characters = {}
	for _, player in pairs(players) do
		if player.Character then
			table.insert(characters, player.Character)
		end
	end
	self.overlapParams.FilterDescendantsInstances = characters

	for _, player in pairs(players) do
		local character = player.Character
		if not character or not character.PrimaryPart then
			continue
		end

		local attachment = self.playerAttachments[player.UserId]

		if attachment then
			-- Player is holding a block. Check for PLACEMENT
			local order = attachment.order
			local placeHitbox = self.placementHitboxMap[order]

			if placeHitbox and not self.placedBlocks[order] then
				local partsInside = workspace:GetPartsInPart(placeHitbox, self.overlapParams)
				local isPlayerTouching = false
				for _, part in pairs(partsInside) do
					if part.Parent == character then
						isPlayerTouching = true
						break
					end
				end

				if isPlayerTouching then
					self:PlaceBlock(player, order)
				end
			end
		else
			-- Player is NOT holding a block. Check for PICKUP.
			local isTouchingHitbox = false
			local touchedOrder = nil
			for order, hitbox in pairs(self.hitboxMap) do
				if not self.placedBlocks[order] then
					local partsInside = workspace:GetPartsInPart(hitbox, self.overlapParams)
					if #partsInside > 0 then
						for _, part in pairs(partsInside) do
							if part.Parent == character then
								isTouchingHitbox = true
								touchedOrder = order
								break
							end
						end
					end
				end
				if isTouchingHitbox then
					break
				end
			end

			if isTouchingHitbox then
				self:AttachBlock(player, touchedOrder)
			end
		end
	end
end

function MainService:PlaceBlock(player, order)
	local attachment = self.playerAttachments[player.UserId]
	if not attachment or not self.placementStandMap[order] then
		return
	end

	local block = attachment.block
	local stand = self.placementStandMap[order]

	print("Placing block for order:", order)

	self:DetachBlock(player)

	self.placedBlocks[order] = true

	self.Client.AnimateObject:FireAll(block, "PlaceBlock", stand.Position, "PlaceSound")

	self:CheckForAllBlocksPlaced()
end

function MainService:CheckForAllBlocksPlaced()
	local placedCount = 0
	for _ in pairs(self.placedBlocks) do
		placedCount += 1
	end

	print("Placed", placedCount, "/", self.totalBlocksToPlace, "blocks")

	if placedCount == self.totalBlocksToPlace then
		print("All blocks placed! Opening final doors.")

		-- Open all doors tagged 'EndDoor'
		for _, door in pairs(self.endDoors) do
			self.Client.AnimateObject:FireAll(door, "DoorOpen", "DoorOpenSound")
		end
	end
end

function MainService:AttachBlock(player, order)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local torso = character and character:FindFirstChild("Torso")

	local blockToAttach = self.blockMap[order]
	if not blockToAttach then
		return
	end

	print("Attaching block for player:", player.Name)

	blockToAttach.Anchored = false

	local motor = Instance.new("Motor6D")
	motor.Part0 = torso
	motor.Part1 = blockToAttach

	local torsoSizeZ = torso.Size.Z
	local blockSizeZ = blockToAttach.Size.Z
	local blockSizeY = blockToAttach.Size.Y

	local offsetZ = -((torsoSizeZ / 2) + (blockSizeZ / 2) + 0.5)
	local offsetY = blockSizeY / 2

	motor.C0 = CFrame.new(0, offsetY, offsetZ)
	motor.Parent = torso

	humanoid.WalkSpeed = 5

	self.playerAttachments[player.UserId] = {
		block = blockToAttach,
		motor = motor,
		order = order,
	}

	self.Client.Animate:Fire(player, "Play", PushAnimation)
end

function MainService:DetachBlock(player)
	local attachment = self.playerAttachments[player.UserId]
	if not attachment then
		return
	end

	print("Detaching block for player:", player.Name)

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if attachment.motor then
		attachment.motor:Destroy()
	end

	local block = attachment.block
	if block and not self.placedBlocks[attachment.order] then
		block.Anchored = true
	end

	if humanoid then
		humanoid.WalkSpeed = 16
	end

	self.playerAttachments[player.UserId] = nil

	self.Client.Animate:Fire(player, "Stop")
end

function MainService:OnDoorHitboxTouched(hitbox, otherPart)
	local character = otherPart.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	local attachment = self.playerAttachments[player.UserId]
	if not attachment then
		return
	end

	local requiredOrder = hitbox:GetAttribute("DetectedCharacterOrder")
	if not requiredOrder then
		return
	end

	if attachment.order == requiredOrder then
		local door = self.doorMap[requiredOrder]
		-- Make sure this isn't an EndDoor
		if door and not door:HasTag("EndDoor") then
			print("Opening door for order:", requiredOrder)
			self.Client.AnimateObject:FireAll(door, "DoorOpen", "DoorOpenSound")
		end
	end
end

function MainService:OnEndHitboxTouched(otherPart)
	local character = otherPart.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	local placedCount = 0
	for _ in pairs(self.placedBlocks) do
		placedCount += 1
	end

	-- Only end the game if all blocks are placed
	if placedCount == self.totalBlocksToPlace then
		print("Player", player.Name, "has finished the game!")
		self.Client.EndGame:Fire(player)
		player:Kick("thanks for playing this all i have now cya next time!!!!!! :D")
	end
end

function MainService:KnitStart()
	self:MapAssets()

	RunService.Heartbeat:Connect(function()
		self:OnHeartbeat()
	end)

	for order, hitbox in pairs(self.doorHitboxMap) do
		hitbox.Touched:Connect(function(otherPart)
			self:OnDoorHitboxTouched(hitbox, otherPart)
		end)
	end

	for _, hitbox in pairs(CollectionService:GetTagged("EndHitbox")) do
		print("Connected EndHitbox")
		hitbox.Touched:Connect(function(otherPart)
			self:OnEndHitboxTouched(otherPart)
		end)
	end

	Players.PlayerRemoving:Connect(function(player)
		if self.playerAttachments[player.UserId] then
			self:DetachBlock(player)
		end
	end)
end

return MainService
