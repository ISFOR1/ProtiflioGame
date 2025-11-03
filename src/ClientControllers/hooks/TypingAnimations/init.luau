local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local RunService = game:GetService("RunService")

local CHAR_INTERVAL = 0.03

local function useTypewriter(fullText: string, soundService)
	local displayedText, setDisplayedText = React.useState("")
	local isTyping, setIsTyping = React.useState(true)

	local skipTypingRef = React.useRef(function() end)

	React.useEffect(function()
		setDisplayedText("")
		setIsTyping(true)

		if not fullText or #fullText == 0 then
			setIsTyping(false)
			setDisplayedText("")
			return function() end
		end

		local startTime = os.clock()
		local connection
		local lastCharCount = 0

		skipTypingRef.current = function()
			if connection then
				connection:Disconnect()
				connection = nil
			end
			setDisplayedText(fullText)
			setIsTyping(false)
		end

		connection = RunService.Heartbeat:Connect(function()
			local elapsedTime = os.clock() - startTime
			local charCount = math.floor(elapsedTime / CHAR_INTERVAL)

			if charCount >= #fullText then
				skipTypingRef.current()
			else
				if charCount > lastCharCount and soundService then
					soundService:play("Talking")
					lastCharCount = charCount
				end
				setDisplayedText(string.sub(fullText, 1, charCount))
			end
		end)

		return function()
			if connection then
				connection:Disconnect()
			end
		end
	end, { fullText, soundService })

	return displayedText, isTyping, skipTypingRef.current
end

return useTypewriter
