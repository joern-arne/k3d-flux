GITHUB_OWNER		:= $(shell op item get "GitHub" --fields "GitHub Username")
GITHUB_TOKEN		:= $(shell op item get "GitHub" --fields token)
REPO				:= k3d-flux
PATH_DEV			:= clusters/k3d-dev
PATH_PROD			:= clusters/k3d-prod
KUBECONFIG			:= ~/.kube/config
KUBECONTEXT_DEV		:= k3d-dev
KUBECONTEXT_PROD	:= k3d-prod


# flux reconcile source git flux-system
# flux get hr podinfo -n podinfo
# flux get kustomizations --watch


.PHONY: k3d-dev-bootstrap
k3d-dev-bootstrap:
	@echo $(shell \
		GITHUB_TOKEN=${GITHUB_TOKEN} \
		KUBECONFIG=${KUBECONFIG} \
		flux bootstrap github \
		--owner=${GITHUB_OWNER} \
		--repository=${REPO} \
		--path=${PATH_DEV} \
		--context=${KUBECONTEXT_DEV} \
		--personal)

.PHONY: k3d-dev-up
k3d-dev-up: k3d-dev-create k3d-dev-bootstrap

.PHONY: k3d-dev-create
k3d-dev-create:
	-rm -rf /tmp/k3d-dev-vol
	mkdir -p /tmp/k3d-dev-vol
	k3d cluster create --config k3d-dev.config.yaml

.PHONY: k3d-dev-delete
k3d-dev-delete:
	k3d cluster delete --config k3d-dev.config.yaml

###
###
###

.PHONY: k3d-prod-bootstrap
k3d-prod-bootstrap:
	@echo $(shell \
		GITHUB_TOKEN=${GITHUB_TOKEN} \
		KUBECONFIG=${KUBECONFIG} \
		flux bootstrap github \
		--owner=${GITHUB_OWNER} \
		--repository=${REPO} \
		--path=${PATH_PROD} \
		--context=${KUBECONTEXT_PROD} \
		--personal)

.PHONY: k3d-prod-up
k3d-prod-up: k3d-prod-create k3d-prod-bootstrap

.PHONY: k3d-prod-create
k3d-prod-create:
	-rm -rf /tmp/k3d-prod-vol
	mkdir -p /tmp/k3d-prod-vol
	k3d cluster create --config k3d-prod.config.yaml

.PHONY: k3d-prod-delete
k3d-prod-delete:
	k3d cluster delete --config k3d-prod.config.yaml
