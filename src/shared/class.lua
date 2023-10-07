------------------
-- Class System --
------------------

local function construct(class, ...)

    local args = {...}
    local object
    if type(args[1]) == "table" then
        object = args[1]
        table.remove(args, 1)
    else
        object = {}
    end
    
    assert(rawget(class, "__call"), "Classes must have a __call method")

    setmetatable(object, class)
    object:init(...)

    return object
end

local function subclass(class, _subclass)
    
    _subclass.__index = _subclass or {}
    _subclass.__call = construct

    return setmetatable(_subclass, class)
end

-- Base class
local BaseClass = subclass(
    {
        __call = construct,
    },
    {}
)

BaseClass.init = function(self) end
BaseClass.subclass = subclass

-- Return the class of the given object
function BaseClass.is(self, class)
    
    local meta = getmetatable(self)

    if typeof(meta) == "table" then
        while meta do
            if meta == class then
                return true
            end
            meta = getmetatable(meta)
        end
    else
        return false
    end
end

return BaseClass