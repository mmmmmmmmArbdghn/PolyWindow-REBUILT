-- default Dark theme
-- can be used as template

-- helpers
local function font(preset, weight)
	local f = BuiltInFontAsset.New()
	f.FontPreset = preset
	f.FontWeight = weight or Enums.FontWeight.Regular
	return f
end

local function audio(preset, volume, pitch)
	local a = BuiltInAudioAsset.New()
	a.AudioPreset = preset
	return { Class = "Sound", Properties = { Audio = a, Volume = volume, Pitch = pitch, PlayInWorld = false } }
end

-- helper colors (to make it easier to modify)
local C = {
	Body = Color.New(0, 0, 0, 0.75),
	Border = Color.New(.65, .65, .65, 0.125),
	Header = Color.New(.5, .5, .5, 0.5),
	Button = Color.FromHex("#7b838d7d"),
	Text = Color.FromHex("#E8EDF2"),
	Title = Color.FromHex("#F5F8FA"),
	Grip = Color.FromHex("#C6CCD4"),
	Shadow = Color.New(0, 0, 0, 0.115),
	Clear = Color.New(0, 0, 0, 0),
	SemiSolid = Color.New(0,0,0,0.75),
	Solid = Color.New(1, 1, 1, 1)
}

local J = Enums.BuiltInAudioPreset.Jump

return {
	Base_Window = {
		Class = "UIView",
		Properties = {
			SizeRelative = Vector2.New(0, 0),
			SizeOffset = Vector2.New(300, 200),
			PositionRelative = Vector2.New(0.5, 0.5),
			PivotPoint = Vector2.New(0.5, 0.5),
			MaskMode = Enums.UIMaskMode.ClipOnly,
			Color = C.Solid,
			CornerRadius = 12,
			ZIndex = 1,
			--Scale = Vector2.New(3, 3),
		},
		Children = {
			UIShadow = {
				Class = "UIShadow",
				Properties = {
					Layers = (function()
						local layer = ShadowLayer.New()
						layer.Color = C.Shadow
						layer.Offset = Vector2.New(0, 16)
						layer.Radius = 32
						return {layer}
					end)(),
				},
			},
			Container = {
				Class = "UIView",
				Properties = {
					SizeRelative = Vector2.New(1, 1),
					SizeOffset = Vector2.New(0, 0),
					PositionRelative = Vector2.New(0, 0),
					PivotPoint = Vector2.New(0, 0),
					Color = C.Body, --C.Body
					BorderWidth = 1.5,
					BorderColor = C.Border,
					CornerRadius = 12,
					--ZIndex = -1,
				},
				Children = {
					WindowContent = {
						Class = "UIView",
						Properties = {
							SizeRelative = Vector2.New(1, 1),
							SizeOffset = Vector2.New(0, -32),
							PositionOffset = Vector2.New(0, 32),
							ClipDescendants = true,
							Color = C.Clear,
						},
					},
				}
			},
		},
	},

	Header = {
		Class = "UIView",
		Properties = {
			SizeRelative = Vector2.New(1, 0),
			SizeOffset = Vector2.New(0, 32),
			PositionRelative = Vector2.New(0, 0),
			PivotPoint = Vector2.New(0, 0),
			Color = C.Header,
		},
		Children = {
			LabelFrame = {
				Class = "UIView",
				Properties = {
					SizeRelative = Vector2.New(1, 1),
					SizeOffset = Vector2.New(0, 0),
					PositionRelative = Vector2.New(0, 0),
					PivotPoint = Vector2.New(0, 0),
					Color = C.Clear,
				},
				Children = {
					HeaderLabel = {
						Class = "UILabel",
						Properties = {
							Color = C.Clear,
							Text = "Window",
							TextColor = C.Title,
							OutlineWidth = 4,
							OutlineColor = C.SemiSolid,
							FontSize = 12,
							FontAsset = font(Enums.FontPreset.SourceSans, Enums.FontWeight.Black),
							HorizontalAlignment = Enums.HorizontalAlignment.Center,
							VerticalAlignment = Enums.VerticalAlignment.Middle,
							SizeRelative = Vector2.New(1, 1),
							SizeOffset = Vector2.New(0, 0),
							IgnoreMouse = true,
						},
					},
					Input = {
						Class = "UIView",
						Properties = { SizeRelative = Vector2.New(1, 1), SizeOffset = Vector2.New(0, 0), Color = C.Clear },
					},
				},
			},
			Buttons = {
				Class = "UIHLayout",
				Properties = {
					SizeRelative = Vector2.New(1, 1),
					SizeOffset = Vector2.New(0, 0),
					PositionRelative = Vector2.New(1, 0),
					PivotPoint = Vector2.New(1, 0),
					ChildAlignment = Enums.UILayoutAlignment.End,
					Spacing = 1,
					IgnoreMouse = true,
					--Color = C.Clear,
				},
			},
		},
	},

	HeaderButton = {
		Class = "UIView",
		Properties = {
			SizeRelative = Vector2.New(0, 1),
			SizeOffset = Vector2.New(72, 0),
			Color = C.Button,
		},
		Children = {
			TextLabel = {
				Class = "UILabel",
				Properties = {
					Color = C.Clear,
					Text = "",
					TextColor = C.Text,
					OutlineWidth = 4,
					OutlineColor = C.SemiSolid,
					FontSize = 12,
					FontAsset = font(Enums.FontPreset.Rubik, Enums.FontWeight.Medium),
					HorizontalAlignment = Enums.HorizontalAlignment.Center,
					VerticalAlignment = Enums.VerticalAlignment.Middle,
					SizeRelative = Vector2.New(1, 1),
					SizeOffset = Vector2.New(0, 0),
					UseRichText = true,
					IgnoreMouse = true,
				},
			},
			Button = {
				Class = "UIView",
				Properties = { SizeRelative = Vector2.New(1, 1), SizeOffset = Vector2.New(0, 0), Color = C.Clear },
			},
		},
	},

	Resize = {
		Class = "UIView",
		Properties = {
			SizeOffset = Vector2.New(24, 24),
			PositionRelative = Vector2.New(1, 1),
			PositionOffset = Vector2.New(-2, -2),
			PivotPoint = Vector2.New(1, 1),
			Color = C.Clear,
			ZIndex = 1,
		},
		Children = {
			Stripe1 = {
				Class = "UIView",
				Properties = {
					SizeOffset = Vector2.New(14, 3),
					PositionRelative = Vector2.New(1, 1),
					PositionOffset = Vector2.New(-10, -10),
					PivotPoint = Vector2.New(0.5, 0.5),
					Rotation = -45,
					CornerRadius = 1,
					Color = C.Grip,
					IgnoreMouse = true,
				},
			},
			Stripe2 = {
				Class = "UIView",
				Properties = {
					SizeOffset = Vector2.New(7, 3),
					PositionRelative = Vector2.New(1, 1),
					PositionOffset = Vector2.New(-8, -8),
					PivotPoint = Vector2.New(0.5, 0.5),
					Rotation = -45,
					CornerRadius = 1,
					Color = C.Grip,
					IgnoreMouse = true,
				},
			},
			Input = {
				Class = "UIView",
				Properties = { PositionRelative = Vector2.New(1,1), PivotPoint = Vector2.New(0.5,0.5), SizeRelative = Vector2.New(1, 1), SizeOffset = Vector2.New(16, 16), Color = C.Clear },
			},
		},
	},

	IntroSound = audio(J, 0.15, 0.6),
	OutroSound = audio(J, 0.15, 0.5),
	Tick = audio(J, 0.08, 1.4),
	ButtonDown = audio(J, 0.15, 0.8),
	ActionTaken = audio(J, 0.15, 1.2),
}