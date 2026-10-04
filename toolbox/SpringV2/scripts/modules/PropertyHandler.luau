-- name: PropertyHandler
-- PORTED TO POLYTORIA 2.0 (Native Performance Build)

local module = {}

local dimensions = {
    boolean     = 1,
    number      = 1,
    Vector2     = 2,
    Vector3     = 3,
    Color       = 4,
    NumberRange = 2,
}

local constructors = {
    boolean = function(x) return x[1] > 0.5 end,
    number = function(x) return x[1] end,
    Vector2 = function(x) return Vector2.New(x[1], x[2]) end,
    Vector3 = function(x) return Vector3.New(x[1], x[2], x[3]) end,
    Color = function(x) return Color.New(x[1], x[2], x[3], x[4]) end,
    NumberRange = function(x) return NumberRange.New(x[1], x[2]) end,
}

local deconstructors = {
    boolean = function(x) return (x and 1 or 0) end,
    number = function(x) return x end,
    Vector2 = function(x) return x.X, x.Y end,
    Vector3 = function(x) return x.X, x.Y, x.Z end,
    Color = function(x) return x.R, x.G, x.B, x.A end,
    NumberRange = function(x) return x.Min, x.Max end,
}

--- Gets the number of dimensions/components for a value.
---@param value any
---@return number
function module.getDimensions(value)
    local vtype = typeof(value)
    if vtype == "table" then
        return #value
    end
    
    local dims = dimensions[vtype]
    if not dims then
        print("WARN: dimensions for type [" .. tostring(vtype) .. "] is not defined! returning 0")
        return 0
    end
    return dims
end

--- Constructs a new value of a dataType from a table of numbers.
---@param dataType string
---@param x {any}
---@return any
function module.construct(dataType, x)
    local constructor = constructors[dataType]
    if not constructor then
        error("handler for type [" .. tostring(dataType) .. "] does not exist!")
    end
    return constructor(x)
end

--- Deconstructs a value into its numeric components.
---@param value any
---@return ...number
function module.deconstruct(value)
    local vtype = typeof(value)
    local deconstructor = deconstructors[vtype]
    if not deconstructor then
        error("deconstructor for type [" .. tostring(vtype) .. "] does not exist!")
    end
    return deconstructor(value)
end

--- Returns the type of a value as a string.
---@param value any
---@return string
function module.typeof(value)
    return typeof(value)
end

return module