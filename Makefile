VERSION:=0.1.4
RELEASE:=1
SPEC:=specs/luaflow-$(VERSION)-$(RELEASE).rockspec

install:
	cp ./luaflow_lib.lua /usr/local/share/lua/5.1/
	cp ./luaflow /usr/local/bin/
test:
	busted -m "./?.lua" test.lua
release:
	cp specs/luaflow-0.1.3-1.rockspec $(SPEC)
	sed -i "s/version = \"\(.*\)\"/version = \"$(VERSION)-$(RELEASE)\"/" $(SPEC)
	sed -i "s/tag = \"\(.*\)\"/tag = \"v$(VERSION)\"/" $(SPEC)
	@echo
	@echo "git add $(SPEC)"
	@echo "git tag v$(VERSION)"
	@echo "git push"
	@echo "git push --tags"

