local plug = {}
plug.global_settings = require(script:FindChild(script.Name))

plug.init = function(window)
	local Debug = window.settings.debug
	local bplug = { connections = {}, headerButtons = {}, label = "" }
	bplug.settings = window.tableCopy_deep(plug.global_settings)

	bplug.instance = window:build("Header")
	local header = bplug.instance
	local labelFrame = header:WaitChild("LabelFrame")
	local label = labelFrame:WaitChild("HeaderLabel")
	local dragInput = labelFrame:WaitChild("Input")
	local buttonStrip = header:WaitChild("Buttons")

	local header_absSize = header.SizeOffset
	window.minSize = Vector2.New(window.minSize.X, header_absSize.Y)

	local function on(id, signal, fn)
		bplug.connections[id] = signal:Connect(function(...)
			Debug.try("Header:" .. id, fn, ...)
		end)
	end

	-- sets the header label text.
	-- @param str string: the text to display
	-- @return table: self
	function bplug:setLabel(str)
		label.Text = str
		bplug.label = str
		return self
	end

	-- adds an interactive button to the header strip.
	-- @param text string: button label
	-- @param call function?: callback on click
	-- @param widthPx number?: button width in pixels
	-- @param focusOnPress boolean?: focus window on click
	-- @param ZIndex number?: render order
	-- @return instance: the created button
	function bplug:addButton(text, call, widthPx, focusOnPress, ZIndex)
		if typeof(text) ~= "string" then
			error("addButton: expected string label, got " .. typeof(text) .. " (called with '.' instead of ':'?)")
		end

		ZIndex = ZIndex or 0

		local button = window:build("HeaderButton", buttonStrip)
		button:WaitChild("TextLabel").Text = text
		button.SizeOffset = Vector2.New(widthPx or (#text * 8 + 24), 0)
		button.ZIndex = ZIndex

		local baseColor = button.Color
		local hoverColor = baseColor:Lerp(Color.New(1, 1, 1, 1), 0.12)
		local pressColor = baseColor:Lerp(Color.New(0, 0, 0, 1), 0.2)
		local inputLayer = button:WaitChild("Button")
		local down = false

		on("down_" .. text, inputLayer.MouseDown, function()
			down = true
			window:playSound("ButtonDown")
			window:spring(button, window.settings.springTypes.snappy, { Color = pressColor })
		end)
		on("up_" .. text, inputLayer.MouseUp, function()
			down = false
			window:playSound("ActionTaken")
			window:spring(button, window.settings.springTypes.snappy, { Color = baseColor })
			if focusOnPress then window:focus() end
			if call then call(button) end
		end)
		on("enter_" .. text, inputLayer.MouseEnter, function()
			window:playSound("Tick")
			window:spring(button, window.settings.springTypes.snappy, { Color = hoverColor })
		end)
		on("exit_" .. text, inputLayer.MouseExit, function()
			if not down then
				window:spring(button, window.settings.springTypes.snappy, { Color = baseColor })
			end
		end)

		window:arrangeLayout_reparent(window.getReparentOrderByProperty(bplug.headerButtons, "ZIndex", false))

		bplug.headerButtons[text] = button
		return button
	end

	-- destroys and removes a header button.
	-- @param button instance: the button to remove
	function bplug:removeButton(button)
		if button then button:Destroy() end
	end

	-- dragging -------------------------------------------------
	local drag = nil
	on("dragStart", dragInput.MouseDown, function()
		local now = tick()
		if bplug.lastTap and now - bplug.lastTap < 0.25 then
			bplug.lastTap = nil
			window:maximize()
			return
		end
		bplug.lastTap = now
		drag = { start = Input.MousePosition, pos = window.instance.PositionOffset }
		window:focus()
	end)
	on("dragMove", Input.MouseMoved, function(m)
		if not drag then return end
		local delta = Input.MousePosition - drag.start
		delta = Vector2.New(
			window.snapXToGrid(window.settings.grid.X, delta.X),
			window.snapXToGrid(window.settings.grid.Y, delta.Y)
		)
		window:spring(window.settings.springTypes.primary, { PositionOffset = drag.pos + delta })
	end)
	on("dragEnd", Input.KeyUp, function(key)
		if key == Enums.KeyCode.MouseLeft then drag = nil end
	end)

	bplug:addButton("X", function() window:destroy() end, 28, true, 10000)

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