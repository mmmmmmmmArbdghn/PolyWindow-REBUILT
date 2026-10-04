local PolyWindow = require(script.Parent.Parent)

return function(content, sizeOffset, themeName)
	local window = PolyWindow.new(themeName)
		:loadPlugin("Resize")
		:loadPlugin("Adapt")
		:loadPlugin("Header")

	window:snap({
		SizeOffset = sizeOffset or Vector2.New(460, 320),
		PositionRelative = Vector2.New(0.5, 0.4),
	})
	window:loadPlugin("BaseWindow")

	local header = window:getPlugin("Header")
	if header then
		header:setLabel(content and content.Name or "Window"):returnWindow()
	end
	window:addContent(content)
	return window
end