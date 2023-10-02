ifndef CLUSTER
$(error CLUSTER is not set)
endif

.PHONY: default
default:
	@echo "No default"

.PHONY: vault
vault: vault-create vault-config vault-secrets
#	create vault
#	prepare vault secrets config for provisioning
#	initialize vault with example secrets

.PHONY: vault-delete
vault-delete:
	op vault delete $(CLUSTER)
	@echo "----------"
	op connect server delete $(CLUSTER)
	@echo "----------"
	@rm -rf $(CLUSTER)



.PHONY: vault-create
vault-create:
	@op vault create $(CLUSTER) --description "Vault for Kubernetes Cluster $(CLUSTER)"
	@echo "----------"
	@op connect server create $(CLUSTER) --vaults $(CLUSTER)
	@mkdir -p $(CLUSTER)/originals
	@mv 1password-credentials.json $(CLUSTER)/originals
	@op connect token create $(CLUSTER)-operator --server $(CLUSTER) --vault $(CLUSTER),r > $(CLUSTER)/originals/token
	@echo "----------"

.PHONY: vault-config
vault-config:
	@echo "Prepare vault secrets for 1Password-Operator deployment"
	@cp kustomization.yaml.template $(CLUSTER)/kustomization.yaml
	@cp namespace.yaml.template $(CLUSTER)/namespace.yaml
	
#	add newline at end of 1password-credentials.json
	@sed -e '$$a\' $(CLUSTER)/originals/1password-credentials.json > $(CLUSTER)/1password-credentials.json

#	encode 1password-credentials.json as base64
	@base64 -i $(CLUSTER)/1password-credentials.json > $(CLUSTER)/1password-credentials.json.base64
	
#	remove newline at end of 1password-credentials.json.base64
	@tr -d '\n' < $(CLUSTER)/1password-credentials.json.base64 > $(CLUSTER)/1password-credentials.json.base64.nnl

#	clean up unnecessary extensions
	@rm $(CLUSTER)/1password-credentials.json.base64
	@mv $(CLUSTER)/1password-credentials.json.base64.nnl $(CLUSTER)/1password-credentials.json

#	remove newline at end of token
	@tr -d '\n' < $(CLUSTER)/originals/token > $(CLUSTER)/token
	@echo "----------"


# # OLD WORKAROUND
# .PHONY: vault-update-helm
# vault-update-helm:
# 	@export K3D_OP_TOKEN=$(shell cat $(CLUSTER)/token) && yq -i '.spec.values.operator.token.value = env(K3D_OP_TOKEN)' infrastructure/prerequisites/overlays/$(CLUSTER)/op-connect-operator/helm-release-values.yaml 
# 	@export K3D_OP_CREDENTIALS=$(shell base64 -i $(CLUSTER)/1password-credentials.json) && yq -i '.spec.values.connect.credentials_base64 = env(K3D_OP_CREDENTIALS)' infrastructure/prerequisites/overlays/$(CLUSTER)/op-connect-operator/helm-release-values.yaml 


.PHONY: vault-secrets
vault-secrets:
	@echo "Provision secrets to vault"
	@python3 secrets_generator.py $(CLUSTER).secrets.yaml
	@echo "----------"
