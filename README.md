How to install
==============

Install using LuaRocks:

    $ luarocks install luaflow

How to use
==========

    luaflow [OPTIONS] luafile

    OPTIONS:
      -a, --ast             dump AST
      -d, --dot             generate call graph dot file (GraphViz format)
      -e, --exclude         exclude this list of comma separated functions
      -m, --main            main/entry function
      -h, --help            show this help message


Get call tree

    $ luaflow a.lua

Get call graph (requires GraphViz)

    $ luaflow -d a.lua > a.dot
    $ dot -Tpng -o a.png a.dot

Get call tree starting from a function (given function name)

    $ luaflow -m process_set_enter luaflow_lib.lua

Exclude function from call tree

    $ luaflow -e insert luaflow_lib.lua
