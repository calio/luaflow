install:
	cp ./luaflow_lib.lua /usr/local/share/lua/5.1/
	cp ./luaflow /usr/local/bin/
test:
	busted -m "./?.lua" test.lua
