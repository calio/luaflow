describe("Luaflow tests", function()
    local lib = require "luaflow_lib"
    local concat = table.concat

    local function test_file_path(s)
        return "tests/" .. s
    end
    local function verify_flow(lua, flow_file)
        local f = assert(io.open(test_file_path(flow_file)))
        local txt = f:read("*a")
        f:close()

        local t, ctx = lib.parse_file(test_file_path(lua))
        lib.adjust_ctx(ctx)
        local flow = lib.get_root_flow(ctx)
        assert.are.equal(concat(flow), txt)
    end

    it("sanity", function()
        verify_flow("sanity.lua", "sanity.txt")
    end)

end)
