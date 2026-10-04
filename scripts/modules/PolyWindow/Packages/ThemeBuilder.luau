local ThemeBuilder = {}
local DEFAULT_THEME = "Dark"
local themes = {}

local PLACEHOLDER = {
	Class = "UIView",
	Properties = {
		SizeRelative = Vector2.New(1, 1),
		Color = Color.New(1, 0, 1, 0.9),
		BorderColor = Color.New(0, 0, 0, 1),
		BorderWidth = 4,
	},
	Children = {
		ErrorLabel = {
			Class = "UILabel",
			Properties = {
				Text = "MISSING THEME ELEMENT",
				TextColor = Color.New(0, 0, 0, 1),
				FontSize = 16,
				HorizontalAlignment = Enums.HorizontalAlignment.Center,
				VerticalAlignment = Enums.VerticalAlignment.Middle,
				SizeRelative = Vector2.New(1, 1),
			},
		},
	},
}

function ThemeBuilder.registerTheme(name, data)
	themes[name] = data
	print("[ThemeBuilder] registered theme: " .. name)
end

-- silent existence check (no warnings)
function ThemeBuilder.hasObject(themeName, objectName)
	local t = themes[themeName]
	if t and t[objectName] then return true end
	local d = themes[DEFAULT_THEME]
	return d ~= nil and d[objectName] ~= nil
end

function ThemeBuilder.getSchema(themeName, objectName)
	local t = themes[themeName] or {}
	local schema = t[objectName]
	if schema then return schema end

	local d = themes[DEFAULT_THEME] or {}
	schema = d[objectName]
	if schema then
		warn(string.format("[ThemeBuilder] '%s' missing in theme '%s' -> falling back to '%s'", objectName, themeName, DEFAULT_THEME))
		return schema
	end

	warn(string.format("[ThemeBuilder] CRITICAL: '%s' missing in '%s' AND '%s' -> generating placeholder", objectName, themeName, DEFAULT_THEME))
	schema = table.clone(PLACEHOLDER)
	schema.Children.ErrorLabel.Properties.Text = "MISSING: " .. objectName
	return schema
end

function ThemeBuilder.build(schema, parent)
	if type(schema) ~= "table" or not schema.Class then
		error("[ThemeBuilder] invalid schema: " .. tostring(schema))
	end

	--print(schema.Class, parent)
	local ok1, element = pcall(Instance.New, schema.Class, parent)
	if not ok1 or not element then
		error(string.format(
			"[ThemeBuilder] cannot instantiate '%s' (abstract or unknown class): %s",
			tostring(schema.Class), tostring(element)
		), 2)
	end

	for prop, value in pairs(schema.Properties or {}) do
		local ok2, err = pcall(function() element[prop] = value end)
		if not ok2 then
			warn(string.format("[ThemeBuilder] property '%s' failed on %s: %s", tostring(prop), schema.Class, tostring(err)))
		end
	end

	for name, childSchema in pairs(schema.Children or {}) do
		local child = ThemeBuilder.build(childSchema, element)
		child.Name = name
	end
	return element
end

function ThemeBuilder.createElement(themeName, objectName, parent)
	local element = ThemeBuilder.build(ThemeBuilder.getSchema(themeName, objectName), parent)
	element.Name = objectName
	return element
end

return ThemeBuilder