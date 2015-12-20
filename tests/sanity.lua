b = {
    __index = function () end
}

function _M.bar()
    foo.bar.log()
end

local f1, f2 = function () end, function () end
function func_a(i)
    func_b(i)
    return func_c(i)
end

function func_b(i)
    return func_c(i)
end

function func_c(i)
    return i % 2 == 0
end

function main()
    local i = 10
    return func_a(i)
end

function foo()
end

foo()
