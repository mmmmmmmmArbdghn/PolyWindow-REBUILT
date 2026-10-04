local plug = {}
plug.global_settings = require(script:FindChild(script.Name))

plug.init = function(window)
	--local Debug = window.settings.debug
	local bplug = { connections = {} }
	bplug.settings = window.tableCopy_deep(plug.global_settings)

    -- put your init code here

	plug[window.id] = bplug
end

plug.quit = function(window)
	local bplug = plug[window.id]
	if not bplug then return end

    -- put your quit code here

	for _, c in pairs(bplug.connections) do c:Disconnect() end

	plug[window.id] = nil
end

return plug