package = "luaflow"
version = "0.1.4-1"
description = {
   summary = "A tool like GNU cflow but for Lua programming language.",
   detailed = [[
       A tool like GNU cflow but for Lua programming language.
   ]],
   homepage = "https://github.com/calio/luaflow",
   license = "MIT",
}
dependencies = {
   "lua >= 5.1",
   "lua-parser",
   "lua-cjson",
}
source = {
   url = "git://github.com/calio/luaflow.git",
   tag = "v0.1.4",
}
build = {
   type = "builtin",
   modules = {
      luaflow_lib = "luaflow_lib.lua",
   },
   install = {
      lua = {
         luaflow_lib = "luaflow_lib.lua",
      },
      bin = {
         luaflow = "luaflow",
      }
   }
}
