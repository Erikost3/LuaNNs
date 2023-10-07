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


local BaseClass = require(game:GetService("ReplicatedStorage").LuaNNs.class)

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

-- Tensor recurse
function Tensor:recurse(...)
    local args = {...}

    local fReturnTensor

    local function recurseiveRecurse(_self, indexList)
        indexList = indexList and Tensor.deepCopy(indexList) or {}
        local depth = #indexList+1
        for i = 1, #_self do
            indexList[depth] = i

            if type(_self[i]) == "table" then
                recurseiveRecurse(_self[i], indexList)
            else
                for j = 1, #args do
                    if type(args[j]) == "function" then
                        local rt = args[j](fReturnTensor or self, unpack(indexList))
                        fReturnTensor = rt
                    end
                end
            end
        end
    end

    assert(fReturnTensor == nil or pcall(function() Tensor.shape(fReturnTensor) end), "Tensor.recurse: Tensor returned by function(s) were broken")

    recurseiveRecurse(self)

    return fReturnTensor or self
end

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

    local newSelf
    local function recursiveConstruct(pastIndicies)
        for i = 1, shape[pastIndicies and #pastIndicies > 0 and #pastIndicies+1 or 1] do
            local indicies = pastIndicies and table.clone(pastIndicies) or {}
            indicies[#indicies+1] = i

            if #indicies < #shape then
                newSelf = Tensor.setReindex(newSelf, Tensor.reindex(self, indicies) or {}, indicies)
                recursiveConstruct(indicies)
            else
                for j = 1, #funcs do
                    newSelf = Tensor.setReindex(newSelf, funcs[j](unpack(indicies)), indicies)
                end
            end
        end
    end

    if #shape > 0 then
        if #funcs < 1 then
            table.insert(funcs, function(...)
                return 0
            end)
        end
        newSelf = {}
        recursiveConstruct()
        for i, v in newSelf do
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

-- Tensor deep copy
function Tensor:deepCopy(newSelf)
    newSelf = newSelf or {}
    for i, v in pairs(self) do
        if type(v) == "table" then
            newSelf[i] = Tensor.deepCopy(v)
        else
            newSelf[i] = v
        end
    end
    return newSelf
end

-- Tensor reindex (repeated indexing)
function Tensor:reindex(...)
    local indcies = {...}

    if type(indcies[1]) == "table" then
        indcies = indcies[1]
    end

    local result = self

    for i = 1, #indcies do
        assert(type(indcies[i]) == "number", "Tensor.reindex: indcies must be numbers")
        result = result[indcies[i]]
        if type(result) ~= "table" then break end
    end

    return result
end

-- Tensor setReindex (repeated set index)
function Tensor:setReindex(value, ...)
    local indcies = {...}

    if type(indcies[1]) == "table" then
        indcies = indcies[1]
    end

    local clone = Tensor.deepCopy(self)
    local newSelf = clone
	
	for i = 1, #indcies - 1 do
        if newSelf[indcies[i]] == nil then
            newSelf[indcies[i]] = {}
        end
		newSelf = newSelf[indcies[i]]
	end
	
	newSelf[indcies[#indcies]] = value
	
	return clone
end

-- Tensor flatten
function Tensor:flatten(...)
    local result = {}
    local function recursiveFlatten(v)
        if type(v) == "table" then
            for i = 1, #v do
                recursiveFlatten(v[i])
            end
        else
            table.insert(result, v)
        end
    end
    recursiveFlatten(self)
    return result
end

-- Tensor reshape
function Tensor:reshape(...)

    local newShape = {...}

    assert(#newShape > 0,
        "Tensor.reshape: New shape must be set"
    )

    local flat = Tensor.flatten(self)

    local product = 1
    for i = 1, #newShape do
        product *= newShape[i]
    end

    assert(
        product == #flat, 
        "Tensor.reshape: New shape must be compatible with existing, flattened: '"..
        tostring(#flat)..
        "', new shape: '"..
        tostring(product)..
        "'"
    )

    local allnums = true
    for i = 1, #self do
        allnums = allnums and type(self[i]) == "number"
    end

    assert(
        not allnums or allnums and #newShape == 1 and newShape[1] == #self,
        "Tensor.reshape: tried to reshape vector with incompatible shape, flattened: '"..
        tostring(#flat)..
        "', new shape: '"..
        tostring(newShape[1])..
        "'"
    )

    if allnums then
        return self
    end

    local function recursiveReshape(v, depth)
        depth = depth or 1
        if depth == #newShape then
            for i = 1, newShape[depth] do
                table.insert(v, flat[1])
                table.remove(flat, 1)
            end
        else
            for i = 1, newShape[depth] do
                v[i] = v[i] or {}
                recursiveReshape(v[i], depth + 1)
            end
        end
    end

    local result = {}

    recursiveReshape(result)

    return result
end

-- Tensor transpose
function Tensor:transpose(...)
    
    local shape = Tensor.shape(self)
    local indicies = {...}

    if #indicies == 0 then
        if #shape == 1 then
            table.insert(indicies, 1)
        else
            for i = 1, #shape do
                if i == #shape-1 then
                    table.insert(indicies, #shape)
                elseif i == #shape then
                    table.insert(indicies, #shape-1)
                else
                    table.insert(i)
                end
            end
        end
    end

    assert(#indicies == #shape, "Tensor.transpose: the amount of indicies doesn't match the shape of the tensor")

    if #shape == 1 then
        return Tensor(self:deepCopy())
    end

    local newSelf = {}

    local function recursiveTranspose(indexList)
        indexList = indexList and Tensor.deepCopy(indexList) or {}
        local depth = #indexList+1
        if depth == #shape then
            for i = 1, shape[depth] do
                indexList[depth] = i
                local setReindexIndicies = {}
                for j = 1, #indicies do
                    setReindexIndicies[j] = indexList[indicies[j]]
                end
                newSelf = Tensor.setReindex(newSelf, self:reindex(indexList), setReindexIndicies)
            end
        elseif shape[depth] and type(Tensor.reindex(self, shape[depth])) == "table" then
            for i = 1, shape[depth] do
                indexList[depth] = i
                recursiveTranspose(indexList)
            end
        else
            error("LuaNNs.Transpose: broken tensor")
        end
    end
    
    local function recursiveRecurse(t, ...)
        local indexList = {...}
        local getReindexIndicies = {}
        for j = 1, shape[#indicies] do
            getReindexIndicies[j] = indexList[indicies[j]]
        end
        newSelf = Tensor.setReindex(newSelf, self:reindex(indexList), getReindexIndicies)
        return newSelf
    end

    return self:recurse(recursiveRecurse)
end

-- Tensor einsum
function Tensor.einsum(raw_notation, ...)
    
    local notation = string.split(raw_notation, "->")

    local notationLeft = string.split(notation[1], ",")
    local notationRight = string.split(notation[2], ",")

    local tensors = {...}

    -- Transpose case
    if #notationLeft == 1 and #notationRight == 1 then

        -- Make sure notation contain same indcies
        for i = 1, #string.split(notationLeft[1], "") do
            assert(string.find(notationRight[1], string.sub(notationLeft[1], i, i)), "Tensor.einsum: in notation tensors does not contain same indcies")
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