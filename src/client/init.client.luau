local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllers(ReplicatedStorage.Client.Controller)

Knit.Start():andThen(function()
    print("started on client")
end):catch(warn)