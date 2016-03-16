VERSION:=0.1.5
RELEASE:=1
SPEC:=specs/luaflow-$(VERSION)-$(RELEASE).rockspec

install:
	cp ./luaflow_lib.lua /usr/local/share/lua/5.1/
	cp ./luaflow /usr/local/bin/
test:
	busted -m "./?.lua" test.lua
release_spec:
	cp specs/luaflow-0.1.3-1.rockspec $(SPEC)
	sed -i "s/version = \"\(.*\)\"/version = \"$(VERSION)-$(RELEASE)\"/" $(SPEC)
	sed -i "s/tag = \"\(.*\)\"/tag = \"v$(VERSION)\"/" $(SPEC)
release_commit:
	@echo
	git add $(SPEC)
	git commit -m 'Add new spec $(SPEC)'
	git tag v$(VERSION)
	git push --tags
	@echo "luarocks upload --api-key=[key] $(SPEC)"
release: release_spec release_commit
