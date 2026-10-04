--!native

--[[
///////////////////////////////////////// ALL HALLOWS' EVE /////////////////////////////////////////#
																									#
▄▄▄▄▄▄              ▄▄▄▄               ▄▄      ▄▄    ██                     ▄▄                     	#
██▀▀▀▀█▄            ▀▀██               ██      ██    ▀▀                     ██                     	#
██    ██   ▄████▄     ██      ▀██  ███ ▀█▄ ██ ▄█▀  ████     ██▄████▄   ▄███▄██   ▄████▄  ██      ██	#
██████▀   ██▀  ▀██    ██       ██▄ ██   ██ ██ ██     ██     ██▀   ██  ██▀  ▀██  ██▀  ▀██ ▀█  ██  █▀	#
██        ██    ██    ██        ████▀   ███▀▀███     ██     ██    ██  ██    ██  ██    ██  ██▄██▄██ 	#
██        ▀██▄▄██▀    ██▄▄▄      ███    ███  ███  ▄▄▄██▄▄▄  ██    ██  ▀██▄▄███  ▀██▄▄██▀  ▀██  ██▀ 	#
▀▀          ▀▀▀▀       ▀▀▀▀      ██     ▀▀▀  ▀▀▀  ▀▀▀▀▀▀▀▀  ▀▀    ▀▀    ▀▀▀ ▀▀    ▀▀▀▀     ▀▀  ▀▀  	#
							   ███                                                                 	#
ooooooooo.   oooooooooooo oooooooooo.  ooooo     ooo ooooo ooooo    ooooooooooooo 					#
`888   `Y88. `888'     `8 `888'   `Y8b `888'     `8' `888' `888'    8'   888   `8 					#
 888   .d88'  888          888     888  888       8   888   888          888      					#
 888ooo88P'   888oooo8     888oooo888'  888       8   888   888          888      					#
 888`88b.     888    "     888    `88b  888       8   888   888          888      					#
 888  `88b.   888       o  888    .88P  `88.    .8'   888   888       o  888      					#
o888o  o888o o888ooooood8 o888bood8P'     `YbodP'    o888o o888ooooood8 o888o                 		#                                                 
																									#
///////////////////////////////////////////////////////////////////// 1-OCTOBER-2026 ///////////////#

		MM/DD/YYYY
VERSION 04/10/2026

Welcome to PolyWindow (Rebuilt)! It has jiggle physics.
Just focus on writing your game's admin panel or something.
Make debugging menus that call functions for testing or something.
...or just straight up implement it into a core part of your game like shop GUIs.
PolyWindow will handle all of that unnecessary container UI helpers.
With no more excuses, you should code your game NOW!!!



This version is specifically built for the Polytoria 2.0 engine. History:
	1. Windows V1, Roblox (no name yet, just a plain name of what it does...)
	2. Windows V2, Roblox (complete rewrite, eventually named Q-WINC)
	3. PolyWindow REBUILT, Polytoria 2.0 <----- here!!!

This rebuild is not yet feature-complete, as
there are many functions that are missing from the original.
Probably counts as a second rewrite.



Planned features:
	- More built-in themes
	- Rebuild useful built-in apps (ColorPicker, WindowManager, AppLauncher, etc)
	- Rebuild multitouch support with multimodal window controls (waiting for the Polytoria mobile port)
	- Rebuild world-space windows (probably after multimodal support)
	- Rebuild header snapping functions
	- Performance improvements
	- iPadOS-style 3D screenspace windows with world-space reveal (it looks so cool)
	- waiting for even more ideas to pile up into a much bigger problem



CHANGES:
	===== 04/10/2026 =====
	- the github
	- comments explaining functions
	- templates

	===== 01/10/2026 =====
	- released the dog


]]

local module = {}

print("========== POLYWINDOW STARTING... ==========")

local settings = require(script:WaitChild("SystemSettings"))
local Debug = settings.debug
local ThemeBuilder = require(settings.packages:WaitChild("ThemeBuilder"))

module.settings = settings
module.path = script
module.plugins = {}
module.space = {}
module.screen = nil

for _, child in pairs(settings.themes:GetChildren()) do
	if child:IsA("ModuleScript") then
		local ok, data = pcall(require, child)
		if ok then
			ThemeBuilder.registerTheme(child.Name, data)
		else
			Debug.warn("theme", "failed to load", child.Name, data)
		end
	end
end

local windowCreated = Instance.New("BindableEvent")::BindableEvent
local windowDestroyed = Instance.New("BindableEvent")::BindableEvent
module.windowCreated = windowCreated.Invoked
module.windowDestroyed = windowDestroyed.Invoked

-- generates a random alphanumeric string.
-- @param len number?: length of the id (default 32)
-- @return string: the generated id
function module:genId(len)
	len = len or 32
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local out = table.create(len)
	for i = 1, len do
		local j = math.random(1, #chars)
		out[i] = chars:sub(j, j)
	end
	return table.concat(out)
end

-- finds a window by its id or z-index.
-- @param idOrZ string|number: the window id or z-index
-- @return table?: the window object or nil
function module.findWindow(idOrZ)
	if typeof(idOrZ) == "string" then
		for _, w in ipairs(module.space) do
			if w.id == idOrZ then return w end
		end
		return nil
	end
	return module.space[idOrZ]
end

-- creates spring physics info.
-- @param d number: duration
-- @param b number: bounciness
-- @return table: spring info table
function module.springInfo(d, b) return settings.spring.springInfo(d, b) end

-- registers a plugin module.
-- @param name string: plugin name
-- @param plug table: plugin module
function module.registerPlugin(name, plug) module.plugins[name] = plug end

-- loads and registers all plugins from the settings folder.
function module.setupPlugins()
	if module.hasSetupPlugins then return end
	for _, child in pairs(settings.plugins:GetChildren()) do
		if child:IsA("ModuleScript") then
			local ok, plug = pcall(require, child)
			if ok then module.registerPlugin(child.Name, plug)
			else Debug.warn("plugin", "failed to require", child.Name, plug) end
		end
	end
	module.hasSetupPlugins = true
end

module.baseWindow = {}
module.baseWindow.__index = module.baseWindow

-- destroys a window by id, cleaning up events and instances.
-- @param id string: the window id
-- @return nil
function module.destroyWindow(id)
	local self = module.findWindow(id)
	if not self then
		Debug.warn("window", "destroy: unknown id", tostring(id))
		return
	end
	Debug.log("window", "destroying", id)

	local outroTime = self.settings.outroTime

	local idx = table.find(module.space, self)
	if idx then table.remove(module.space, idx) end
	for i, w in ipairs(module.space) do
		if w.instance then w.instance.ZIndex = i end
	end

	self:fireEvent("destroying")
	for name in pairs(table.clone(self.plugins)) do self:unloadPlugin(name) end
	for _, conn in pairs(self.misc.eventConnections) do conn:Disconnect() end
	table.clear(self.misc.eventConnections)
	for _, sig in pairs(self.misc.eventObjects) do sig:Destroy() end
	table.clear(self.misc.eventObjects)

	local inst = self.instance
	spawn(function()
		wait(outroTime)
		if inst then inst:Destroy() end
		windowDestroyed:Invoke(table.pack(id))
	end)

	setmetatable(self, nil)
	table.clear(self)
	return nil
end

-- creates and returns a new window instance.
-- @param themeName string?: the theme to use (default from settings)
-- @return table: the new window object
function module.new(themeName)
	local startTick = tick()
	--Debug.log("window", "new(", tostring(themeName), ")")
	local self = setmetatable({}, module.baseWindow)

	-- deep copies a table.
	-- @param t table: source table
	-- @return table: copied table
	function self.tableCopy_deep(t)
        local copy = {}
        for key, value in pairs(t) do
            copy[key] = type(value) == "table" and self.tableCopy_deep(value) or value
        end
        return copy
    end

	self.settings = self.tableCopy_deep(settings)
	self.theme = themeName or settings.defaultTheme
	self.id = module:genId()
	self.plugins = {}
	self.misc = { eventObjects = {}, eventConnections = {} }
	self.lastKnownGoodSize = nil
	self.lastKnownGoodPosition = nil

	self.minSize = Vector2.New(100, 0) --y axis gets changed upon header plugin init
	self.maxSize = Vector2.New(math.huge, math.huge)

	if not module.screen then
		local gui = Instance.New("GUI", PlayerGUI)
		local screen = Instance.New("UIView", gui)
		screen.Name = "PolyWindow_Screen"
		screen.SizeRelative = Vector2.New(1, 1)
		screen.Color = Color.New(0, 0, 0, 0)
		screen.IgnoreMouse = true
		module.screen = screen
		Debug.log("window", "screen created")
	end

	local base:Instance = ThemeBuilder.createElement(self.theme, "Base_Window", module.screen)
	base.Name = "Window_" .. self.id
	self.instance = base
	self.container = base:WaitChild("Container")
	self.canvas = self.container:WaitChild("WindowContent")
	self.subInstance = base -- alias; UniqueElements folder removed in rebuild (probably expanding this later)
	self.baseColor = base.Color

	-- deep copies a table (alias).
	-- @param t table: source table
	-- @return table: copied table
	function self.deepCopyTable(t)
		local copy = {}
		for k, v in pairs(t) do
			copy[k] = type(v) == "table" and self.deepCopyTable(v) or v
		end
		return copy
	end

	-- creates a themed ui element.
	-- @param objectName string: element name
	-- @param parent instance?: parent instance
	-- @return instance: the created element
	function self:build(objectName, parent)
		return ThemeBuilder.createElement(self.theme, objectName, parent or self.instance)
	end

	-- plays a themed sound and destroys it when finished.
	-- @param name string: sound name
	function self:playSound(name)
		if not ThemeBuilder.hasObject(self.theme, name) then
			Debug.log("sound", "no schema for", name)
			return
		end
		local s = self:build(name, Hidden)
		s.Finished:Once(function() s:Destroy() end)
		s:Play()
	end

	-- events -------------------------------------------------
	
	-- registers a new bindable event.
	-- @param id string: event id
	-- @return table: self
	function self:addEvent(id)
		if self.misc.eventObjects[id] then return self end
		self.misc.eventObjects[id] = Instance.New("BindableEvent")::BindableEvent
		return self
	end
	
	-- invokes a registered event.
	-- @param id string: event id
	-- @param ... any: arguments to pass
	-- @return table: self
	function self:fireEvent(id, ...)
		local event = self.misc.eventObjects[id]
		if not event then
			Debug.log("event", "fire on unregistered event:", id)
			return self
		end
		event:Invoke(table.pack(...))
		return self
	end
	
	-- connects a function to a registered event.
	-- @param id string: event id
	-- @param call function: callback
	-- @param connId string?: connection id
	-- @return table: self
	function self:bindEvent(id, call, connId)
		local event = self.misc.eventObjects[id]
		if not event then
			Debug.warn("event", "bind on unregistered event:", id)
			return self
		end
		connId = connId or (id .. "_" .. tostring(#self.misc.eventConnections + 1))
		self.misc.eventConnections[connId] = event.Invoked:Connect(function(payload)
			Debug.try("event:" .. id, call, self, table.unpack(payload, 1, payload.n))
		end)
		return self
	end

	-- connects to an external signal safely.
	-- @param id string: connection id
	-- @param signal PTSignalConnection: the signal
	-- @param fn function: callback
	-- @return table: self
	function self:connect(id, signal, fn)
		self.misc.eventConnections[id] = signal:Connect(function(...)
			Debug.try("conn:" .. id, fn, ...)
		end)
		return self
	end

	-- disconnects and removes a signal connection.
	-- @param id string: connection id
	-- @return table: self
	function self:removeConnection(id)
		local c = self.misc.eventConnections[id]
		if c then
			c:Disconnect()
			self.misc.eventConnections[id] = nil
		end
		return self
	end

	-- layout helpers ---------------------------------------
	
	-- sorts a dictionary of elements by a specific property.
	-- @param elementsUnorderedDict table: dictionary of elements
	-- @param propertyKey string|number: property to sort by
	-- @param reversed boolean?: sort in descending order
	-- @return table: sorted array of elements
	function self.getReparentOrderByProperty(elementsUnorderedDict, propertyKey, reversed)
		-- collect values into an array
		local elements = table.create(#elementsUnorderedDict)
		for _, element in elementsUnorderedDict do
			table.insert(elements, element)
		end

		table.sort(elements, function(a, b)
			local aVal = a[propertyKey]
			local bVal = b[propertyKey]

			-- numerical comparison
			if type(aVal) == "number" and type(bVal) == "number" then
				if aVal == bVal then
					return false -- stable-ish: keep original order on ties
				end
				return reversed and (aVal > bVal) or (aVal < bVal)
			end

			-- lexicographic comparison
			-- luau's `<` / `>` on strings already weights earlier characters more
			local aStr = tostring(aVal)
			local bStr = tostring(bVal)

			if aStr == bStr then
				return false
			end
			return reversed and (aStr > bStr) or (aStr < bStr)
		end)

		return elements
	end

	-- reparents elements to enforce z-order/layout.
	-- @param elementsOrderedArray table: sorted elements
	function self:arrangeLayout_reparent(elementsOrderedArray)
		for i, element:Instance in ipairs(elementsOrderedArray) do
			local temp = element.Parent
			element.Parent = element.Parent.Parent
			element.Parent = temp
		end
	end

	-- transform helpers ------------------------------------
	
	-- snaps a value to a grid cell.
	-- @param cell number: grid size
	-- @param value number: value to snap
	-- @return number: snapped value
	function self.snapXToGrid(cell, value)
		if cell <= 0 then return value end
		local snapped = math.round(value / cell) * cell
		return snapped == snapped and snapped or value
	end

	-- calculates the offset between instance and canvas sizes.
	-- @return vector2: the content offset
	function self:getContentOffset()
		return (self.instance.AbsoluteSize - self.canvas.AbsoluteSize) + settings.offsets.contentOffset
	end

	-- applies a table of properties to the window instance.
	-- @param propertyTable table: properties to set
	-- @return table: self
	function self:snap(propertyTable)
		for prop, value in pairs(propertyTable) do
			self.instance[prop] = value
		end
		return self
	end

	-- tweens properties using spring physics.
	-- accepts (instance, sinfo, props, call) or (sinfo, props, call).
	-- @param a instance|table: target instance or spring info
	-- @param b table: spring info or properties
	-- @param c table|function: properties or completion callback
	-- @param d function?: completion callback
	-- @return table: tween object
	function self:spring(a, b, c, d)
		local inst, sinfo, props, call = a, b, c, d
		if typeof(a) == "table" and a.duration then
			inst, sinfo, props, call = self.instance, a, b, c
		end
		if typeof(inst) == "table" and inst.instance then inst = inst.instance end
		local tween = settings.spring.tween(inst, sinfo, props)
		if call then
			local key = next(props)
			Debug.try("springCompleted", function()
				tween.getCompletedSignal(key):Once(function()
					Debug.try("springComplete", call)
				end)
			end)
		end
		return tween
	end

	-- plugins ------------------------------------------------
	
	-- loads and initializes a plugin on the window.
	-- @param name string: plugin name
	-- @param returnPlugin boolean?: return the plugin instance
	-- @return table: self or plugin instance
	function self:loadPlugin(name, returnPlugin)
		module.setupPlugins()
		if self.plugins[name] then
			Debug.warn("plugin", "already loaded:", name)
			return self
		end
		local plug = module.plugins[name]
		if not plug then
			Debug.warn("plugin", "not found:", name)
			return self
		end
		Debug.try("pluginInit:" .. name, plug.init, self)
		self.plugins[name] = plug
		local bplug = plug[self.id]
		if bplug then
			bplug.returnWindow = function() return self end
			if returnPlugin then return bplug end
		end
		return self
	end

	-- gets a loaded plugin instance.
	-- @param name string: plugin name
	-- @return table?: plugin instance or nil
	function self:getPlugin(name)
		local plug = self.plugins[name]
		if not plug then
			Debug.warn("plugin", "not loaded:", name)
			return nil
		end
		return plug[self.id]
	end

	-- unloads and cleans up a plugin.
	-- @param name string: plugin name
	-- @return table: self
	function self:unloadPlugin(name)
		local plug = self.plugins[name]
		if not plug then return self end
		Debug.try("pluginQuit:" .. name, plug.quit, self)
		self.plugins[name] = nil
		return self
	end

	-- content ------------------------------------------------
	
	-- parents an instance to the window canvas.
	-- @param inst instance?: instance to add
	-- @return table: self
	function self:addContent(inst)
		if inst then inst.Parent = self.canvas end
		return self
	end

	-- sets the parent of the window instance.
	-- @param inst instance: new parent
	-- @return table: self
	function self:setParent(inst)
		self.instance.Parent = inst
		return self
	end

	-- stacking -----------------------------------------------
	
	-- brings the window to the front and fires focus events.
	-- @return table: self
	function self:focus()
		local idx = table.find(module.space, self)
		if idx then table.remove(module.space, idx) end
		table.insert(module.space, self)
		for i, w in ipairs(module.space) do
			if w.instance then
				w.instance.ZIndex = i
				w:fireEvent(w == self and "focus" or "unfocus")
			end
		end
		return self
	end

	-- fires the unfocus event.
	-- @return table: self
	function self:unfocus()
		self:fireEvent("unfocus")
		return self
	end

	-- checks if the window is at the top of the z-index.
	-- @return boolean: true if on top
	function self:isOnTop()
		return module.space[#module.space] == self
	end

	-- minimize / maximize ------------------------------------
	
	-- minimizes the window to the header.
	-- @param skipAnim boolean?: skip the animation
	-- @return table: self
	function self:minimize(skipAnim)
		self:fireEvent("minimized")
		local inst = self.instance
		local sSinfo = skipAnim and module.springInfo(0, 0) or settings.springTypes.fifternary
		local pSinfo = skipAnim and module.springInfo(0, 0) or settings.springTypes.quaternary

		if self.lastKnownGoodSize then
			local ls, lp = self.lastKnownGoodSize, self.lastKnownGoodPosition
			self.lastKnownGoodSize, self.lastKnownGoodPosition = nil, nil
			self:spring(sSinfo, { SizeOffset = ls, PositionOffset = lp, PositionRelative = Vector2.New(0.5, 0.5) })
		else
			self.lastKnownGoodSize = inst.SizeOffset
			self.lastKnownGoodPosition = inst.PositionOffset
			local h = settings.headerHeight
			self:spring(sSinfo, { SizeOffset = Vector2.New(inst.AbsoluteSize.X, h) })
			self:spring(pSinfo, {
				PositionRelative = Vector2.New(inst.PositionRelative.X, 1),
				PositionOffset = Vector2.New(inst.PositionOffset.X, -h * 0.5),
			})
		end
		return self
	end

	-- maximizes the window to fill the screen.
	-- @return table: self
	function self:maximize()
		self:fireEvent("maximized")
		local inst = self.instance
		if self.lastKnownGoodSize then
			local ls, lp = self.lastKnownGoodSize, self.lastKnownGoodPosition
			self.lastKnownGoodSize, self.lastKnownGoodPosition = nil, nil
			self:spring(settings.springTypes.quaternary, { SizeOffset = ls, PositionOffset = lp, PositionRelative = Vector2.New(0.5, 0.5) })
		else
			self.lastKnownGoodSize = inst.SizeOffset
			self.lastKnownGoodPosition = inst.PositionOffset
			self:spring(settings.springTypes.fifternary, {
				SizeRelative = Vector2.New(1, 1),
				SizeOffset = Vector2.New(0, 0),
				PositionRelative = Vector2.New(0.5, 0.5),
				PositionOffset = Vector2.New(0, 0),
			})
		end
		return self
	end

	-- destroys the window.
	-- @return nil
	function self:destroy()
		return module.destroyWindow(self.id)
	end

	-- finalize -------------------------------------------------
	self:addEvent("destroying")
	self:addEvent("focus")
	self:addEvent("unfocus")
	self:addEvent("minimized")
	self:addEvent("maximized")

	self:connect("baseDestroying", base.Destroying, function()
		if self.id then module.destroyWindow(self.id) end
	end)

	self:focus()
	windowCreated:Invoke(table.pack(self.id, tick() - startTick))
	Debug.log("window", "created", self.id, "in", tostring(tick() - startTick), "s")
	return self
end

-- sets the active window creation manager.
-- @param id string: manager id
-- @return table?: the manager module or nil
function module:setWCreateManager(id)
	local path = settings.wcreate_managers:FindChild(id)
	if not path then
		Debug.warn("manager", "invalid id:", id)
		return nil
	end
	local manager = require(path)
	settings.currentWCreateManager = manager
	return manager
end

-- creates a new window using the current manager.
-- @param content any: window content
-- @param sizeOffset vector2?: initial size offset
-- @param themeName string?: theme name
-- @return table: the new window object
function module:create(content, sizeOffset, themeName)
	local manager = settings.currentWCreateManager or module:setWCreateManager(settings.defaultWCreateManager)
	return manager(content, sizeOffset, themeName)
end

print("========== POLYWINDOW INIT SUCCESS ==========")

return module