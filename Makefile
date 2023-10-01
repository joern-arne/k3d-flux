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

###
###
###

.PHONY: k3d-dev-vault
k3d-dev-vault: k3d-dev-vault-create k3d-dev-vault-config k3d-dev-vault-init
#	create vault
#	prepare vault secrets config for provisioning
#	initialize vault with example secrets

.PHONY: k3d-dev-vault-create
k3d-dev-vault-create:
	op vault create k3d-dev --description "Vault for Kubernetes Cluster k3d-dev"
	op connect server create k3d-dev --vaults k3d-dev
	mkdir -p secrets/k3d-dev/originals
	mv 1password-credentials.json secrets/k3d-dev/originals
	op connect token create k3d-dev-operator --server k3d-dev --vault k3d-dev,r > secrets/k3d-dev/originals/token

.PHONY: k3d-dev-vault-config
k3d-dev-vault-config:
	cp secrets/kustomization.yaml.template secrets/k3d-dev/kustomization.yaml
	
#	add newline at end of 1password-credentials.json
	sed -e '$$a\' secrets/k3d-dev/originals/1password-credentials.json > secrets/k3d-dev/1password-credentials.json

#	encode 1password-credentials.json as base64
	base64 -i secrets/k3d-dev/1password-credentials.json > secrets/k3d-dev/1password-credentials.json.base64
	
#	remove newline at end of 1password-credentials.json.base64
	tr -d '\n' < secrets/k3d-dev/1password-credentials.json.base64 > secrets/k3d-dev/1password-credentials.json.base64.nnl

#	clean up unnecessary extensions
	rm secrets/k3d-dev/1password-credentials.json.base64
	mv secrets/k3d-dev/1password-credentials.json.base64.nnl secrets/k3d-dev/1password-credentials.json

#	remove newline at end of token
	tr -d '\n' < secrets/k3d-dev/originals/token > secrets/k3d-dev/token


# # OLD WORKAROUND
# .PHONY: k3d-dev-vault-update-helm
# k3d-dev-vault-update-helm:
# 	@export K3D_OP_TOKEN=$(shell cat secrets/k3d-dev/token) && yq -i '.spec.values.operator.token.value = env(K3D_OP_TOKEN)' infrastructure/prerequisites/overlays/k3d-dev/op-connect-operator/helm-release-values.yaml 
# 	@export K3D_OP_CREDENTIALS=$(shell base64 -i secrets/k3d-dev/1password-credentials.json) && yq -i '.spec.values.connect.credentials_base64 = env(K3D_OP_CREDENTIALS)' infrastructure/prerequisites/overlays/k3d-dev/op-connect-operator/helm-release-values.yaml 


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

.PHONY: k3d-dev-vault-update-test
k3d-dev-vault-update-test:
	@op item edit \
		--vault='k3d-dev' \
		'my_example_item' \
		password=$(shell pwgen -sn1 24)

.PHONY: k3d-dev-vault-delete
k3d-dev-vault-delete:
	op vault delete k3d-dev
	op connect server delete k3d-dev
	rm -rf secrets/k3d-dev

