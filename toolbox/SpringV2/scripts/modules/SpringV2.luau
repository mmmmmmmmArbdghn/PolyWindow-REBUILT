--[[

// SpringV2

// me = @z5rxtcyvui (in Roblox) or @FrostyWolfus (in Polytoria)

// spaghetti creator               : me
// spaghetti fixer OCD 9000        : Bing AI (o7)
// porter helpers                  : DeepSeek, Qwen, Siri (yes, really), me
// speed boost IV                  : Assistant (Roblox), VSCode Models
// background youtube video player : Sharp LC-32LE375E (EG)

// 2.1 version 18/02/2026 (base)
//   +--> branch Polytoria: 2.0 version || 09/08/2026 ||

changelog:
- added `tweenCustom` for tweening functions; accepts functions instead of instances, the rest of the syntax is similar
- added valueTransformer parameter to both `tween` and `tweenCustom`, particularly useful for 360deg rotations
	
- ported to Luau (Polyria 2.0 flavor)
- fixed pcall overhead that destroyed performance (unnecessary now due to the more stable Luau)
- code also now faster due to it being closer to the baseline original and less workarounds yippee
- retired DynamicPropertyAccessor
]]

--[[ TEMPLATES ==============================================

local template_startValues = {
	[1] = Vector2.New(0.5,0)
}

local template_endValues = {
	[1] = Vector2.New(0.5,1)
}

local template_tweenCunstom_function = function(x, x2, x3) --x is ordered by the startValues table's indices
		print(x, x2, x3)
end

local template_valueTransformer = function(i, value)
		if i == 1 then
				return value*1
		else	
				return value
		end
end

============================================================]]

--[[ EXAMPLES ================================================

Spring.tween(
    GUITestView,
    Spring.springInfo(1, 3),
    { SizeRelative = Vector2.New(0.5, 0.5), PositionRelative = Vector2.New(0.5, 0.25) },
		{ SizeRelative = template_valueTransformer }, --valueTransformers (optional)
		{ PositionRelative = Vector2.New(0.5,0) } --startValues (optional)
)

Spring.tweenCustom(
	template_tweenCunstom_function,
	Spring.springInfo(1, 3),
	template_startValues, --also works with plain {numbers}
	template_endValues,		--also works with plain {numbers}
	{ [1] = template_valueTransformer } --optional
)
	
============================================================]]

local loadStart_CPU = os.clock()

local PropertyHandler = require(script:WaitChild("PropertyHandler")::ModuleScript)

-- Micro optimizations
local min, max, sqrt, exp, cos, sin, log, abs = math.min, math.max, math.sqrt, math.exp, math.cos, math.sin, math.log, math.abs
local pi = math.pi

local module = {}

module.desyncFT_aboveTarget = (1 / 20)
module.bucketsProcessed_perFT = 420
module.epsilon = 0.00000001
module.log_epsilon = log(module.epsilon)
module.settlePosEpsilon = 1e-5
module.settleVelEpsilon = 1e-4

-- Custom High-Performance Signal (Replaces Instance.New("Signal") & BindableEvent)
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _head = nil }, Signal)
end

function Signal:Connect(func)
    local node = { func = func, next = self._head, disconnected = false }
    self._head = node
    
    local connection = {}
    function connection:Disconnect()
        node.disconnected = true
    end
    return connection
end

function Signal:Fire(...)
    local prev = nil
    local node = self._head
    while node do
        if node.disconnected then
            if prev then prev.next = node.next else self._head = node.next end
        else
            node.func(...)
            prev = node
        end
        node = node.next
    end
end

function Signal:Destroy()
    self._head = nil
end

module.fallback_propertyEvent = Signal.new()

function module.getFunc_nParameters(f: (...any) -> ())
    local paramCount, isVariadic = debug.info(f, "a")
    return paramCount, isVariadic
end

---@class springInfo
---@field duration number
---@field bounces number

local bucket = setmetatable({}, { __mode = "k" }) -- Weak keys for auto GC

---@class Spring
local Spring = {}
Spring.__index = Spring

function Spring.new(stiffness: number, dampingRatio: number, initialValue: number?, initialVel: number?)
    local self = setmetatable({}, Spring)
    self.k = stiffness
    self.zeta = dampingRatio
    self.x0 = initialValue or 0
    self.v0 = initialVel or 0
    self.target = self.x0
    self.t0 = tick()

    self.w0 = sqrt(self.k)
    self.wd = self.w0 * sqrt(max(0, 1 - self.zeta * self.zeta))
    return self
end

function Spring:setTarget(newGoal)
    if newGoal == nil then error("newGoal is nil") end
    local now = tick()
    local x, v = self:getState(now)

    self.x0 = x
    self.v0 = v
    self.target = newGoal
    self.t0 = now
    return self
end

function Spring:setInfo(springInfo)
    local now = tick()
    local x, v = self:getState(now)
    local stiffness, dampingRatio = module.springParams(springInfo.duration, springInfo.bounces)

    self.k = stiffness
    self.zeta = dampingRatio
    self.w0 = sqrt(stiffness)
    self.wd = self.w0 * sqrt(max(0, 1 - self.zeta * self.zeta))
    self.x0 = x
    self.v0 = v
    self.t0 = now
    return self
end

function Spring:getState(ctick: number)
    local dt = max(0, ctick - self.t0)
    local x0, v0, xg, w0, dr = self.x0, self.v0, self.target, self.w0, self.zeta
    local A = x0 - xg
    local x, v

    if dr < 1 then
        local wd = self.wd
        local e = exp(-dr * w0 * dt)
        local c = cos(wd * dt)
        local s = sin(wd * dt)
        local B = (v0 + dr * w0 * A) / wd
        x = xg + e * (A * c + B * s)
        v = e * (-((w0 ^ 2 * A + dr * w0 * v0) / wd) * s + v0 * c)
    elseif dr == 1 then
        local e = exp(-w0 * dt)
        local B = v0 + w0 * A
        x = xg + (A + B * dt) * e
        v = e * (B - w0 * (A + B * dt))
    else
        local s = sqrt(dr * dr - 1)
        local r1 = -w0 * (dr - s)
        local r2 = -w0 * (dr + s)
        local C2 = (v0 - r1 * A) / (r2 - r1)
        local C1 = A - C2
        local e1 = exp(r1 * dt)
        local e2 = exp(r2 * dt)
        x = xg + C1 * e1 + C2 * e2
        v = C1 * r1 * e1 + C2 * r2 * e2
    end

    if x ~= x then x = xg end
    if v ~= v then v = 0 end
    return x::number, v::number
end

function module.springParams(duration: number, bounces: number)
    local log_ep = module.log_epsilon
    bounces = max(0, bounces)

    if bounces == 0 then
        local k = (4.6 / duration) ^ 2
        return k, 1
    end

    local scale = 0.7
    local d4 = duration * 4
    local A = -log_ep / (d4 * scale)
    local B = bounces * (pi * pi) / (d4 * scale)
    local w0 = sqrt(A * A + B * B)
    local zeta = A / w0
    zeta = max(0.05, min(zeta, 0.9))
    local k = w0 * w0
    return k, zeta
end

function module.springInfo(duration, bounces)
    return { duration = duration or 1, bounces = bounces or 1 }
end

function module.tween(instance, springInfo, propertyTable, valueTransformers, startValues)
    if instance == nil then
        print("WARN: instance is nil")
        return {
            subTweens = {},
            eventObjects = {},
            stop = function() end,
            getCompletedSignal = function() return module.fallback_propertyEvent end
        }
    end

    local isMultipleSprInfos = springInfo[1] ~= nil
    local stiffness, dampingRatio
    if not isMultipleSprInfos then
        if typeof(springInfo["duration"]) ~= "number" then error("duration must be a number") end
        if typeof(springInfo["bounces"]) ~= "number" then error("bounces must be a number") end
        stiffness, dampingRatio = module.springParams(springInfo.duration, springInfo.bounces)
    end

    local masterTween = bucket[instance]
    if masterTween == nil then
        masterTween = { subTweens = {}, eventObjects = {} }
        bucket[instance] = masterTween
    end

    masterTween.stop = function(propertyTable)
        for _, k in pairs(propertyTable) do
            if masterTween.subTweens then masterTween.subTweens[k] = nil end
            if masterTween.eventObjects then
                local event = masterTween.eventObjects[k]
                if event then event:Fire() end
            end
        end
        if not next(masterTween.subTweens or {}) then
            bucket[instance] = nil
        end
    end

    masterTween.getCompletedSignal = function(propertyKey: string | number)
        local mystery_instance = typeof(instance) ~= "function" and instance :: any or nil
        if mystery_instance and not mystery_instance[propertyKey] then
            error("property [" .. propertyKey .. "] does not exist in instance [" .. tostring(instance) .. "]")
            return
        end
        
        local event = masterTween.eventObjects[propertyKey]
        if not event then
            event = Signal.new()
            masterTween.eventObjects[propertyKey] = event
        end
        
        local conn
        conn = event:Connect(function()
            masterTween.eventObjects[propertyKey] = nil
            conn:Disconnect()
            event:Destroy()
        end)
        
        return event
    end

    for propId, value in pairs(propertyTable) do
        local v_prop
        if typeof(propId) == "number" then
            if not startValues then error("startValue is nil in a custom function call") end
            v_prop = startValues[propId]
        else
            local mystery_instance = typeof(instance) ~= "function" and instance :: any or nil
            v_prop = startValues and startValues[propId] or (mystery_instance and mystery_instance[propId] or nil)
            if not v_prop then error("instance property does not exist: [" .. propId .. "]") end
            if typeof(v_prop) ~= typeof(propertyTable[propId]) then
                error("type mismatch at property [" .. tostring(propId) .. "].")
            end
        end

        local origin = v_prop
        local dimensions = PropertyHandler.getDimensions(v_prop)
        if not dimensions then error("instance property [" .. propId .. "] is not supported") end
        if not (masterTween and masterTween.subTweens) then return masterTween end
        
        local subTween = masterTween.subTweens[propId]
        local i_sprinfo = springInfo
        if isMultipleSprInfos then
            i_sprinfo = springInfo[propId]
            stiffness, dampingRatio = module.springParams(i_sprinfo.duration, i_sprinfo.bounces)
        end

        local dOrigin = table.pack(PropertyHandler.deconstruct(origin))
        local dTarget = table.pack(PropertyHandler.deconstruct(value))

        if subTween then
            for i = 1, dimensions do
                subTween.springs[i]:setInfo(i_sprinfo)
                subTween.springs[i]:setTarget(dTarget[i])
            end
        else
            subTween = { springs = {}, duration = i_sprinfo.duration, type = typeof(origin) }
            for i = 1, dimensions do
                subTween.springs[i] = Spring.new(stiffness, dampingRatio, dOrigin[i]):setTarget(dTarget[i])
            end
            masterTween.subTweens[propId] = subTween
        end

        local override = valueTransformers and valueTransformers[propId] or nil
        if override ~= nil then subTween.valueTransformer = override end
    end

    return masterTween
end

function module.tweenCustom(func: (...any) -> (), springInfo, startValues, endValues, valueTransformers)
    func(table.unpack(endValues))
    func(table.unpack(startValues))
    
    if not next(springInfo) then error("empty springInfo table!") end
    
    local empty_indices = {}
    for i, i_sprinfo in pairs(springInfo) do
        if not (i_sprinfo.duration and i_sprinfo.bounces) then
            table.insert(empty_indices, i)
        end
    end
    
    if next(empty_indices) then
        error("empty springInfo found in list! affected indices: " .. table.concat(empty_indices, " "))
    end
    
    return module.tween(func, springInfo, endValues, valueTransformers, startValues)
end

-- Updater
local t_tick = tick()
local cache_tick = t_tick
local bucketCount = 0
local lastDelta = 1 / 60

local spr_values, temp_propstop = {}, {}
local param_holdout = {}

local calcSprings_toFrame = function(springTable, valueTransformer)
    local allDone = true
    table.clear(spr_values)
    
    for i = 1, #springTable do
        local spring = springTable[i]
        local x, v = spring:getState(cache_tick)
        local target = spring.target
        local value

        local posError = abs(x - target)
        local velMag = abs(v)
        if posError < module.settlePosEpsilon and velMag < module.settleVelEpsilon then
            value = target
        else
            allDone = false
            value = x
        end
        
        if valueTransformer then value = valueTransformer(i, value) end
        spr_values[i] = value
    end
    
    return allDone
end

Hooks.Updated:Connect(function(dt)
    local epsilon = module.epsilon
    local processingTarget = math.floor(module.bucketsProcessed_perFT / (lastDelta + epsilon))
    local processed = 0

    module.fallback_propertyEvent:Fire()

    for curr_inst, master in pairs(bucket) do
        if not master.subTweens or next(master.subTweens) == nil then
            bucket[curr_inst] = nil
            continue
        end

        cache_tick = tick()
        if bucketCount < 1 then t_tick = cache_tick end
        table.clear(temp_propstop)
        
        if typeof(curr_inst) == "function" then
            table.clear(param_holdout)
            for prop, sub in pairs(master.subTweens) do
                local allDone = calcSprings_toFrame(sub.springs, sub.valueTransformer)
                param_holdout[prop] = PropertyHandler.construct(sub.type, spr_values)
                if allDone then table.insert(temp_propstop, prop) end
            end
            curr_inst(table.unpack(param_holdout))
        else
            for prop, sub in pairs(master.subTweens) do
                local allDone = calcSprings_toFrame(sub.springs, sub.valueTransformer)
                local mystery_instance = typeof(curr_inst) ~= "function" and curr_inst :: any or nil
                mystery_instance[prop] = PropertyHandler.construct(sub.type, spr_values)
                if allDone then table.insert(temp_propstop, prop) end
            end
        end
        
        master.stop(temp_propstop)

        processed = processed + 1
        if processed >= processingTarget then
            processed = 0
            continue
        end

        t_tick = cache_tick
        bucketCount = bucketCount + 1
    end

    bucketCount = 0
    lastDelta = dt
end)

print("SpringV2 updater started, loading took (in CPU time): " .. tostring(os.clock() - loadStart_CPU))
return module