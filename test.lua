describe("Luaflow tests", function()
    local lib = require "luaflow_lib"
    local concat = table.concat

    local function test_file_path(s)
        return "tests/" .. s
    end

    local function verify_flow(lua_src, flow_txt)
        local ctx = lib.create_ctx()
        local t = lib.parse(ctx, lua_src)
        lib.adjust_ctx(ctx)
        local flow = lib.get_root_flow(ctx)
        flow[#flow + 1] = "\n"
        assert.are.equal(flow_txt, concat(flow))
    end

    local function verify_flow_file(lua_file, flow_file)
        local f = assert(io.open(test_file_path(flow_file)))
        local txt = f:read("*a")
        f:close()

        local ctx = lib.create_ctx()
        local t = lib.parse_file(ctx, test_file_path(lua_file))
        lib.adjust_ctx(ctx)
        local flow = lib.get_root_flow(ctx)
        flow[#flow + 1] = "\n"
        assert.are.equal(txt, concat(flow))
    end

    it("sanity", function()
        verify_flow_file("sanity.lua", "sanity.txt")
        verify_flow([[
        function
            foo()
        end
        function main()
            foo()
        end
        ]],
        "main\n    foo\n")

        verify_flow([[
function foo()
    foo()
end
        ]],
        "foo\n    foo (recursive: see 1)\n")

    end)

end)
