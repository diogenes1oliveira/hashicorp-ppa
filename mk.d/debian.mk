
.PHONY: generate
generate: $(BUILD_FILES)
	@find $(OUT) -type f

$(PACKAGE_FILES): $(OUT)/%: %
	@ mkdir -p $(OUT)
	@ cp $< $@

$(OUT)/Makefile: debian/Makefile.template $(VERSION_VARS_FILE)
	@ mkdir -p $(OUT)
# prefixing the vars with 'export' so the shell will pick them up
	@ eval "`cat $(VERSION_VARS_FILE) | xargs echo export`" \
		&& cat $< | envsubst $(VERSION_VARS) > $@

$(PACKAGE_DEBIAN_FILES): $(OUT)/debian/%: debian/$(PACKAGE).d/%
	@ mkdir -p $(OUT)
	@ cp $< $@

$(GENERIC_DEBIAN_NORMAL_FILES): $(OUT)/debian/%: debian/%
	@ mkdir -p $(OUT)/debian
	@ cp $< $@

$(GENERIC_DEBIAN_TEMPLATE_FILES): $(OUT)/debian/%: debian/%.template $(VERSION_VARS_FILE)
	@ mkdir -p $(OUT)/debian
# prefixing the vars with 'export' so the shell will pick them up
	@ eval "`cat $(VERSION_VARS_FILE) | xargs echo export`" \
		&& export AUTHOR_NAME="`git config user.name`" \
		&& export AUTHOR_EMAIL="`git config user.email`" \
		&& export BUILD_TIME="`date --utc -R`" \
		&& cat $< | envsubst $(VERSION_VARS),\$$AUTHOR_NAME,\$$AUTHOR_EMAIL,\$$BUILD_TIME > $@
