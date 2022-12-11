----------------
-- Test class --
----------------

local TestCase = require(game:GetService("ReplicatedStorage").Common.testCase)

local testTestCase = TestCase:subclass{}

testTestCase.name = "testTestCase"

-- Test prettyTable
function testTestCase.testPrettyTable(self)

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
function testTestCase.testAssertTrue(self)
    self:assertTrue(true)
end

-- Test assertFalse
function testTestCase.testAssertFalse(self)
    self:assertFalse(false)
end

-- Test assertEquals
function testTestCase.testAssertEquals(self)
    self:assertEquals(1, 1)
end

-- Test assertNotEquals
function testTestCase.testAssertNotEquals(self)
    self:assertNotEquals(1, 2)
end

-- Test assertNil
function testTestCase.testAssertNil(self)
    self:assertNil(nil)
end

-- Test assertNotNil
function testTestCase.testAssertNotNil(self)
    self:assertNotNil(1)
end

-- Test assertError
function testTestCase.testAssertError(self)
    self:assertError(function()
        error("test")
    end)
end

-- Test assertNoError
function testTestCase.testAssertNoError(self)
    self:assertNoError(function()
    end)
end

-- Test assertEqualsTable
function testTestCase.testAssertEqualsTable(self)
    self:assertEqualsTable(1, 1)
    self:assertEqualsTable({1, 2, 3}, {1, 2, 3})
end

-- Test assertNotEqualsTable
function testTestCase.testAssertNotEqualsTable(self)
    self:assertNotEqualsTable(1, 2)
    self:assertNotEqualsTable({1, 2, 3}, {1, 2, 4})
end

-- Test assertAlmostEquals
function testTestCase.testAssertAlmostEquals(self)
    self:assertAlmostEquals(1.0, 1.0)
end

-- Test assertNotAlmostEquals
function testTestCase.testAssertNotAlmostEquals(self)
    self:assertNotAlmostEquals(1.0, 2.0)
end

-- Run the tests
local case = testTestCase()
case:run()

return true