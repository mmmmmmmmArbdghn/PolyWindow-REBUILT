local plug = {}
plug.global_settings = require(script:FindChild(script.Name))

plug.init = function(window)
	local Debug = window.settings.debug
	local bplug = { connections = {} }
	bplug.settings = window.tableCopy_deep(plug.global_settings)

	bplug.instance = window:build("Resize", window.instance)
	local input = bplug.instance:WaitChild("Input")

	local function on(id, signal, fn)
		bplug.connections[id] = signal:Connect(function(...)
			Debug.try("Resize:" .. id, fn, ...)
		end)
	end

	local rz = nil
	local posOffset_final = Vector2.Zero
	on("start", input.MouseDown, function()
		rz = {
			start = Input.MousePosition,
			size = window.instance.SizeOffset,
			pos = window.instance.PositionOffset,
			pivot = window.instance.PivotPoint,
		}
		window:focus()
	end)
	on("move", Input.MouseMoved, function(m)
		if not rz then return end
		local delta = Input.MousePosition - rz.start
		local newSize = rz.size + delta
		local finalSize = Vector2.New(
			math.clamp(newSize.X, window.minSize.X, window.maxSize.X),
			math.clamp(newSize.Y, window.minSize.Y, window.maxSize.Y)
		)
		
		-- DO NOT TOUCH
		local devX = math.max(newSize.X / finalSize.X - 1, -0.75) * 0.25
		local devY = math.max(newSize.Y / finalSize.Y - 1, -0.75) * 0.25
	
		-- 1.0 = rigid volume lock (ugly). Lower = rubberier, more give (wow 5 stars)
		local VOLUME_LOCK = 0.8
		-- how far the shape is allowed to swell on a diagonal pull
		local ELASTICITY = 0.4
	
		-- only positive when BOTH axes are being stretched at once (a diagonal drag)
		local diagonal = math.min(devX, devY)
		local swell = 0
		if diagonal > 0 then
			-- tanh saturates, so a huge drag can't balloon the sprite out of control
			swell = ELASTICITY * math.tanh(diagonal * 3)
		end
	
		local scaleX = 1 + devX - VOLUME_LOCK * devY + swell
		local scaleY = 1 + devY - VOLUME_LOCK * devX + swell
	
		local scale = Vector2.New(math.max(0.1, scaleX), math.max(0.1, scaleY))
	
		local effDelta = newSize - rz.size
		local effDelta_final = finalSize - rz.size
		effDelta = effDelta + (effDelta_final - effDelta) * 0.5
	
		local posOffset = rz.pos + effDelta * rz.pivot
		posOffset_final = rz.pos + effDelta_final * rz.pivot
	
		window:spring(window.settings.springTypes.primary, {
			SizeOffset = finalSize,
			Scale = scale,
			PositionOffset = posOffset,
		})
	end)
	on("end", Input.KeyUp, function(key)
		if not rz then return end
		if key ~= Enums.KeyCode.MouseLeft then return end

		rz = nil
		window:spring(window.settings.springTypes.primary, {
			Scale = Vector2.One,
		})
		window:spring(window.settings.springTypes.secondary, {
			PositionOffset = posOffset_final,
		})
	end)

	plug[window.id] = bplug
end

plug.quit = function(window)
	local bplug = plug[window.id]
	if not bplug then return end
	for _, c in pairs(bplug.connections) do c:Disconnect() end
	if bplug.instance then bplug.instance:Destroy() end
	plug[window.id] = nil
end

return plug