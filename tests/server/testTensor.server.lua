----------------
-- TensorTest --
----------------

local Tensor = require(game:GetService("ReplicatedStorage").LuaNNs.tensor)
local TestCase = require(game:GetService("ReplicatedStorage").LuaNNs.testCase)

-- Tensor test case
local testTensor = TestCase:subclass{name = "testTensor"}

-- Test tensor init
function testTensor:testInit()

    -- VECTOR: 1
    local v11 = Tensor(3)
    local v12 = Tensor{0, 0, 0}
    self:assertEquals(v11, v12)
    self:assertEqualsTable(v11, v12)

    -- VECTOR 2
    local v21 = Tensor(3, function(i)
        return i
    end)
    local v22 = Tensor{1, 2, 3}
    self:assertEquals(v21, v22)
    self:assertEqualsTable(v21, v22)

    -- MATRIX: 1
    local m11 = Tensor(3, 3)
    local m12 = Tensor{{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
    self:assertEquals(m11, m12)
    self:assertEqualsTable(m11, m12)

    -- MATRIX: 2
    local m21 = Tensor(3, 3, function(i, j)
        return i and j and i + j
    end)
    local m22 = Tensor{{2, 3, 4}, {3, 4, 5}, {4, 5, 6}}
    self:assertEquals(m21, m22)
    self:assertEqualsTable(m21, m22)

    -- TENSOR: 1
    local t11 = Tensor(3, 3, 3)
    local t12 = Tensor{{{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}, {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}, {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}}
    self:assertEquals(t11, t12)
    self:assertEqualsTable(t11, t12)

    -- TENSOR: 2
    local t21 = Tensor(3, 3, 3, function(i, j, k)
        return i and j and k and i + j + k
    end)
    local t22 = Tensor{{{3, 4, 5}, {4, 5, 6}, {5, 6, 7}}, {{4, 5, 6}, {5, 6, 7}, {6, 7, 8}}, {{5, 6, 7}, {6, 7, 8}, {7, 8, 9}}}
    self:assertEquals(t21, t22)
    self:assertEqualsTable(t21, t22)
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

-- Test tensor recurse
function testTensor:testRecurse()
    
    local v = Tensor {1, 2, 3}
    local f = function(t, i)
        return Tensor(t:setReindex({t[i]}, i))
    end
    self:assertEqualsTable(v:recurse(f), Tensor{
        {1},
        {2},
        {3}
    })

    local m = Tensor {
        {1, 2, 3},
        {1, 2, 3},
        {1, 2, 3}
    }
    local f2 = function(t, i, j)
        return Tensor(t:setReindex({t[i][j]}, i, j))
    end
    self:assertEqualsTable(m:recurse(f2), {
        {{1}, {2}, {3}},
        {{1}, {2}, {3}},
        {{1}, {2}, {3}}
    })
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

    -- VECTOR: 1
    local v1 = Tensor {1}
    self:assertEquals(v1, v1)

    -- VECTOR: 2
    local v2 = Tensor {1, 2, 3}
    self:assertEquals(v2, v2)

    -- MATRIX: 1
    local m1 = Tensor {{1}}
    self:assertEquals(m1, m1)

    -- MATRIX: 2
    local m2 = Tensor {{1}, {1}}
    self:assertEquals(m2, m2)

    -- TENSOR: 1
    local t1 = Tensor {{{1}}}
    self:assertEquals(t1, t1)

     -- TENSOR: 2
     local t2 = Tensor {{{1}}, {{1}}}
     self:assertEquals(t2, t2)
end

-- Test tensor inequality
function testTensor:testInequality()

    -- ARRAY
    self:assertFalse(Tensor{1} == {1})

    -- VECTOR: 1
    local v11 = Tensor {1}
    local v12 = Tensor {2}
    self:assertNotEquals(v11, v12)

    -- VECTOR: 2
    local v21 = Tensor {1, 2, 3}
    local v22 = Tensor {1, 2, 4}
    self:assertNotEquals(v21, v22)

    -- MATRIX: 1
    local m11 = Tensor {{1}}
    local m12 = Tensor {{2}}
    self:assertNotEquals(m11, m12)

    -- MATRIX: 2
    local m21 = Tensor {{1}, {1}}
    local m22 = Tensor {{1}, {2}}
    self:assertNotEquals(m21, m22)

    -- TENSOR: 1
    local t11 = Tensor {{{1}}}
    local t12 = Tensor {{{2}}}
    self:assertNotEquals(t11, t12)

     -- TENSOR: 2
     local t21 = Tensor {{{1}}, {{1}}}
     local t22 = Tensor {{{1}}, {{2}}}
     self:assertNotEquals(t21, t22)
end

-- Test tensor shape
function testTensor:testShape()

    -- VECTOR: 1
    local v = Tensor {1, 2, 3}
    self:assertEqualsTable(v:shape(), {3})

    -- MATRIX: 1
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

    self:assertEqualsTable(t3:shape(), {2, 3, 3})

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
    local v = Tensor {1, 2, 3}
    local v2 = v:deepCopy()
    self:assertEqualsTable(v, v2)

    v = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    v2 = v:deepCopy()

    self:assertEqualsTable(v, v2)
end

-- Test tensor reindexing
function testTensor:testReindex(...)

    local t = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    self:assertEqualsTable(t:reindex(1), Tensor {1, 2, 3})
    self:assertEqualsTable(t:reindex{1}, Tensor {1, 2, 3})

    self:assertEqualsTable(t:reindex(2), Tensor {4, 5, 6})
    self:assertEqualsTable(t:reindex{2}, Tensor {4, 5, 6})

    self:assertEqualsTable(t:reindex(3), Tensor {7, 8, 9})
    self:assertEqualsTable(t:reindex{3}, Tensor {7, 8, 9})


    self:assertEquals(t:reindex(1, 1), 1)
    self:assertEquals(t:reindex{1, 1}, 1)

    self:assertEquals(t:reindex(1, 2), 2)
    self:assertEquals(t:reindex{1, 2}, 2)

    self:assertEquals(t:reindex(1, 3), 3)
    self:assertEquals(t:reindex{1, 3}, 3)

    self:assertEquals(t:reindex(2, 1), 4)
    self:assertEquals(t:reindex{2, 1}, 4)

    self:assertEquals(t:reindex(2, 2), 5)
    self:assertEquals(t:reindex{2, 2}, 5)

    self:assertEquals(t:reindex(2, 3), 6)
    self:assertEquals(t:reindex{2, 3}, 6)

    self:assertEquals(t:reindex(3, 1), 7)
    self:assertEquals(t:reindex{3, 1}, 7)

    self:assertEquals(t:reindex(3, 2), 8)
    self:assertEquals(t:reindex{3, 2}, 8)

    self:assertEquals(t:reindex(3, 3), 9)
    self:assertEquals(t:reindex{3, 3}, 9)


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
    self:assertEquals(t2:reindex{1, 1, 1}, 1)

    self:assertEquals(t2:reindex(1, 1, 2), 2)
    self:assertEquals(t2:reindex{1, 1, 2}, 2)

    self:assertEquals(t2:reindex(1, 1, 3), 3)
    self:assertEquals(t2:reindex{1, 1, 3}, 3)

    self:assertEquals(t2:reindex(1, 2, 1), 4)
    self:assertEquals(t2:reindex{1, 2, 1}, 4)

    self:assertEquals(t2:reindex(1, 2, 2), 5)
    self:assertEquals(t2:reindex{1, 2, 2}, 5)

    self:assertEquals(t2:reindex(1, 2, 3), 6)
    self:assertEquals(t2:reindex{1, 2, 3}, 6)

    self:assertEquals(t2:reindex(1, 3, 1), 7)
    self:assertEquals(t2:reindex{1, 3, 1}, 7)

    self:assertEquals(t2:reindex(1, 3, 2), 8)
    self:assertEquals(t2:reindex{1, 3, 2}, 8)

    self:assertEquals(t2:reindex(1, 3, 3), 9)
    self:assertEquals(t2:reindex{1, 3, 3}, 9)

    self:assertEquals(t2:reindex(2, 1, 1), 1)
    self:assertEquals(t2:reindex{2, 1, 1}, 1)

    self:assertEquals(t2:reindex(2, 1, 2), 2)
    self:assertEquals(t2:reindex{2, 1, 2}, 2)

    self:assertEquals(t2:reindex(2, 1, 3), 3)
    self:assertEquals(t2:reindex{2, 1, 3}, 3)

    self:assertEquals(t2:reindex(2, 2, 1), 4)
    self:assertEquals(t2:reindex{2, 2, 1}, 4)

    self:assertEquals(t2:reindex(2, 2, 2), 5)
    self:assertEquals(t2:reindex{2, 2, 2}, 5)

    self:assertEquals(t2:reindex(2, 2, 3), 6)
    self:assertEquals(t2:reindex{2, 2, 3}, 6)

    self:assertEquals(t2:reindex(2, 3, 1), 7)
    self:assertEquals(t2:reindex{2, 3, 1}, 7)

    self:assertEquals(t2:reindex(2, 3, 2), 8)
    self:assertEquals(t2:reindex{2, 3, 2}, 8)

    self:assertEquals(t2:reindex(2, 3, 3), 9)
    self:assertEquals(t2:reindex{2, 3, 3}, 9)
end

-- Test tensor reindexing invalid
function testTensor:testReindexInvalid(...)
    local t = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    self:assertError(function()
        t:reindex(0, 1)
    end)
end

-- Test tensor setReindex
function testTensor:testSetReindex(...)

    local v = Tensor{}
    self:assertEqualsTable(v:setReindex(1, 1, 1), Tensor{{1}})
    self:assertEqualsTable(v:setReindex(1, {1, 1}), Tensor{{1}})

    local v2 = Tensor {1, 2, 3}

    self:assertEqualsTable(v2:setReindex(2, 1), Tensor{2, 2, 3})
    self:assertEqualsTable(v2:setReindex(2, {1}), Tensor{2, 2, 3})

    local t = Tensor {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }
    
    self:assertEqualsTable(t:setReindex({0, 0, 0}, 1), {
        {0, 0, 0},
        {4, 5, 6},
        {7, 8, 9}
    })
    self:assertEqualsTable(t:setReindex({0, 0, 0}, {1}), {
        {0, 0, 0},
        {4, 5, 6},
        {7, 8, 9}
    })

    self:assertEqualsTable(t:setReindex({0, 0, 0}, 2), {
        {1, 2, 3},
        {0, 0, 0},
        {7, 8, 9}
    })
    self:assertEqualsTable(t:setReindex({0, 0, 0}, {2}), {
        {1, 2, 3},
        {0, 0, 0},
        {7, 8, 9}
    })

    self:assertEqualsTable(t:setReindex({0, 0, 0}, 3), {
        {1, 2, 3},
        {4, 5, 6},
        {0, 0, 0}
    })
    self:assertEqualsTable(t:setReindex({0, 0, 0}, {3}), {
        {1, 2, 3},
        {4, 5, 6},
        {0, 0, 0}
    })

    self:assertEqualsTable(t:setReindex(2, 1, 1), {
        {2, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    })
    self:assertEqualsTable(t:setReindex(2, {1, 1}), {
        {2, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    })

    self:assertEqualsTable(t:setReindex(2, 1, 2), {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    })
    self:assertEqualsTable(t:setReindex(2, {1, 2}), {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    })

    self:assertEqualsTable(t:setReindex(2, 1, 3), {
        {1, 2, 2},
        {4, 5, 6},
        {7, 8, 9}
    })
    self:assertEqualsTable(t:setReindex(2, {1, 3}), {
        {1, 2, 2},
        {4, 5, 6},
        {7, 8, 9}
    })

    self:assertEqualsTable(t:setReindex(2, 2, 1), {
        {1, 2, 3},
        {2, 5, 6},
        {7, 8, 9}
    })
    self:assertEqualsTable(t:setReindex(2, {2, 1}), {
        {1, 2, 3},
        {2, 5, 6},
        {7, 8, 9}
    })

    self:assertEqualsTable(t:setReindex(2, 2, 2), {
        {1, 2, 3},
        {4, 2, 6},
        {7, 8, 9}
    })
    self:assertEqualsTable(t:setReindex(2, {2, 2}), {
        {1, 2, 3},
        {4, 2, 6},
        {7, 8, 9}
    })

    self:assertEqualsTable(t:setReindex(2, 2, 3), {
        {1, 2, 3},
        {4, 5, 2},
        {7, 8, 9}
    })
    self:assertEqualsTable(t:setReindex(2, {2, 3}), {
        {1, 2, 3},
        {4, 5, 2},
        {7, 8, 9}
    })

    self:assertEqualsTable(t:setReindex(2, 3, 1), {
        {1, 2, 3},
        {4, 5, 6},
        {2, 8, 9}
    })
    self:assertEqualsTable(t:setReindex(2, {3, 1}), {
        {1, 2, 3},
        {4, 5, 6},
        {2, 8, 9}
    })

    self:assertEqualsTable(t:setReindex(2, 3, 2), {
        {1, 2, 3},
        {4, 5, 6},
        {7, 2, 9}
    })
    self:assertEqualsTable(t:setReindex(2, {3, 3}), {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 2}
    })


    local t2 = Tensor{
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
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

    self:assertEqualsTable(t2:setReindex({{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}, 1), {
        {
            {0, 0, 0},
            {0, 0, 0},
            {0, 0, 0}
        },
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
    })
    self:assertEqualsTable(t2:setReindex({{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}, {1}), {
        {
            {0, 0, 0},
            {0, 0, 0},
            {0, 0, 0}
        },
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
    })

    self:assertEqualsTable(t2:setReindex({{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}, 2), {
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {0, 0, 0},
            {0, 0, 0},
            {0, 0, 0}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        }
    })
    self:assertEqualsTable(t2:setReindex({{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}, {2}), {
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {0, 0, 0},
            {0, 0, 0},
            {0, 0, 0}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        }
    })

    self:assertEqualsTable(t2:setReindex({{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}, 3), {
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {0, 0, 0},
            {0, 0, 0},
            {0, 0, 0}
        }
    })
    self:assertEqualsTable(t2:setReindex({{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}, {3}), {
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {0, 0, 0},
            {0, 0, 0},
            {0, 0, 0}
        }
    })


    self:assertEqualsTable(t2:setReindex(2, 1, 1, 1), {
        {
            {2, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
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
    })
    self:assertEqualsTable(t2:setReindex(2, {1, 1, 1}), {
        {
            {2, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
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
    })

    self:assertEqualsTable(t2:setReindex(2, 2, 1, 1), {
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {2, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        }
    })
    self:assertEqualsTable(t2:setReindex(2, {2, 1, 1}), {
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {2, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        }
    })

    self:assertEqualsTable(t2:setReindex(2, 3, 1, 1), {
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {2, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        }
    })
    self:assertEqualsTable(t2:setReindex(2, {3, 1, 1}), {
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {1, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        },
        {
            {2, 2, 3},
            {4, 5, 6},
            {7, 8, 9}
        }
    })
end

-- Test tensor flatten
function testTensor:testFlatten(...)

    -- VECTOR: 1
    local v = Tensor{1}
    self:assertEqualsTable(v:flatten(), v)

    -- MATRIX: 1
    local m = Tensor{{1, 2, 3, 4, 5, 6}}
    self:assertEqualsTable(m:flatten(), Tensor{1, 2, 3, 4, 5, 6})

    -- MATRIX: 2
    local m2 = Tensor{{1, 10, 17}, {8, 5, 2}}
    self:assertEqualsTable(m2:flatten(), Tensor{1, 10, 17, 8, 5, 2})

    -- TENSOR: 1
    local t = Tensor{{{1, 2, 3}, {9, 8, 7}}, {{6, 7, 8}, {6, 5, 4}}}
    self:assertEqualsTable(t:flatten(), Tensor{1, 2, 3, 9, 8, 7, 6, 7, 8, 6, 5, 4})

end

-- Test tensor reshape
function testTensor:testReshape(...)

    -- VECTOR: 1
    local v = Tensor{1}
    self:assertEqualsTable(v:reshape(1), v)

    -- MATRIX: 1
    local m = Tensor{{1, 1}}
    self:assertEqualsTable(m:reshape(2, 1), Tensor{{1}, {1}})
    self:assertEqualsTable(m:reshape(1, 2), Tensor{{1, 1}})

    -- MATRIX: 2
    local m2 = Tensor{{1, 1}, {2, 2}}
    self:assertEqualsTable(m2:reshape(2, 2), m2)
    self:assertEqualsTable(m2:reshape(2, 2, 1), Tensor{{{1}, {1}}, {{2}, {2}}})
    self:assertEqualsTable(m2:reshape(2, 1, 2), Tensor{{{1, 1}}, {{2, 2}}})
    self:assertEqualsTable(m2:reshape(1, 2, 2), Tensor{{{1, 1}, {2, 2}}})
    self:assertEqualsTable(m2:reshape(4), Tensor{1, 1, 2, 2})
    self:assertEqualsTable(m2:reshape(1, 4), Tensor{{1, 1, 2, 2}})
    self:assertEqualsTable(m2:reshape(4, 1), Tensor{{1}, {1}, {2}, {2}})
    self:assertEqualsTable(m2:reshape(1, 1, 4), Tensor{{{1, 1, 2, 2}}})
    self:assertEqualsTable(m2:reshape(1, 4, 1), Tensor{{{1}, {1}, {2}, {2}}})
    self:assertEqualsTable(m2:reshape(4, 1, 1), Tensor{{{1}}, {{1}}, {{2}}, {{2}}})

    -- TENSOR: 1
    local t = Tensor{{{1, 1, 2, 2}}, {{3, 3, 4, 4}}}
    self:assertEqualsTable(t:reshape(8), Tensor{1, 1, 2, 2, 3, 3, 4, 4})
    self:assertEqualsTable(t:reshape(1, 8), Tensor{{1, 1, 2, 2, 3, 3, 4, 4}})
    self:assertEqualsTable(t:reshape(8, 1), Tensor{{1}, {1}, {2}, {2}, {3}, {3}, {4}, {4}})
    self:assertEqualsTable(t:reshape(1, 1, 8), Tensor{{{1, 1, 2, 2, 3, 3, 4, 4}}})
    self:assertEqualsTable(t:reshape(1, 8, 1), Tensor{{{1}, {1}, {2}, {2}, {3}, {3}, {4}, {4}}})
    self:assertEqualsTable(t:reshape(8, 1, 1), Tensor{{{1}}, {{1}}, {{2}}, {{2}}, {{3}}, {{3}}, {{4}}, {{4}}})
    self:assertEqualsTable(t:reshape(4, 2), Tensor{{1, 1}, {2, 2}, {3, 3}, {4, 4}})
    self:assertEqualsTable(t:reshape(2, 4), Tensor{{1, 1, 2, 2}, {3, 3, 4, 4}})
    self:assertEqualsTable(t:reshape(2, 2, 2), Tensor{{{1, 1}, {2, 2}}, {{3, 3}, {4, 4}}})

end

-- Test tensor transpose
function testTensor:testTranspose(...)
    -- VECTOR: 1
    local v = Tensor {1}
    self:assertEqualsTable(v:transpose(), {1})

    -- MATRIX: 1
    local m = Tensor {
        {1, 2}
    }
    self:assertEqualsTable(m:transpose(1, 2), m)
    self:assertEqualsTable(m:transpose(2, 1), Tensor{{1}, {2}})

    -- MATRIX: 2
    local m2 = Tensor {
        {1, 2},
        {3, 4}
    }
    self:assertEqualsTable(m2:transpose(1, 2), m2)
    self:assertEqualsTable(m2:transpose(2, 1), Tensor{{1, 3}, {2, 4}})
    self:assertEqualsTable(m2:transpose(), Tensor{{1, 3}, {2, 4}})

    -- TENSOR: 1
    local t = Tensor{
        {
            {1, 2, 3}
        }
    }
    self:assertEqualsTable(t:transpose(1, 2, 3), Tensor{{{1, 2, 3}}})
    self:assertEqualsTable(t:transpose(2, 1, 3), Tensor{{{1, 2, 3}}})
    self:assertEqualsTable(t:transpose(1, 3, 2), Tensor{{{1}, {2}, {3}}})
    self:assertEqualsTable(t:transpose(2, 3, 1), Tensor{{{1}, {2}, {3}}})
    self:assertEqualsTable(t:transpose(3, 1, 2), Tensor{{{1}}, {{2}}, {{3}}})
    self:assertEqualsTable(t:transpose(3, 2, 1), Tensor{{{1}}, {{2}}, {{3}}})
end

-- Test tensor dot product
function testTensor:testTensordot(...)

    -- NUMBER: 1
    self:assertEquals(Tensor.Tensordot(1, 1, 1), 1)

    -- VECTOR: 1
    self:assertEqualsTable(Tensor.Tensordot({1}, {1}, 2), {1})

    -- VECTOR: 2
    self:assertEqualsTable(Tensor.Tensordot({1, 2}, {1, 2}, 2))
end

-- Test tensor einsum
function testTensor:testEinsum(...)
    
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