local _, NS = ...
local API = {}
NS.API = API

function API.public(value)
    return not (type(issecretvalue) == "function" and issecretvalue(value))
end
local function pack(...) return {n = select("#", ...), ...} end
function API.read(fn, ...)
    if type(fn) ~= "function" then return nil end
    local values = pack(pcall(fn, ...))
    if not values[1] then return nil end
    for i = 2, values.n do if not API.public(values[i]) then return nil end end
    return unpack(values, 2, values.n)
end
function API.field(value, key)
    if API.public(value) and type(value) == "table" then
        return API.read(function() return value[key] end)
    end
    return nil
end
