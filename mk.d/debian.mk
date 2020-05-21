
GENERIC_DEBIAN_NORMAL_FILES := $(shell find debian/ -mindepth 1 -maxdepth 1 -type f -not -name '*.template')
GENERIC_DEBIAN_NORMAL_FILES := $(addprefix $(OUT)/,$(GENERIC_DEBIAN_NORMAL_FILES))
GENERIC_DEBIAN_TEMPLATE_FILES := $(shell find debian/ -mindepth 1 -maxdepth 1 -type f -name '*.template' | grep -v Makefile | sed 's/.template//g')
GENERIC_DEBIAN_TEMPLATE_FILES := $(addprefix $(OUT)/,$(filter-out %Makefile.template,$(GENERIC_DEBIAN_TEMPLATE_FILES)))

PACKAGE_DEBIAN_FILES := $(shell find debian/$(PACKAGE).d -type f | sed 's~$(PACKAGE).d/~~g')
PACKAGE_DEBIAN_FILES := $(addprefix $(OUT)/,$(PACKAGE_DEBIAN_FILES))

PACKAGE_FILES := hashicorp-download-release
PACKAGE_FILES := $(addprefix $(OUT)/,$(PACKAGE_FILES))

BUILD_FILES := $(GENERIC_DEBIAN_TEMPLATE_FILES)
BUILD_FILES += $(GENERIC_DEBIAN_NORMAL_FILES)
BUILD_FILES += $(PACKAGE_DEBIAN_FILES)
BUILD_FILES += $(PACKAGE_FILES)
BUILD_FILES += $(OUT)/Makefile

.PHONY: package
package: $(BUILD_FILES)
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
		&& cat $< | envsubst $(VERSION_VARS) > $@
