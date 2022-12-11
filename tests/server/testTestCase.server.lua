----------------
-- Test class --
----------------

local TestCase = require(game:GetService("ReplicatedStorage").Common.testCase)

local testTestCase = TestCase:subclass{name = "testTestCase"}

-- Test prettyTable
function testTestCase:testPrettyTable()

    -- NUMBER: 1
    local tbl = 1
    local str = TestCase.prettyTable(tbl)
    self:assertEquals(str, "1")

    -- VECTOR: 1
    tbl = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    str = TestCase.prettyTable(tbl)
    self:assertEquals("{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}", str)
    
    -- viewIndex is true
    str = TestCase.prettyTable(tbl, true)
    self:assertEquals("{1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, 10:10}", str)

    -- MATRIX: 1
    local tbl2d = {
        {1, 2, 3}
    }

    local str2d = TestCase.prettyTable(tbl2d)
    self:assertEquals("{{1, 2, 3}}", str2d)

    -- viewIndex is true
    str2d = TestCase.prettyTable(tbl2d, true)
    self:assertEquals("{1:{1:1, 2:2, 3:3}}", str2d)

    -- MATRIX: 2
    local tbl2d = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9},
        {10, 11, 12}
    }

    local str2d = TestCase.prettyTable(tbl2d)
    self:assertEquals("{{1, 2, 3}, {4, 5, 6}, {7, 8, 9}, {10, 11, 12}}", str2d)

    -- viewIndex is true
    str2d = TestCase.prettyTable(tbl2d, true)
    self:assertEquals("{1:{1:1, 2:2, 3:3}, 2:{1:4, 2:5, 3:6}, 3:{1:7, 2:8, 3:9}, 4:{1:10, 2:11, 3:12}}", str2d)

    -- TENSOR: 1

    local tbl2d = {{
        {1, 2, 3}
    }}

    local str2d = TestCase.prettyTable(tbl2d)
    self:assertEquals("{{{1, 2, 3}}}", str2d)

    -- viewIndex is true
    str2d = TestCase.prettyTable(tbl2d, true)
    self:assertEquals("{1:{1:{1:1, 2:2, 3:3}}}", str2d)

    -- TENSOR: 2
    local tbl2d = {{
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9},
        {10, 11, 12}
    }}

    local str2d = TestCase.prettyTable(tbl2d)
    self:assertEquals("{{{1, 2, 3}, {4, 5, 6}, {7, 8, 9}, {10, 11, 12}}}", str2d)

    -- viewIndex is true
    str2d = TestCase.prettyTable(tbl2d, true)
    self:assertEquals("{1:{1:{1:1, 2:2, 3:3}, 2:{1:4, 2:5, 3:6}, 3:{1:7, 2:8, 3:9}, 4:{1:10, 2:11, 3:12}}}", str2d)
end

-- Test assertTrue
function testTestCase:testAssertTrue()
    self:assertTrue(true)
end

-- Test assertFalse
function testTestCase:testAssertFalse()
    self:assertFalse(false)
end

-- Test assertEquals
function testTestCase:testAssertEquals()
    self:assertEquals(1, 1)
end

-- Test assertNotEquals
function testTestCase:testAssertNotEquals()
    self:assertNotEquals(1, 2)
end

-- Test assertNil
function testTestCase:testAssertNil()
    self:assertNil(nil)
end

-- Test assertNotNil
function testTestCase:testAssertNotNil()
    self:assertNotNil(1)
end

-- Test assertError
function testTestCase:testAssertError()
    self:assertError(function()
        error("test")
    end)
end

-- Test assertNoError
function testTestCase:testAssertNoError()
    self:assertNoError(function()
    end)
end

-- Test assertEqualsTable
function testTestCase:testAssertEqualsTable()
    self:assertEqualsTable(1, 1)

    self:assertEqualsTable(true, true)
    self:assertEqualsTable(false, false)
    self:assertEqualsTable("1", "1")

    self:assertEqualsTable({1}, {1})
    self:assertEqualsTable({1, 2}, {1, 2})

    self:assertEqualsTable(
        {{1}}, 
        {{1}}
    )
    self:assertEqualsTable(
        {{1}, {1}}, 
        {{1}, {1}}
    )
    self:assertEqualsTable(
        {{1, 2}, {1, 2}},
        {{1, 2}, {1, 2}}
    )

    self:assertEqualsTable(
        {{{1}}},
        {{{1}}}
    )
    self:assertEqualsTable(
        {{{1}}, {{1}}},
        {{{1}}, {{1}}}
    )
    self:assertEqualsTable(
        {{{1, 2}, {1, 2}}, {{1, 2}, {1, 2}}},
        {{{1, 2}, {1, 2}}, {{1, 2}, {1, 2}}}
    )
    self:assertEqualsTable(
        {{{1, 2}, {1, 2}}, {{1, 2}, {1, 2}}},
        {{{1, 2}, {1, 2}}, {{1, 2}, {1, 2}}}
    )
end

-- Test assertNotEqualsTable
function testTestCase:testAssertNotEqualsTable()
    self:assertNotEqualsTable(1, 2)

    self:assertNotEqualsTable({1}, {2})
    self:assertNotEqualsTable({1, 2}, {1, 3})

    self:assertNotEqualsTable(
        {{1}}, 
        {{2}}
    )
    self:assertNotEqualsTable(
        {{1}, {1}}, 
        {{1}, {2}}
    )
    self:assertNotEqualsTable(
        {{1, 2}, {1, 2}}, 
        {{1, 2}, {1, 3}}
    )
    
    self:assertNotEqualsTable(
        {{{1}}},
        {{{2}}}
    )

    self:assertNotEqualsTable(
        {{{1}}, {{1}}},
        {{{1}}, {{2}}}
    )

    self:assertNotEqualsTable(
        {{{1, 2}, {1, 2}}, {{1, 2}, {1, 2}}},
        {{{1, 2}, {1, 2}}, {{1, 2}, {1, 3}}}
    )

    self:assertNotEqualsTable(
        {{{1, 2}, {1, 2}}, {{1, 2}, {1, 2}}},
        {{{1, 2}, {1, 2}}, {{1, 2}, {1, 3}}}
    )
end

-- Test assertAlmostEquals
function testTestCase.testAssertAlmostEquals(self)
    self:assertAlmostEquals(1.5, 1.0)
    self:assertAlmostEquals(0.5, 1.0)

    self:assertAlmostEquals(9, 10, 1)
    self:assertAlmostEquals(11, 10, 1)
end

-- Test assertNotAlmostEquals
function testTestCase.testAssertNotAlmostEquals(self)
    self:assertAlmostEquals(1.0, 1.0)
    self:assertAlmostEquals(0.89, 1.0)

    self:assertAlmostEquals(9, 10, 1)
    self:assertAlmostEquals(11, 10, 1)
end

-- Run the tests
testTestCase():run()

return true