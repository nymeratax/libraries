local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

local HttpService = game:GetService("HttpService")

local Registry = {
	Signals = {},
	Callbacks = {}
}

local function split(str: string, sep: string)
	local result = {}
	for part in string.gmatch(str, "[^" .. sep .. "]+") do
		table.insert(result, part)
	end
	return result
end

function Signal.new()
	local self = setmetatable({}, Signal)
	self._bindable = Instance.new("BindableEvent")
	self._argMap = {}
	return self
end

function Signal:Fire(...)
	if not self._bindable then return end

	local key = HttpService:GenerateGUID(false)
	self._argMap[key] = { ... }

	self._bindable:Fire(key)
end

function Signal:Connect(fn: (...any) -> ())
	assert(type(fn) == "function", "Signal:Connect expects a function")

	return self._bindable.Event:Connect(function(key)
		local args = self._argMap[key]
		self._argMap[key] = nil

		if args then
			fn(table.unpack(args))
		else
			warn("[Signal] Missing args for key:", key)
		end
	end)
end

function Signal:Wait()
	local key = self._bindable.Event:Wait()
	local args = self._argMap[key]
	self._argMap[key] = nil

	if args then
		return table.unpack(args)
	end
end

function Signal:Destroy()
	if self._bindable then
		self._bindable:Destroy()
		self._bindable = nil
	end

	self._argMap = nil
	setmetatable(self, nil)
end

function Signal.Get(name: string)
	local segments = split(name, "%.")
	local cursor = Registry.Signals

	for _, part in ipairs(segments) do
		cursor = cursor and cursor[part]
		if not cursor then
			return nil
		end
	end

	return cursor
end

function Signal.New(name: string?)
	if typeof(name) ~= "string" then
		return Signal.new()
	end

	local segments = split(name, "%.")
	local cursor = Registry.Signals

	for i, part in ipairs(segments) do
		if i == #segments then
			cursor[part] = cursor[part] or Signal.new()
			return cursor[part]
		else
			cursor[part] = cursor[part] or {}
			cursor = cursor[part]
		end
	end
end

function Signal.Add(name: string, fn: (...any) -> ())
	if typeof(name) == "string" and typeof(fn) == "function" then
		Registry.Callbacks[name] = fn
	end
end

function Signal.Run(name: string, ...)
	local cb = Registry.Callbacks[name]
	if cb then
		return cb(...)
	end
end

function Signal.Remove(name: string)
	Registry.Callbacks[name] = nil
end

function Signal.Wrap(name: string)
	return function(...)
		local sig = Signal.Get(name)
		if sig then
			sig:Fire(...)
		end
	end
end

return Signal
