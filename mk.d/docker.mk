TAG ?= hashicorp-ppa-builder
GNUPGHOME ?= $(HOME)/.gnupg
PPA ?= diogenes1oliveira/hashicorp-ppa

DOCKER_FILES := Dockerfile docker-entrypoint.sh

.PHONY: docker/build
docker/build: $(BUILD)/docker.tag

.PHONY: build
build: $(OUT)_source.changes

.PHONY: deploy/check-vars
deploy/check-vars:
	@ if ! [ -d "$(GNUPGHOME)" ]; then echo 'GNUPGHOME=$(GNUPGHOME) not found' >&2 && exit 1; fi
	@ if ! [ -d "$(OUT)" ]; then echo 'source package not generated' >&2 && exit 1; fi

.PHONY: deploy
deploy: deploy/check-vars
	@ docker run -it --rm \
			-e USER_UID="`id -u`" \
			-e USER_GID="`id -g`" \
			-v "`realpath $(GNUPGHOME)`:/gnupg:ro" \
			-v "`pwd`/$(BUILD):/app" \
			-w /app \
			$(TAG) "cd $(PACKAGE)_$(VERSION) && dput ppa:$(PPA) ../$(PACKAGE)_$(VERSION)_source.changes"

.PHONY: docker/shell
docker/shell:
	@ docker run -it --rm \
			-e USER_UID="`id -u`" \
			-e USER_GID="`id -g`" \
			-v "`realpath $(GNUPGHOME)`:/gnupg:ro" \
			-v "`pwd`/$(BUILD):/app" \
			-w /app \
			$(TAG) "cd $(PACKAGE)_$(VERSION) && bash"

$(BUILD)/docker.tag: $(DOCKER_FILES)
	@docker build -t $(TAG) .
	@mkdir -p $(BUILD) && echo $(TAG) > $@

$(OUT)_source.changes: $(BUILD_FILES) $(VERSION_VARS_FILE) deploy/check-vars
	@ docker run -it --rm \
			-e USER_UID="`id -u`" \
			-e USER_GID="`id -g`" \
			-v "`realpath $(GNUPGHOME)`:/gnupg:ro" \
			-v "`pwd`/$(BUILD):/app" \
			-w /app \
			$(TAG) "cd $(PACKAGE)_$(VERSION) && debuild -S"
