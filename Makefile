ifndef CLUSTER
$(error CLUSTER is not set)
endif

GITHUB_OWNER		:= $(shell op item get "GitHub" --fields "GitHub Username")
GITHUB_TOKEN		:= $(shell op item get "GitHub" --fields token)
REPO				:= k3d-flux
CLUSTER_PATH		:= clusters/$(CLUSTER)
KUBECONFIG			:= $(HOME)/.kube/config
KUBECONTEXT			:= $(CLUSTER)

# flux reconcile source git flux-system
# flux get hr podinfo -n podinfo
# flux get kustomizations --watch

.PHONY: cluster-bootstrap
cluster-bootstrap:
	@echo $(shell \
		GITHUB_TOKEN=${GITHUB_TOKEN} \
		KUBECONFIG=${KUBECONFIG} \
		flux bootstrap github \
		--owner=${GITHUB_OWNER} \
		--repository=${REPO} \
		--path=${CLUSTER_PATH} \
		--context=${KUBECONTEXT} \
		--personal)

.PHONY: cluster-up
cluster-up: cluster-create cluster-bootstrap

.PHONY: cluster-create
cluster-create: enable-ingress
	-rm -rf /tmp/$(CLUSTER)-vol
	mkdir -p /tmp/$(CLUSTER)-vol
	k3d cluster create --config $(CLUSTER).config.yaml

.PHONY: cluster-delete
cluster-delete: disable-ingress
	k3d cluster delete --config $(CLUSTER).config.yaml

###
###
###


.PHONY: enable-ingress
enable-ingress:
	@$(MAKE) -C k3s-ingress enable-ingress

.PHONY: disable-ingress
disable-ingress:
	@$(MAKE) -C k3s-ingress disable-ingress


###
###
###

.PHONY: vault
vault:
	@$(MAKE) -C secrets vault


.PHONY: vault-delete
vault-delete:
	@$(MAKE) -C secrets vault-delete


.PHONY: vault-secrets
vault-secrets:
	@$(MAKE) -C secrets vault-secrets


.PHONY: images-build
images-build:
	@$(MAKE) -C images build
