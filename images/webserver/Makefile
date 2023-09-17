REGISTRY := joernarne
IMAGE := webserver
RELEASE := latest

.PHONY: build
build: build-release


.PHONY: build-release
build-release:
	docker buildx build . \
		--platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
		--tag $(REGISTRY)/$(IMAGE):$(RELEASE) \
		--push \
		--no-cache
