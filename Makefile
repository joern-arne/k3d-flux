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


.PHONY: k3d-dev-cluster-bootstrap
k3d-dev-cluster-bootstrap:
	@echo $(shell \
		GITHUB_TOKEN=${GITHUB_TOKEN} \
		KUBECONFIG=${KUBECONFIG} \
		flux bootstrap github \
		--owner=${GITHUB_OWNER} \
		--repository=${REPO} \
		--path=${PATH_DEV} \
		--context=${KUBECONTEXT_DEV} \
		--personal)

.PHONY: k3d-dev-cluster-up
k3d-dev-cluster-up: k3d-dev-cluster-create k3d-dev-cluster-bootstrap

.PHONY: k3d-dev-cluster-create
k3d-dev-cluster-create: enable-ingress
	-rm -rf /tmp/k3d-dev-vol
	mkdir -p /tmp/k3d-dev-vol
	k3d cluster create --config k3d-dev.config.yaml

.PHONY: k3d-dev-cluster-delete
k3d-dev-cluster-delete: disable-ingress
	k3d cluster delete --config k3d-dev.config.yaml

###
###
###

.PHONY: k3d-prod-cluster-bootstrap
k3d-prod-cluster-bootstrap:
	@echo $(shell \
		GITHUB_TOKEN=${GITHUB_TOKEN} \
		KUBECONFIG=${KUBECONFIG} \
		flux bootstrap github \
		--owner=${GITHUB_OWNER} \
		--repository=${REPO} \
		--path=${PATH_PROD} \
		--context=${KUBECONTEXT_PROD} \
		--personal)

.PHONY: k3d-prod-cluster-up
k3d-prod-cluster-up: k3d-prod-cluster-create k3d-prod-cluster-bootstrap

.PHONY: k3d-prod-cluster-create
k3d-prod-cluster-create: enable-ingress
	-rm -rf /tmp/k3d-prod-vol
	mkdir -p /tmp/k3d-prod-vol
	k3d cluster create --config k3d-prod.config.yaml

.PHONY: k3d-prod-cluster-delete
k3d-prod-cluster-delete: disable-ingress
	k3d cluster delete --config k3d-prod.config.yaml

###
###
###

.PHONY: enable-ingress
enable-ingress:
	@( \
		echo "Target IP for ingress is " && \
		cat k3s-ingress/kustomization.yaml | yq '.patches.[].patch' | yq '.[].value' && \
		export KUBECONFIG=/Users/u299496/git/github.com/joern-arne/nexus-services/k3s/kubeconfig && \
		kubectl apply -k k3s-ingress \
	)

.PHONY: disable-ingress
disable-ingress:
	-@( \
		export KUBECONFIG=/Users/u299496/git/github.com/joern-arne/nexus-services/k3s/kubeconfig && \
		kubectl delete -k k3s-ingress \
	)

