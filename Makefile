GITHUB_OWNER	:= $(shell op item get "GitHub" --fields "GitHub Username")
GITHUB_TOKEN	:= $(shell op item get "GitHub" --fields token)
REPO			:= k3d-flux
PATH			:= clusters/k3d-dev
KUBECONFIG		:= ~/.kube/config
KUBECONTEXT		:= k3d-dev


.PHONY: bootstrap
bootstrap:
	@echo $(shell \
		GITHUB_TOKEN=${GITHUB_TOKEN} \
		KUBECONFIG=${KUBECONFIG} \
		flux bootstrap github \
		--owner=${GITHUB_OWNER} \
		--repository=${REPO} \
		--path=${PATH} \
		--context=${KUBECONTEXT} \
		--personal)

.PHONY: reconcile
reconcile:
	$(shell \
		KUBECONFIG=${KUBECONFIG} \
		flux reconcile source git flux-system --context=${KUBECONTEXT} \
	)

.PHONY: hr-status
hr-status:
	@echo $(shell \
		KUBECONFIG=${KUBECONFIG} \
		flux get hr podinfo -n podinfo --context=${KUBECONTEXT} \
	)

.PHONY: watch
watch:
	$(shell \
		KUBECONFIG=${KUBECONFIG} \
		flux get kustomizations --watch --context=${KUBECONTEXT} \
	)

.PHONY: k3d-up
k3d-up: k3d-create bootstrap

.PHONY: k3d-create
k3d-dev-create:
	-rm -rf /tmp/k3d-dev-vol
	mkdir -p /tmp/k3d-dev-vol
	k3d cluster create --config k3d-dev.config.yaml

.PHONY: k3d-delete
k3d-dev-delete:
	k3d cluster delete --config k3d-dev.config.yaml
