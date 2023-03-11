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

--------------------
-- TestCase class --
--------------------

local TestCase = BaseClass:subclass{}

-- Pretty table
function TestCase:prettyTable(viewIndex)
    if type(self) == "number" then
        return tostring(self)
    end

    assert(type(self) == "table", "TestCase.prettyTable: self is not a table")

    local str = "{"
    for i, v in pairs(self) do
        str = str .. (viewIndex and i .. ":" or "")
        if type(v) == "table" then
            str = str .. TestCase.prettyTable(v, viewIndex)
        else
            str = str .. tostring(v)
        end
        str = str .. ", "
    end
    str = str:sub(1, string.len(str) - 2) .. "}"

    return str
end

-- Fail
function TestCase:fail(message)
    return error("TestCase: "..message, 2)
end

-- assertTrue
function TestCase:assertTrue(value)
    if not value then
        self:fail("Expected true, got false")
    end
end

-- assertFalse
function TestCase:assertFalse(value)
    if value then
        self:fail("Expected false, got true")
    end
end

-- assertEquals
function TestCase:assertEquals(actual, expected)
    if expected ~= actual then
        self:fail("Expected "..tostring(expected)..", got "..tostring(actual))
    end
end

-- assertNotEquals
function TestCase:assertNotEquals(actual, expected)
    if expected == actual then
        self:fail("Expected something other than "..tostring(expected))
    end
end

-- assertNil
function TestCase:assertNil(value)
    if value ~= nil then
        self:fail("Expected nil, got "..tostring(value))
    end
end

-- assertNotNil
function TestCase:assertNotNil(value)
    if value == nil then
        self:fail("Expected something other than nil")
    end
end

-- assertError
function TestCase:assertError(func)
    local success, err = pcall(func)
    if success then
        self:fail("Expected error, got none")
    end
    return success, err
end

-- assertNoError
function TestCase:assertNoError(func)
    local success, err = pcall(func)
    if not success then
        self:fail("Expected no error, got "..tostring(err))
    end
    return success, err
end

-- assertEqualsTable
function TestCase:assertEqualsTable(actual, expected)
    if not recursiveEquals(expected, actual) then
        self:fail("Expected ".. TestCase.prettyTable(expected) ..", got ".. TestCase.prettyTable(actual))
    end
end

-- assertNotEqualsTable
function TestCase:assertNotEqualsTable(actual, expected)
    if recursiveEquals(actual, expected) then
        self:fail("Expected something other than ".. TestCase.prettyTable(expected))
    end
end

-- assertAlmostEquals
function TestCase:assertAlmostEquals(actual, expected, maxError)

    maxError = maxError or .5
    
    if expected == actual then
        return
    end
    
    local diff = expected - actual
    if diff < 0 then
        diff = -diff
    end
    
    if diff > maxError then
        self:fail("Expected "..tostring(expected)..", got "..tostring(actual).." (difference "..tostring(diff)..")")
    end
end

-- assertNotAlmostEquals
function TestCase:assertNotAlmostEquals(actual, expected, maxError)
    local succ = self:assertError(function()
        self:assertAlmostEquals(expected, actual, maxError)
    end)
    if succ then
        self:fail("Expected "..tostring(expected).." to not equal "..tostring(actual))
    end
end

-- Init
function TestCase:init()
    self.name = self.name or "Test"

    self.tests = {}
    self.failures = {}
    self.passed = {}
end

-- Test case
function TestCase:test(func, name)
    
    local start = tick()
    local suc, err = pcall(func, self)

    if not suc then
        table.insert(self.failures, {name = name, message = err, time = tick() - start})
    else
        table.insert(self.passed, {name = name, time = tick() - start})
    end
end

-- Print results
function TestCase:printResults()
    
    local total = #self.tests
    local passed = #self.passed
    local failed = #self.failures

    print("----------------------------------------------------")
    print("Case: "..self.name.." results.")
    print("----------------------------------------------------")
    print("Total: "..total)
    print("Passed: "..passed)
    if failed > 0 then
        print("Failed: "..failed)
    end
    print("----------------------------------------------------")
    
    if failed > 0 then
        warn("Failed tests:")
        for i = 1, #self.failures do
            warn("    "..self.failures[i].name.." - "..self.failures[i].message.." ("..self.failures[i].time.."ms)")
        end
        print("----------------------------------------------------")
    end
    if passed > 0 then
        print("Passed tests:")
        for i = 1, #self.passed do
            print("    "..self.passed[i].name.." ("..(self.passed[i].time * 1000).."ms)")
        end
    end
    print("----------------------------------------------------")
    print("Passed", math.floor((passed / total) * 100).."%", "of the tests")
    print("----------------------------------------------------")
    print("")
end

-- Run all tests
function TestCase:run(patternRule)

    patternRule = patternRule or function(k)
        return string.match(k, "^test")
    end

    for k, v in pairs(getmetatable(self)) do
        if type(v) == "function" and patternRule(k) then
            table.insert(self.tests, {name = k, func = v})
        end
    end

    for i, v in ipairs(self.tests) do
        self:test(v.func, v.name)
    end

    self:printResults()
end

return TestCase