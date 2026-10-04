local Debug = {}
Debug.verbose = true

local function fmt(...)
	local n = select("#", ...)
	local out = table.create(n)
	for i = 1, n do out[i] = tostring(select(i, ...)) end
	return table.concat(out, " ")
end

function Debug.log(tag, ...)
	if Debug.verbose then print("[" .. tag .. "] " .. fmt(...)) end
end

function Debug.warn(tag, ...)
	warn("[" .. tag .. "] " .. fmt(...))
end

-- pcall wrapper that ALWAYS surfaces failures with a traceback
function Debug.try(tag, fn, ...)
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[" .. tag .. "] ERROR: " .. tostring(err) .. "\n" .. debug.traceback())
	end
	return ok, err
end

return Debug