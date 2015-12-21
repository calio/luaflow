local _M = {}


local cjson = require "cjson"
local parser = require "lua-parser.parser"


local insert = table.insert
local concat = table.concat
local encode = cjson.encode
local GLOBAL = '_G'


function _M.create_ctx()
    return {
        roots = {},
        no_roots = {},
        call = {},
        scope = { GLOBAL },
        seen = {}
    }
end

local function index_str(t)
    local s
    if t[1].tag == "Index" then
        s = index_str(t[1])
    else
        s = t[1][1]
    end

    return s .. "." .. t[2][1]
end

local function process_set_enter(t, ctx)
    -- `Set{ {lhs+} {expr+} }                 -- lhs1, lhs2... = e1, e2...
    for i, v in ipairs(t[2]) do
        if v.tag == "Function" then
            local node = t[1][i]
            local tag = node.tag
            if tag == "Id" then
                v.name = node[1]
            elseif tag == "Index" then
                v.name = index_str(node)
            else
                error("Unexpected node type: " .. tag)
            end
        end
    end
end

-- TODO properly decode function name
-- For code block:
--
--     a = {
--       __index = function () end
--     }
--
-- Current name is : `__index`, should be `a.__index`
local function process_pair_enter(t, ctx)
    if t[2].tag == "Function" then
        t[2].name = t[1][1]
    end
end

local function process_localrec_enter(t, ctx)
    -- `Localrec{ ident expr }                -- only used for 'local function'
    for _, v in ipairs(t[2]) do
        if v.tag == "Function" then
            v.name = t[1][1][1]
            --print(v.name)
        end
    end
end

local function process_function_enter(t, ctx)
    assert(t.name, "No function name: " .. encode(t))
    insert(ctx.scope, t.name)

    -- add new function to root list
    ctx.roots[t.name] = true
end

local function process_function_leave(t, ctx)
    --print("Current scope: ", encode(ctx.scope))
    --print("Deleting scope: ", ctx.scope[#ctx.scope])
    ctx.scope[#ctx.scope] = nil
end

local function process_call_enter(t, ctx)
    local node = t[1]
    local name
    if node.tag == "Id" then
        name = t[1][1]
    elseif node.tag == "Index" then
        name = index_str(node)
    else
        error("Unexpected tag, t: " .. encode(t))
    end
    assert(type(name) == "string", "name is not string" .. encode(name))

    local scope = ctx.scope[#ctx.scope]
    local l = ctx.call[scope]
    if l == nil then
        l = {}
        ctx.call[scope] = l
    end

    l[#l + 1] = name

    -- not root, remove from root list
    --print(name, ctx.roots[name])
    insert(ctx.no_roots, name)
end

local function visit(t, conf, ctx)
    --print(t.tag)
    local handler = conf[t.tag]

    if handler and handler.enter then
        handler.enter(t, ctx)
    end

    for _, v in ipairs(t) do
        if type(v) == "table" then
            visit(v, conf, ctx)
        end
    end

    if handler and handler.leave then
        handler.leave(t, ctx)
    end
end

function _M.parse(ctx, s)
    local t, err = parser.parse(s, "luaflow")

    if not t and err then
        return error(err)
    end

    local conf = {
        Function    = { enter = process_function_enter,
                        leave = process_function_leave },
        Call        = { enter = process_call_enter },
        Set         = { enter = process_set_enter },
        Local       = { enter = process_set_enter },
        Localrec    = { enter = process_localrec_enter },
        Pair        = { enter = process_pair_enter },
    }

    visit(t, conf, ctx)

    return t
end

function _M.adjust_ctx(ctx)
    for _, v in ipairs(ctx.no_roots) do
        ctx.roots[v] = nil
    end
end

local function get_flow(ctx, t, func, indent)
    for _ = 1, indent do
        insert(t, " ")
    end

    assert(type(func) == "string", "name is not string: " .. encode(func))

    insert(t, func)

    local seen = ctx.seen
    if seen[func] and seen[func] > 0 then
        insert(t, " (recursive: see " .. seen[func] .. ")")
        return
    else
        seen[func] = 1
    end

    local callee = ctx.call[func]

    if not callee then
        return
    end

    for i, v in ipairs(callee) do
        insert(t, "\n")
        get_flow(ctx, t, v, indent + 4)
        seen[v] = seen[v] - 1
    end
end

function _M.get_root_flow(ctx)
    local t = {}

    local i = 0
    for _, _ in pairs(ctx.roots) do
        i = i + 1
    end

    if i == 0 then
        local func = ctx.no_roots[1]
        ctx.roots[func] = true
    end

    i = 1
    for k, _ in pairs(ctx.roots) do
        if i ~= 1 then
            insert(t, "\n")
        end
        get_flow(ctx, t, k, 0)
        ctx.seen = {}
        i = i + 1
    end

    if i == 1 then
        
        get_flow(ctx, t, k, 0)
    end

    return t
end

function _M.print_root_flow(ctx)
    local t = _M.get_root_flow(ctx)
    print(concat(t))
end

function _M.parse_file(ctx, fname)
    local file = assert(io.open(fname))
    local s = file:read("*a")
    file:close()

    return _M.parse(ctx, s)
end

return _M
