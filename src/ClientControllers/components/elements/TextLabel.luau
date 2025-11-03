local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local e: typeof(React.createElement) = React.createElement

export type TextLabelProps = {
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundColor3: Color3?,
	BackgroundTransparency: number?,
	BorderSizePixel: number?,
	Text: string?,
	TextColor3: Color3?,
	TextTransparency: number?,
	Font: Enum.Font?,
	Fontface: Font?,
	TextSize: number?,
	TextScaled: boolean?,
	TextXAlignment: Enum.TextXAlignment?,
	TextYAlignment: Enum.TextYAlignment?,
	IsStorked: boolean?,
	StrokeColor: Color3?,
	Thickness: number?,
	Transparency: number?,
	ApplyStrokeMode: Enum.ApplyStrokeMode?,
	BorderStrokePosition: Enum.BorderStrokePosition?,
	LineJoinMode: Enum.LineJoinMode?,
	StrokeSizingMode: Enum.StrokeSizingMode?,
	BorderOffset: UDim?,
}

local function TextLabel(props: TextLabelProps)
	return e("TextLabel", {
		Size = props.Size or UDim2.fromScale(0, 0),
		Position = props.Position or UDim2.fromScale(0, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = props.BackgroundTransparency or 1,
		BorderSizePixel = props.BorderSizePixel or 0,
		Text = props.Text or "",
		TextColor3 = props.TextColor3 or Color3.fromRGB(0, 0, 0),
		TextScaled = props.TextScaled or false,
		TextTransparency = props.TextTransparency or 0,
		Font = props.Font or Enum.Font.SourceSans,
		FontFace = props.Fontface
			or Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		TextSize = props.TextSize or 14,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
		TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
	}, {
		UIStroke = if props.IsStorked
			then e("UIStroke", {
				Color = props.StrokeColor or Color3.fromRGB(0, 0, 0),
				Thickness = props.Thickness or 1,
				Transparency = props.Transparency or 0,
				ApplyStrokeMode = props.ApplyStrokeMode or Enum.ApplyStrokeMode.Contextual,
				BorderStrokePosition = props.BorderStrokePosition or Enum.BorderStrokePosition.Outer,
				LineJoinMode = props.LineJoinMode or Enum.LineJoinMode.Round,
				StrokeSizingMode = props.StrokeSizingMode or Enum.StrokeSizingMode.FixedSize,
				BorderOffset = props.BorderOffset or UDim.new(0, 0),
			})
			else nil,
	})
end

return TextLabel
