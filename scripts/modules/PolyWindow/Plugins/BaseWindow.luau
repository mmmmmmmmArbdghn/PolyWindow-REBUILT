local plug = {}
plug.global_settings = require(script:FindChild(script.Name))

local function stretch(sizeOffset: Vector2, factor: Vector2): (Vector2, Vector2)
	local x = sizeOffset.X / factor.X
	local y = sizeOffset.Y / factor.Y
	local output_sizeOffset = Vector2.New(x,y)
	local output_scale = factor

	return output_sizeOffset, output_scale
end

local function withAlpha(color, alpha)
	return Color.New(color.R, color.G, color.B, alpha)
end

plug.init = function(window)
	local bplug = { connections = {} }
	bplug.settings = window.tableCopy_deep(plug.global_settings)

	local origSize = window.instance.SizeOffset
	local base = window.baseColor

	local i_so, i_s = stretch(origSize - bplug.settings.io_offset, Vector2.New(2, 2))
	local e_so, e_s = stretch(origSize, Vector2.One)

	window:playSound("IntroSound")
	window:snap({
		SizeOffset = i_so,
		Scale = i_s,
		Color = withAlpha(base, 0),
	})
	window:spring(window.settings.springTypes.primary, {
		SizeOffset = e_so,
		Scale = e_s,
		Color = withAlpha(base, window.settings.transparency.activeAlpha),
	})

	window:bindEvent("focus", function()
		window:spring(window.settings.springTypes.secondary, { Color = withAlpha(window.baseColor, window.settings.transparency.activeAlpha) })
	end, "bw_focus")

	window:bindEvent("unfocus", function()
		window:spring(window.settings.springTypes.secondary, { Color = withAlpha(window.baseColor, window.settings.transparency.inactiveAlpha) })
	end, "bw_unfocus")

	plug[window.id] = bplug
end

plug.quit = function(window)
	local bplug = plug[window.id]
	if not bplug then return end
	for _, c in pairs(bplug.connections) do c:Disconnect() end

	local shadow = (window.instance::Instance):FindChild("UIShadow")
	if shadow then
		shadow:Destroy()
	end
	
	local origSize = window.instance.SizeOffset
	local e_so, e_s = stretch(origSize - bplug.settings.io_offset, Vector2.New(0.5, 0.5))

	window:playSound("OutroSound")
	window:spring(window.settings.springTypes.primary, {
		SizeOffset = e_so,
		Scale = e_s,
		Color = Color.New(window.baseColor.R, window.baseColor.G, window.baseColor.B, 0),
	})
	plug[window.id] = nil
end

return plug