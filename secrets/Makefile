CLUSTER := k3d-dev

.PHONY: vault
vault: vault-create vault-config vault-init
#	create vault
#	prepare vault secrets config for provisioning
#	initialize vault with example secrets

.PHONY: vault-delete
vault-delete:
	op vault delete $(CLUSTER)
	op connect server delete $(CLUSTER)
	rm -rf $(CLUSTER)



.PHONY: vault-create
vault-create:
	op vault create $(CLUSTER) --description "Vault for Kubernetes Cluster $(CLUSTER)"
	op connect server create $(CLUSTER) --vaults $(CLUSTER)
	mkdir -p $(CLUSTER)/originals
	mv 1password-credentials.json $(CLUSTER)/originals
	op connect token create $(CLUSTER)-operator --server $(CLUSTER) --vault $(CLUSTER),r > $(CLUSTER)/originals/token

.PHONY: vault-config
vault-config:
	cp kustomization.yaml.template $(CLUSTER)/kustomization.yaml
	
#	add newline at end of 1password-credentials.json
	sed -e '$$a\' $(CLUSTER)/originals/1password-credentials.json > $(CLUSTER)/1password-credentials.json

#	encode 1password-credentials.json as base64
	base64 -i $(CLUSTER)/1password-credentials.json > $(CLUSTER)/1password-credentials.json.base64
	
#	remove newline at end of 1password-credentials.json.base64
	tr -d '\n' < $(CLUSTER)/1password-credentials.json.base64 > $(CLUSTER)/1password-credentials.json.base64.nnl

#	clean up unnecessary extensions
	rm $(CLUSTER)/1password-credentials.json.base64
	mv $(CLUSTER)/1password-credentials.json.base64.nnl $(CLUSTER)/1password-credentials.json

#	remove newline at end of token
	tr -d '\n' < $(CLUSTER)/originals/token > $(CLUSTER)/token


# # OLD WORKAROUND
# .PHONY: vault-update-helm
# vault-update-helm:
# 	@export K3D_OP_TOKEN=$(shell cat $(CLUSTER)/token) && yq -i '.spec.values.operator.token.value = env(K3D_OP_TOKEN)' infrastructure/prerequisites/overlays/$(CLUSTER)/op-connect-operator/helm-release-values.yaml 
# 	@export K3D_OP_CREDENTIALS=$(shell base64 -i $(CLUSTER)/1password-credentials.json) && yq -i '.spec.values.connect.credentials_base64 = env(K3D_OP_CREDENTIALS)' infrastructure/prerequisites/overlays/$(CLUSTER)/op-connect-operator/helm-release-values.yaml 


.PHONY: vault-init
vault-init:
	@op item create --category=login \
		--vault="$(CLUSTER)" \
		--title="my_example_item" \
		username=my_example_user \
		--generate-password=20,letters,digits

	@op item create --category=login \
		--vault="$(CLUSTER)" \
		--title="my_example_item_2" \
		"Test Field 1=my test secret" \
		"Test Section 1.Test Field2[text]=Jane Doe" \
		"Test Section 1.Test Field3[date]=1995-02-23" \
		"Test Section 2.Test Field4[text]=$(shell pwgen -sn1 24)"

.PHONY: vault-update-test
vault-update-test:
	@op item edit \
		--vault="$(CLUSTER)" \
		"my_example_item" \
		password=$(shell pwgen -sn1 24)

