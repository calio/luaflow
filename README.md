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


**Get a call tree**

    $ luaflow luaflow_lib

**Get a call graph (requires GraphViz)**

    $ luaflow -d luaflow_lib.lua > a.dot
    $ dot -Tpng -o a.png a.dot

**Generated call graph**

![call graph](https://raw.githubusercontent.com/calio/luaflow/master/doc/call_graph.png)

**Get call tree starting from a function (given function name)**

    $ luaflow -m process_set_enter luaflow_lib.lua

**Exclude function from call tree**

    $ luaflow -e insert luaflow_lib.lua
