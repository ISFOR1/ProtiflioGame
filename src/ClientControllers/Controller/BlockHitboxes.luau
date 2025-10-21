local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local ZonePlus = require(ReplicatedStorage.lib.ZonePlus.Zone) 

local BlockHitboxes = Knit.CreateController { Name = "BlockHitboxes" }

return BlockHitboxes