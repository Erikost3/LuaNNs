--[[

MIT License

Copyright (c) 2022 Erikost3

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]


local BaseClass = require(game:GetService("ReplicatedStorage").Common.class)

-- Check if tables contents are the same
local function recursiveEquals(_expected, _actual)
        
    if type(_expected) ~= type(_actual) then
        return false
    end
    
    if type(_expected) ~= "table" then
        return _expected == _actual
    end
  
    if #_expected ~= #_actual then
        return false
    end

    for i = 1, #_expected do
        if not recursiveEquals(_expected[i], _actual[i]) then
            return false
        end
    end

    return true
end

------------------
-- Tensor class --
------------------

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

    if not other['is'] or type(other['is']) ~= "function" then
        return false
    end

    return recursiveEquals(self, other)
end

-- Tensor shape (recursively)
function Tensor:shape()

    for i = 1, #self do
        -- Make sure types are same
        assert(type(self[1]) == type(self[i]), "Tensor.shape: types are not same " .. type(self[1]) .. " ~= " .. type(self[i]))
    end

    local shape = {}

    local function recursiveShape(_self, _depth)
        _depth = _depth or 1

        for i = 1, #_self do
            assert(type(_self[1]) == type(_self[i]), "Tensor.shape: broken tensor with mixed value types")
        end

        if type(_self[1]) == "table" then
            for i = 1, #_self do
                recursiveShape(_self[i], _depth + 1)
            end
        end

        if not shape[_depth] then
            shape[_depth] = #_self
        end

        assert(#_self == shape[_depth], "Tensor.shape: broken tensor shape")
    end

    recursiveShape(self)

    return shape
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