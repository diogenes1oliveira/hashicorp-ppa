ifndef PACKAGE
$(error PACKAGE is not set)
endif

ifndef VERSION
$(error VERSION is not set)
endif

BUILD ?= build
OUT := $(BUILD)/$(PACKAGE)_$(VERSION)

VERSION_VARS := \$$BASE_URL,\$$ARCH,\$$PACKAGE,\$$VERSION,\$$CHECKSUM
VERSION_VARS_FILE := $(OUT).vars

.PHONY: clean
clean:
	@rm -rfv $(BUILD)

.PHONY: echo
echo:
	@echo 'BASE_URL=$${HOME}' | envsubst $(VERSION_VARS)


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

include ./mk.d/debian.mk
include ./mk.d/source.mk
include ./mk.d/docker.mk
