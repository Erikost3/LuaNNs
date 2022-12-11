----------------
-- Test class --
----------------

local Tensor = require(game:GetService("ReplicatedStorage").Common.tensor)
local TestCase = require(game:GetService("ReplicatedStorage").Common.testCase)

-- Tensor test case
local testTensor = TestCase:subclass{}

testTensor.name = "testTensor"

-- Test tensor init
function testTensor:testInit()
    local t = Tensor(3, 3)
    self:assertEqualsTable(t, {
        {0, 0, 0},
        {0, 0, 0},
        {0, 0, 0}
    })

    local t2 = Tensor(3, 3, function(i, j)
        return i and j and i + j
    end)

    self:assertEqualsTable(t2, {
        {2, 3, 4},
        {3, 4, 5},
        {4, 5, 6}
    })

    -- Test with already initialized tensor
    local t3 = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    self:assertEqualsTable(t3, {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    })
end

-- Test tensor indexing
function testTensor:testIndexing()
    local t = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    self:assertEquals(t[1][1], 1)
    self:assertEquals(t[1][2], 2)
    self:assertEquals(t[1][3], 3)
    self:assertEquals(t[2][1], 4)
    self:assertEquals(t[2][2], 5)
    self:assertEquals(t[2][3], 6)
    self:assertEquals(t[3][1], 7)
    self:assertEquals(t[3][2], 8)
    self:assertEquals(t[3][3], 9)
end

-- Test tensor indexing with invalid indices
function testTensor:testIndexingInvalid()
    local t = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    self:assertError(function()
        self:assertEquals(t[0][1], 1)
    end)
    self:assertError(function()
        self:assertEquals(t[1][0], 1)
    end)
    self:assertError(function()
        self:assertEquals(t[1][4], 1)
    end)
    self:assertError(function()
        self:assertEquals(t[4][1], 1)
    end)
end

-- Test tensor equality
function testTensor:testEquality()

    local t = Tensor {1, 2, 3}
    self:assertEquals(t, t)

    local t2 = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    self:assertEquals(t2, t2)

    local t3 = Tensor {
        {
            { 1, 2, 3 },
            { 4, 5, 6 },
            { 7, 8, 9 }
        }
    }
    self:assertEquals(t3, t3)
end

-- Test tensor inequality
function testTensor:testInequality()

    local t = Tensor {1, 2, 3}
    self:assertNotEquals(t, {1, 2, 0})

    local t2 = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    self:assertNotEquals(t2, {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 0}
    })

    local t3 = Tensor {
        {
            { 1, 2, 3 },
            { 4, 5, 6 },
            { 7, 8, 9 }
        }
    }
    self:assertNotEquals(t3, {
        {
            { 1, 2, 3 },
            { 4, 5, 6 },
            { 7, 8, 0 }
        }
    })
end

-- Test tensor shape
function testTensor:testShape()
    
    local t = Tensor {1, 2, 3}
    self:assertEqualsTable(t:shape(), 3)

    local t2 = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    self:assertEqualsTable(t2:shape(), {3, 3})

    local t3 = Tensor {
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        }
    }
    local shape = t3:shape()
    self:assertEqualsTable(shape, {2, 3, 3})

    local t4 = Tensor {
        {
            {
                {1, 2, 3},
                {4, 5, 6},
                {7, 8, 9}
            },
            {
                {1, 2, 3},
                {4, 5, 6},
                {7, 8, 9}
            }
        },
        {
            {
                {1, 2, 3},
                {4, 5, 6},
                {7, 8, 9}
            },
            {
                {1, 2, 3},
                {4, 5, 6},
                {7, 8, 9}
            }
        }
    }
    self:assertEqualsTable(t4:shape(), {2, 2, 3, 3})
end

-- Test broken tensor shape
function testTensor:testShapeInvalid()

    local n = 1
    self:assertError(function()
        Tensor.shape(n)
    end)

    local t = Tensor {
        {
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        }
    }
    self:assertError(function()
        self:assertEqualsTable(t:shape(), {2, 3, 3})
    end)

    local t2 = Tensor {
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8}
        }
    }
    self:assertError(function()
        self:assertEqualsTable(t2:shape(), {2, 3, 3})
    end)

    local t3 = Tensor {
        {
            {2, 3},
            {4, 5, 6},
            {7, 9}
        },
        {
            {1, 2, 3},
            {4, 6},
            {7, 8, 9}
        }
    }
    self:assertError(function()
        self:assertEqualsTable(t3:shape(), {2, 3, 3})
    end)
end

-- Test tensor deep copy
function testTensor:testDeepCopy()
    local t = Tensor {1, 2, 3}
    local t2 = t:deepCopy()
    self:assertEqualsTable(t, t2)

    t = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    t2 = t:deepCopy()

    self:assertEqualsTable(t, t2)
end

-- Test tensor reindexing
function testTensor:testReindex(...)
    local t = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    self:assertEqualsTable(t:reindex(1), Tensor {1, 2, 3})
    self:assertEqualsTable(t:reindex(2), Tensor {4, 5, 6})
    self:assertEqualsTable(t:reindex(3), Tensor {7, 8, 9})
    self:assertEquals(t:reindex(1, 1), 1)
    self:assertEquals(t:reindex(1, 2), 2)
    self:assertEquals(t:reindex(1, 3), 3)
    self:assertEquals(t:reindex(2, 1), 4)
    self:assertEquals(t:reindex(2, 2), 5)
    self:assertEquals(t:reindex(2, 3), 6)
    self:assertEquals(t:reindex(3, 1), 7)
    self:assertEquals(t:reindex(3, 2), 8)
    self:assertEquals(t:reindex(3, 3), 9)

    local t2 = Tensor {
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        }
    }
    self:assertEquals(t2:reindex(1, 1, 1), 1)
    self:assertEquals(t2:reindex(1, 1, 2), 2)
    self:assertEquals(t2:reindex(1, 1, 3), 3)
    self:assertEquals(t2:reindex(1, 2, 1), 4)
    self:assertEquals(t2:reindex(1, 2, 2), 5)
    self:assertEquals(t2:reindex(1, 2, 3), 6)
    self:assertEquals(t2:reindex(1, 3, 1), 7)
    self:assertEquals(t2:reindex(1, 3, 2), 8)
    self:assertEquals(t2:reindex(1, 3, 3), 9)
    self:assertEquals(t2:reindex(2, 1, 1), 1)
    self:assertEquals(t2:reindex(2, 1, 2), 2)
    self:assertEquals(t2:reindex(2, 1, 3), 3)
    self:assertEquals(t2:reindex(2, 2, 1), 4)
    self:assertEquals(t2:reindex(2, 2, 2), 5)
    self:assertEquals(t2:reindex(2, 2, 3), 6)
    self:assertEquals(t2:reindex(2, 3, 1), 7)
    self:assertEquals(t2:reindex(2, 3, 2), 8)
    self:assertEquals(t2:reindex(2, 3, 3), 9)

end

-- Test tensor reindexing invalid
function testTensor:testReindexInvalid(...)
    local t = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    self:assertError(function()
        t:reindex(0, 1) -- because 0 is nil, can't recursivley index it with 1
    end)
end

-- Test tensor setReindex
function testTensor:testSetReindex(...)

    local t = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    local t2 = t:setReindex({0, 0, 0}, 1)
    self:assertEqualsTable(t, {
        {0, 0, 0},
        {4, 5, 6},
        {7, 8, 9}
    })
    t2 = t:setReindex({0, 0, 0}, 2)
    self:assertEqualsTable(t, {
        {1, 2, 3},
        {0, 0, 0},
        {7, 8, 9}
    })
    t2 = t:setReindex({0, 0, 0}, 3)
    self:assertEqualsTable(t, {
        {1, 2, 3},
        {4, 5, 6},
        {0, 0, 0}
    })

    t2 = t:setReindex(2, 1, 1)
    self:assertEqualsTable(t, {
        {2, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    })
    t2 = t:setReindex(2, 1, 2)
    self:assertEqualsTable(t, {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    })
    t2 = t:setReindex(2, 1, 3)
    self:assertEqualsTable(t, {
        {1, 2, 2},
        {4, 5, 6},
        {7, 8, 9}
    })
    t2 = t:setReindex(2, 2, 1)
    self:assertEqualsTable(t, {
        {1, 2, 3},
        {2, 5, 6},
        {7, 8, 9}
    })
    t2 = t:setReindex(2, 2, 2)
    self:assertEqualsTable(t, {
        {1, 2, 3},
        {4, 2, 6},
        {7, 8, 9}
    })
    t2 = t:setReindex(2, 2, 3)
    self:assertEqualsTable(t, {
        {1, 2, 3},
        {4, 5, 2},
        {7, 8, 9}
    })
    t2 = t:setReindex(2, 3, 1)
    self:assertEqualsTable(t, {
        {1, 2, 3},
        {4, 5, 6},
        {2, 8, 9}
    })
    t2 = t:setReindex(2, 3, 2)
    self:assertEqualsTable(t, {
        {1, 2, 3},
        {4, 5, 6},
        {7, 2, 9}
    })
    t2 = t:setReindex(2, 3, 3)
    self:assertEqualsTable(t, {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 2}
    })

end

-- Test tensor einsum
function testTensor:testEinsum()
    
    local t = Tensor(2, 3, function()
        return 1
    end)

    -- Permutation (same as transpose)
    local out = Tensor.einsum("ij->ji", t)
    local shape = out:shape()
    local expected = {3, 2}
    self:assertEqualsTable(shape, expected)

    -- Summation (return sum of all elements)
    out = Tensor.einsum("ij->", t)
    self:assertEquals(out, 6)

    -- Column sum
    out = Tensor.einsum("ij->j", t)
    self:assertEqualsTable(out:shape(), 3)
    self:assertEqualsTable(out, {2, 2, 2})

    -- Row sum
    out = Tensor.einsum("ij->i", t)
    self:assertEqualsTable(out:shape(), 2)
    self:assertEqualsTable(out, {3, 3})

    -- Matrix-Vector multiplication
    local v = Tensor(1, 3, function()
        return 1
    end)
    out = Tensor.einsum("ij,kj->ik", t, v)
    self:assertEqualsTable(out:shape(), {2, 1})
    self:assertEqualsTable(out, {3, 3})

    -- Matrix-Matrix multiplication
    out = Tensor.einsum("ij,kj->ik", t, t)
    self:assertEqualsTable(out:shape(), {2, 2})
    self:assertEqualsTable(out, {{3, 3}, {3, 3}})

    -- Dot product first row with first row of matrix
    out = Tensor.einsum("i,i->", t[1], t[1])
    self:assertEquals(out, 3)

    -- Dot product with matrix
    out = Tensor.einsum("ij,ij->", t, t)
    self:assertEquals(out, 6)

    -- Hadamard product (elementwise multiplication)
    out = Tensor.einsum("ij,ij->ij", t, t)
    self:assertEqualsTable(out:shape(), {2, 3})
    self:assertEqualsTable(out, {{1, 1, 1}, {1, 1, 1}})

    -- Outer product
    local a = Tensor(3, function()
        return 1
    end)
    local b = Tensor(5, function()
        return 1
    end)
    out = Tensor.einsum("i,j->ij", a, b)
    self:assertEqualsTable(out:shape(), {3, 5})
    self:assertEqualsTable(out, {{1, 1, 1, 1, 1}, {1, 1, 1, 1, 1}, {1, 1, 1, 1, 1}})

    -- Batch Matrix multiplication
    a = Tensor(3, 2, 5, function()
        return 1
    end)
    b = Tensor(2, 5, 3, function()
        return 1
    end)
    out = Tensor.einsum("ijk,ikl->ijl", a, b)
    self:assertEqualsTable(out:shape(), {3, 2, 3})
    self:assertEqualsTable(out, {{{5, 5, 5}, {5, 5, 5}}, {{5, 5, 5}, {5, 5, 5}}, {{5, 5, 5}, {5, 5, 5}}})

    -- Matrix diagonal
    t = Tensor(3, 3, function()
        return 1
    end)
    out = Tensor.einsum("ii->i", t)
    self:assertEqualsTable(out:shape(), 3)
    self:assertEqualsTable(out, {1, 1, 1})

    -- Matrix trace
    out = Tensor.einsum("ii->", t)
    self:assertEquals(out, 3)
end

-- Run tests
local test = testTensor()
test:run()