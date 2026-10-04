local plug = {}
plug.global_settings = require(script:FindChild(script.Name))

plug.init = function(window)
	local Debug = window.settings.debug
	local bplug = { connections = {}, acc = 0 }
	bplug.settings = window.tableCopy_deep(plug.global_settings)

	bplug.connections["tick"] = Hooks.Updated:Connect(function(dt)
		Debug.try("Adapt:tick", function()
			bplug.acc += dt
			if bplug.acc < 0.25 then return end
			bplug.acc = 0
	
			local inst = window.instance
			local parent = inst and inst.Parent
			if not parent then return end
	
			local header = window:getPlugin("Header")
			local labelFrame = header.instance:WaitChild("LabelFrame")
			local dragInput = labelFrame:WaitChild("Input")
	
			local inset: Vector2 = bplug.settings.borderInset_px*2
	
			local pPos, pSize = parent.AbsolutePosition, parent.AbsoluteSize
			local aPos, aSize = dragInput.AbsolutePosition, dragInput.AbsoluteSize

			-- observation: WHY DOES IT NEED AN EXTRA INSET OF 50??? HUH????
			local stupid_hardcode = 50
			local workingAxis = math.min(aSize.X, aSize.Y)
			inset = inset + Vector2.One*(stupid_hardcode + workingAxis)
	
			local p_tl = pPos
			local p_br = pPos + pSize
	
			local i_tl = aPos
			local i_br = aPos + aSize
	
			local tl = p_tl + inset - i_br
			local br = p_br - inset - i_tl

			--print(tl, br)
	
			local fix = Vector2.New(0, 0)
			

			if tl.X > 0 then
				print(1)
				fix += Vector2.New(tl.X, 0)
			end
			if br.X < 0 then
				print(2)
				fix += Vector2.New(br.X, 0)
			end
			if tl.Y > 0 then
				print(3)
				fix += Vector2.New(0, tl.Y)
			end
			if br.Y < 0 then
				print(4)
				fix += Vector2.New(0, br.Y)
			end
	
			if fix.Magnitude > 0.5 then
				window:spring(window.settings.springTypes.secondary, {
					PositionOffset = inst.PositionOffset + fix
				})
			end
	
			local over = Vector2.New(
				math.max(0, aSize.X - pSize.X),
				math.max(0, aSize.Y - pSize.Y)
			)
	
			if over.Magnitude > 0.5 then
				window:spring(window.settings.springTypes.secondary, {
					SizeOffset = inst.SizeOffset - over
				})
			end
		end)
	end)

	plug[window.id] = bplug
end

plug.quit = function(window)
	local bplug = plug[window.id]
	if not bplug then return end
	for _, c in pairs(bplug.connections) do c:Disconnect() end
	plug[window.id] = nil
end

return plug