----------------
-- Test class --
----------------

local BaseClass = require(game:GetService("ReplicatedStorage").Common.class)

-- Test subclassing
local SubClass = BaseClass:subclass{}

-- Makes ure SubClass is a subclass of BaseClass
assert(
    SubClass:is(BaseClass),
    "Class: SubClass is not a subclass of BaseClass"
)

-- Make instance of SubClass
local instance = SubClass()

-- Make sure instance is an instance of SubClass
assert(
    instance:is(SubClass),
    "Class: instance is not an instance of SubClass"
)

SubClass.test = "test2"

instance = SubClass()

-- Make sure the initializer works
assert(
    instance.test == "test2",
    "Class: instance.test is not 'test2'"
)

-- Make sure the initializer inheritance overrides with initilizer
SubClass.init = function(self)
    self.test = "test"
end

instance = SubClass()

assert(
    instance.test == "test",
    "Class: instance.test is not 'test'"
)
