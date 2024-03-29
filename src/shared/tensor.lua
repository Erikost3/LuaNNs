local BaseClass = require(game:GetService("ReplicatedStorage").Common.class)

------------------
-- Tensor class --
------------------

--[[

Description: Tensor class for tensor operations

]]


local Tensor = BaseClass:subclass{}

-- Init
function Tensor:init(...)
    
    local args = {...}

    local shape = {}
    for i = 1, #args do
        if type(args[i]) == "number" then
            table.insert(shape, args[i])
        end
    end

    local funcs = {}
    for i = 1, #args do
        if type(args[i]) == "function" then
            table.insert(funcs, args[i])
        end
    end

    local function recursiveConstruct(_shape, ...)
        local indices = {...}
        local scope = {}
        
        for i = 1, shape[#shape] do
            if #_shape - #indices == 1 then
                table.insert(indices, i)
                for j = 1, #funcs do
                    scope[i] = funcs[j](unpack(indices))
                    assert(scope[i] ~= nil, "Tensor.init: function returned nil")
                end
                table.remove(indices)
            else
                table.insert(indices, i)
                table.insert(scope, recursiveConstruct(_shape, unpack(indices)))
                table.remove(indices)
            end
        end

        return scope
    end

    if #shape > 0 then
        if #funcs < 1 then
            table.insert(funcs, function(...)
                return 0
            end)
        end

        local newSelf = recursiveConstruct(shape)
        for i, v in pairs(newSelf) do
            self[i] = v
        end
    end
end

-- __eq (check if two tensors have similar contents, recursively)
function Tensor:__eq(other)
    local equal = true
    for i, v in pairs(self) do
        if type(v) == "table" then
            equal = equal and Tensor.__eq(v, other[i])
        else
            equal = equal and v == other[i]
        end
    end
    return equal
end

-- Tensor shape (recursively)
function Tensor:shape(shape, depth)

    for i = 1, #self do
        -- Make sure types are same
        assert(type(self[1]) == type(self[i]), "Tensor.shape: types are not same, 1: " .. type(self[1]) .. " ~= " .. i .. ": " .. type(self[i]))
    end

    -- Vector case
    if type(self[1]) == "number" then
        return #self
    end

    shape = shape or {}
    depth = depth or 1

    -- Tensors case
    shape[depth] = #self

    for i = 1, #self do
        if not shape[1 + depth] then
            shape[depth + 1] = Tensor.shape(self[i], shape, depth + 1)
        else
            -- Make sure shapes are same
            local depthSize = shape[depth + 1]
            local currentSize = #self[i]
            assert(depthSize == currentSize, "Tensor.shape: shapes are not same at dimension depth(1), " .. 1 + depth .. ": " .. (depthSize or type(depthSize)) .. " ~= " .. (currentSize or type(currentSize)))
            Tensor.shape(self[i], shape, depth + 1)
        end
    end

    if depth > 1 then
        -- Make sure shapes are same
        local depthSize = shape[depth]
        local currentSize = #self
        assert(depthSize == currentSize, "Tensor.shape: shapes are not same at dimension depth(2), " .. depth .. ": " .. (depthSize or type(depthSize)) .. " ~= " .. (currentSize or type(currentSize)))
        return #self
    else
        return shape
    end
end

-- Tensor deep copy (recursively)
function Tensor:deepCopy()
    local newSelf = {}
    for i, v in pairs(self) do
        if type(v) == "table" then
            newSelf[i] = Tensor.deepCopy(v)
        else
            newSelf[i] = v
        end
    end
    return newSelf
end

-- Tensor reindex
function Tensor:reindex(...)

    local indices = {...}
    for i = 1, #indices do
        assert(type(indices[i]) == "number", "Tensor.reindex: indices must be numbers")
        
        self = self[indices[i]]
    end

    return self
end

-- Tensor setReindex
function Tensor:setReindex(value, ...)
    local indices = {...}
    local clone = table.clone(self)
end

-- Tensor einsum
function Tensor.einsum(raw_notation, ...)
    
    local notation = string.split(raw_notation, "->")

    local notationLeft = string.split(notation[1], ",")
    local notationRight = string.split(notation[2], ",")

    local tensors = {...}

    -- Transpose case
    if #notationLeft == 1 and #notationRight == 1 then

        -- Make sure notation contain same indices
        for i = 1, #string.split(notationLeft[1], "") do
            assert(string.find(notationRight[1], string.sub(notationLeft[1], i, i)), "Tensor.einsum: in notation tensors does not contain same indices")
        end

        -- Make sure notation are same shape
        assert(#notationLeft[1] == #notationRight[1], "Tensor.einsum: in notation tensors are not same shape")

        local swapDims = {}
        for i, v in pairs(string.split(notationLeft[1], "")) do
            table.insert(swapDims, string.find(notationRight[1], v), i)
        end

        
        


    end
end

return Tensor