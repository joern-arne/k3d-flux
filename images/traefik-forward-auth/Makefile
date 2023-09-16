KUBECONFIG ?= ../../../kubeconfig

LOCAL_AMD64 := $(shell docker images --format '{"repository": "{{.Repository}}", "tag":"{{.Tag}}", "id": "{{.ID}}"}' --all \
		| jq --slurp '[.[] | select(.repository=="localhost:5500/traefik-forward-auth" and (.tag=="latest--amd64"))] | length')

LOCAL_ARM64 := $(shell docker images --format '{"repository": "{{.Repository}}", "tag":"{{.Tag}}", "id": "{{.ID}}"}' --all \
		| jq --slurp '[.[] | select(.repository=="localhost:5500/traefik-forward-auth" and (.tag=="latest--arm64"))] | length')

LOCAL_ARMV7 := $(shell docker images --format '{"repository": "{{.Repository}}", "tag":"{{.Tag}}", "id": "{{.ID}}"}' --all \
		| jq --slurp '[.[] | select(.repository=="localhost:5500/traefik-forward-auth" and (.tag=="latest--armv7"))] | length') 


create-manifest:
	# docker context use desktop-linux
	# @echo "Waiting for docker-registry to be running."
	# @(																																   \
	# 	export KUBECONFIG=$(KUBECONFIG)																								&& \
	# 	while ! kubectl wait --for=jsonpath='{.status.phase}'=Running pod/docker-registry -n container-registry --timeout=-1s ; do	   \
	# 	echo "Waiting for docker-registry to be running." && sleep 1;																   \
	# 	done																														   \
	# )
	
	# sleep 10



# ATTENTION
#	Docker push seems to poison the dns cache on macos. hence add an dns entry to /etc/hosts
# 192.168.1.240	localhost:5500



# @(while [ ! curl -s -o /dev/null -I -w "%{http_code}" https://localhost:5500/v2/ -eq 401 ]; do \
# 	echo "Waiting for docker-registry to react to curl." && sleep 3;	\
# done)

	@test $(LOCAL_AMD64) -eq 1 || $(MAKE) build-amd64
	@docker push localhost:5500/traefik-forward-auth:latest--amd64

	@test $(LOCAL_ARM64) -eq 1 || $(MAKE) build-arm64
	@docker push localhost:5500/traefik-forward-auth:latest--arm64

	@test $(LOCAL_ARMV7) -eq 1 || $(MAKE) build-armv7
	@docker push localhost:5500/traefik-forward-auth:latest--armv7

	@rm -rf ~/.docker/manifests/localhost:5500_traefik-forward-auth-latest
	@echo "Create Manifest"
	@docker manifest create localhost:5500/traefik-forward-auth:latest	\
		--amend localhost:5500/traefik-forward-auth:latest--armv7		\
		--amend localhost:5500/traefik-forward-auth:latest--arm64		\
		--amend localhost:5500/traefik-forward-auth:latest--amd64

	@docker manifest push localhost:5500/traefik-forward-auth:latest
	@make clean

build-armv7: traefik-forward-auth-master
	@docker buildx build \
		--platform linux/arm/v7 \
		traefik-forward-auth-master \
		-f Dockerfile.arm \
		-t localhost:5500/traefik-forward-auth:latest--armv7 \
		--load
		
	@docker push localhost:5500/traefik-forward-auth:latest--armv7


build-arm64: traefik-forward-auth-master
	@docker buildx build \
		--platform linux/arm64 \
		traefik-forward-auth-master \
		-f Dockerfile.arm64 \
		-t localhost:5500/traefik-forward-auth:latest--arm64 \
		--load
		
	@docker push localhost:5500/traefik-forward-auth:latest--arm64


build-amd64: traefik-forward-auth-master
	@docker buildx build \
		--platform linux/amd64 \
		traefik-forward-auth-master \
		-f Dockerfile \
		-t localhost:5500/traefik-forward-auth:latest--amd64 \
		--load
		
	@docker push localhost:5500/traefik-forward-auth:latest--amd64


letsencrypt-stg-root-x1.pem:
	@wget https://letsencrypt.org/certs/staging/letsencrypt-stg-root-x1.pem


letsencrypt-stg-int-r3.pem:
	@wget https://letsencrypt.org/certs/staging/letsencrypt-stg-int-r3.pem


traefik-forward-auth-master: letsencrypt-stg-root-x1.pem letsencrypt-stg-int-r3.pem
	@wget https://github.com/thomseddon/traefik-forward-auth/archive/refs/heads/master.zip
	@unzip -n master.zip && rm master.zip
	@cp letsencrypt-stg-*.pem traefik-forward-auth-master
	@cp Dockerfile* traefik-forward-auth-master


clean:
	rm -rf traefik-forward-auth-master *.pem

clear-local-registry: clean
	@-docker rmi localhost:5500/traefik-forward-auth:latest
	@-docker rmi localhost:5500/traefik-forward-auth:latest--armv7
	@-docker rmi localhost:5500/traefik-forward-auth:latest--arm64
	@-docker rmi localhost:5500/traefik-forward-auth:latest--amd64



# builder: ca.pem
# 	docker buildx create --use \
# 		--name stage-builder \
# 		# --config buildkit.toml \
# 		--driver docker-container

# build-multiarch: traefik-forward-auth-master
# 	docker buildx build \
# 		--platform linux/arm64,linux/amd64 \
# 		traefik-forward-auth-master \
# 		-f Dockerfile.arm64 \
# 		-t registry.k3s.lessingstrasse.org:443/traefik-forward-auth:latest \
# 		--push

