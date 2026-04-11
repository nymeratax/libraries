local Utility = {};
Utility.Connections = {};

local Insert = table.insert

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
    Insert(Utility.Connections, Connection)
    return Connection
end

return Utility
