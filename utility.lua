local Utility = {};
Utility.Connections = {};

local Clamp = math.clamp
local Min = math.min
local Max = math.max

local Vec2 = Vector2.new
local Dim2 = UDim2.new
local Color = Color3.new

local Insert = table.insert

function Utility:CreateReactiveTable(InitialData)
    local Data = InitialData or {}
    local Listeners = {
        Read = {},
        Write = {},
        Delete = {}
    }

    local function Notify(Event, Key, Value, OldValue)
        for _, Callback in ipairs(Listeners[Event]) do
            Callback(Key, Value, OldValue)
        end
    end

    local Proxy; Proxy = setmetatable({}, {
        __index = function(_, Key)
            local Value = Data[Key]
            Notify("Read", Key, Value)
            return Value
        end,
        __newindex = function(_, Key, Value)
            local OldValue = Data[Key]
            Data[Key] = Value
            Notify("Write", Key, Value, OldValue)
        end,
        __pairs = function() return pairs(Data) end,
        __len = function() return #Data end,
        __tostring = function() return "ReactiveTable" end,
    })

    function Proxy:OnRead(Callback)
        Insert(Listeners.Read, Callback)
    end

    function Proxy:OnWrite(Callback)
        Insert(Listeners.Write, Callback)
    end

    function Proxy:OnDelete(Callback)
        Insert(Listeners.Delete, Callback)
    end

    function Proxy:Delete(Key)
        local OldValue = Data[Key]
        Data[Key] = nil
        Notify("Delete", Key, nil, OldValue)
    end

    return Proxy
end

function Utility:ConvertNumberRange(Value, OldMin, OldMax, NewMin, NewMax, Clamped)
    local Mapped = ((Value - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin) + NewMin
    if Clamped then
        Mapped = Clamp(Mapped, Min(NewMin, NewMax), Max(NewMin, NewMax))
    end
    return Mapped
end

function Utility:UDim2ToVector2(UDim, ContainerSize)
    local X = UDim.X.Offset + self:ConvertNumberRange(UDim.X.Scale, 0, 1, 0, ContainerSize.X)
    local Y = UDim.Y.Offset + self:ConvertNumberRange(UDim.Y.Scale, 0, 1, 0, ContainerSize.Y)
    return Vec2(X, Y)
end

function Utility:Lerp(A, B, T)
    return A + (B - A) * Clamp(T, 0, 1)
end

function Utility:LerpVector2(A, B, T)
    return Vec2(self:Lerp(A.X, B.X, T), self:Lerp(A.Y, B.Y, T))
end

function Utility:LerpColor(A, B, T)
    return Color(
        self:Lerp(A.R, B.R, T),
        self:Lerp(A.G, B.G, T),
        self:Lerp(A.B, B.B, T)
    )
end

function Utility:LerpUDim2(A, B, T)
    return Dim2(
        self:Lerp(A.X.Scale, B.X.Scale, T), self:Lerp(A.X.Offset, B.X.Offset, T),
        self:Lerp(A.Y.Scale, B.Y.Scale, T), self:Lerp(A.Y.Offset, B.Y.Offset, T)
    )
end

function Utility:Create(Class, Properties)
    local Object = Instance.new(Class)
    for Property, Value in pairs(Properties or {}) do
        Object[Property] = Value
    end
    return Object
end

function Utility:Draw(Class, Properties)
    local Object = Drawing.new(Class)
    for Property, Value in pairs(Properties or {}) do
        Object[Property] = Value
    end
    return Object
end

function Utility:Merge(Table1, Table2)
    local New = {}
    for k, v in pairs(Table1) do New[k] = v end
    for k, v in pairs(Table2) do New[k] = v end
    return New
end

function Utility:Connect(Signal, Callback)
    local Connection = Signal:Connect(Callback)
    Insert(self.Connections, Connection)
    return Connection
end

function Utility:DisconnectAll()
    for _, Connection in ipairs(self.Connections) do
        if Connection then
            Connection:Disconnect()
        end
    end
    self.Connections = {}
end

return Utility
