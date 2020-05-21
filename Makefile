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

include ./mk.d/debian.mk
include ./mk.d/source.mk
