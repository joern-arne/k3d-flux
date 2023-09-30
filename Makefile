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
k3d-dev-create: enable-ingress
	-rm -rf /tmp/k3d-dev-vol
	mkdir -p /tmp/k3d-dev-vol
	k3d cluster create --config k3d-dev.config.yaml

.PHONY: k3d-dev-delete
k3d-dev-delete: disable-ingress
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
k3d-prod-create: enable-ingress
	-rm -rf /tmp/k3d-prod-vol
	mkdir -p /tmp/k3d-prod-vol
	k3d cluster create --config k3d-prod.config.yaml

.PHONY: k3d-prod-delete
k3d-prod-delete: disable-ingress
	k3d cluster delete --config k3d-prod.config.yaml


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

.PHONY: k3d-dev-vault-create
k3d-dev-vault-create:
	op vault create k3d-dev --description "Vault for Kubernetes Cluster k3d-dev"
	op connect server create k3d-dev --vaults k3d-dev
	mkdir -p secrets/k3d-dev
	mv 1password-credentials.json secrets/k3d-dev
	op connect token create k3d-dev-operator --server k3d-dev --vault k3d-dev,r > secrets/k3d-dev/token
	export K3D_OP_TOKEN=$(shell cat secrets/k3d-dev/token) && yq -i '.spec.values.operator.token.value = env(K3D_OP_TOKEN)' infrastructure/prerequisites/overlays/k3d-dev/op-connect-operator/helm-release-values.yaml 
	export K3D_OP_CREDENTIALS=$(shell cat secrets/k3d-dev/1password-credentials.json | base64) && yq -i '.spec.values.connect.credentials_base64 = env(K3D_OP_CREDENTIALS)' infrastructure/prerequisites/overlays/k3d-dev/op-connect-operator/helm-release-values.yaml 


.PHONY: k3d-dev-vault-init
k3d-dev-vault-init:
	@op item create --category=login \
		--vault='k3d-dev' \
		--title='my_example_item' \
		username=my_example_user \
		--generate-password=20,letters,digits

	@op item create --category=login \
		--vault='k3d-dev' \
		--title='my_example_item_2' \
		'Test Field 1=my test secret' \
		'Test Section 1.Test Field2[text]=Jane Doe' \
		'Test Section 1.Test Field3[date]=1995-02-23' \
		'Test Section 2.Test Field4[text]=$(shell pwgen -sn1 24)'

.PHONY: k3d-dev-vault-delete
k3d-dev-vault-delete:
	op vault delete k3d-dev
	op connect server delete k3d-dev
	rm -rf secrets/k3d-dev

