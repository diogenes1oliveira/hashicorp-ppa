# OUT := $(BUILD)/$(PACKAGE)_$(VERSION).vars

# .PHONY: check
# check: $(OUT)

# $(OUT):

BASE_URL ?= https://releases.hashicorp.com
ARCH ?= linux_amd64


.PHONY: fetch
fetch: $(VERSION_VARS_FILE)

$(VERSION_VARS_FILE): $(OUT)_SHA256SUMS
	@mkdir -p $(BUILD)
	@echo 'BASE_URL=$(BASE_URL)\nARCH=$(ARCH)\nPACKAGE=$(PACKAGE)\nVERSION=$(VERSION)' > $(VERSION_VARS_FILE)
	@cat $< | grep $(PACKAGE)_$(VERSION)_$(ARCH).zip | awk '{print $$1}' | xargs printf 'CHECKSUM=%s\n' >> $(VERSION_VARS_FILE)

$(OUT)_SHA256SUMS: $(OUT)_SHA256SUMS.sig
	@mkdir -p $(BUILD)
	@curl -fL $(BASE_URL)/$(PACKAGE)/$(VERSION)/$(PACKAGE)_$(VERSION)_SHA256SUMS -o $@
	@ if ! gpg --verify $< $@; then rm $@ && exit 1; fi

$(OUT)_SHA256SUMS.sig:
	@mkdir -p $(BUILD)
	@curl -fL $(BASE_URL)/$(PACKAGE)/$(VERSION)/$(PACKAGE)_$(VERSION)_SHA256SUMS.sig -o $@
