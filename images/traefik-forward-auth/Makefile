REGISTRY := joernarne
IMAGE := traefik-forward-auth
RELEASE := 3.1.0



.PHONY: build
build: build-release clean



.PHONY: build-release
build-release: traefik-forward-auth-release
	docker buildx build traefik-forward-auth-release \
		--platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
		--tag $(REGISTRY)/$(IMAGE):$(RELEASE) \
		--push \
		--no-cache



traefik-forward-auth-release:
	@wget https://github.com/mesosphere/traefik-forward-auth/archive/refs/tags/v$(RELEASE).zip
	@unzip -n v$(RELEASE).zip && rm v$(RELEASE).zip
	@mv traefik-forward-auth-$(RELEASE) traefik-forward-auth-release

	@wget --directory-prefix=traefik-forward-auth-release https://letsencrypt.org/certs/staging/letsencrypt-stg-root-x1.pem
	@wget --directory-prefix=traefik-forward-auth-release https://letsencrypt.org/certs/staging/letsencrypt-stg-int-r3.pem

	@cp Dockerfile* traefik-forward-auth-release



.PHONY: clean
clean:
	rm -rf traefik-forward-auth-release



