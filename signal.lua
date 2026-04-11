local Gmatch = string.gmatch
local Insert = table.insert
local Unpack = table.unpack

local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

local HttpService = game:GetService("HttpService")

local Registry = {
	Signals = {},
	Callbacks = {}
}

function Signal.New()
	local self = setmetatable({}, Signal)
	self.Bindable = Instance.new("BindableEvent")
	self.ArgMap = {}
	return self
end

function Signal:Fire(...)
	if not self.Bindable then return end

	local Key = HttpService:GenerateGUID(false)
	self.ArgMap[Key] = { ... }

	self.Bindable:Fire(Key)
end

function Signal:Connect(Fn)
	assert(type(Fn) == "function", "Signal:Connect expects a function")

	return self.Bindable.Event:Connect(function(Key)
		local Args = self.ArgMap[Key]
		self.ArgMap[Key] = nil

		if Args then
			Fn(Unpack(Args))
		else
			warn("[Signal] Missing args for key:", Key)
		end
	end)
end

function Signal:Wait()
	local Key = self.Bindable.Event:Wait()
	local Args = self.ArgMap[Key]
	self.ArgMap[Key] = nil

	if Args then
		return Unpack(Args)
	end
end

function Signal:Destroy()
	if self.Bindable then
		self.Bindable:Destroy()
		self.Bindable = nil
	end

	self.ArgMap = nil
	setmetatable(self, nil)
end

function Signal.Get(Name)
	local Segments = {}
	for Part in Gmatch(Name, "[^%.]+") do
		Insert(Segments, Part)
	end

	local Cursor = Registry.Signals

	for _, Part in ipairs(Segments) do
		Cursor = Cursor and Cursor[Part]
		if not Cursor then
			return nil
		end
	end

	return Cursor
end

function Signal.NewNamed(Name)
	if type(Name) ~= "string" then
		return Signal.New()
	end

	local Segments = {}
	for Part in Gmatch(Name, "[^%.]+") do
		Insert(Segments, Part)
	end

	local Cursor = Registry.Signals

	for Index, Part in ipairs(Segments) do
		if Index == #Segments then
			Cursor[Part] = Cursor[Part] or Signal.New()
			return Cursor[Part]
		else
			Cursor[Part] = Cursor[Part] or {}
			Cursor = Cursor[Part]
		end
	end
end

function Signal.Add(Name, Fn)
	if type(Name) == "string" and type(Fn) == "function" then
		Registry.Callbacks[Name] = Fn
	end
end

function Signal.Run(Name, ...)
	local Fn = Registry.Callbacks[Name]
	if Fn then
		return Fn(...)
	end
end

function Signal.Remove(Name)
	Registry.Callbacks[Name] = nil
end

function Signal.Wrap(Name)
	return function(...)
		local Sig = Signal.Get(Name)
		if Sig then
			Sig:Fire(...)
		end
	end
end

return Signal
