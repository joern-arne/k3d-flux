ifndef CLUSTER
$(error CLUSTER is not set)
endif



.PHONY: default
default:
	@echo "No default"



$(CLUSTER):
	@$(MAKE) vault-create vault-config vault-secrets
#	create vault
#	prepare vault secrets config for provisioning
#	initialize vault with example secrets



.PHONY: vault-delete
vault-delete:
	-op vault delete $(CLUSTER)
	@echo "----------"
	-op connect server delete $(CLUSTER)
	@echo "----------"
	@rm -rf provisioning/$(CLUSTER)



.PHONY: vault-create
vault-create:
	@op vault create $(CLUSTER) --description "Vault for Kubernetes Cluster $(CLUSTER)"
	@echo "----------"
	@op connect server create $(CLUSTER) --vaults $(CLUSTER)
	@mkdir -p provisioning/$(CLUSTER)/originals
	@mv 1password-credentials.json provisioning/$(CLUSTER)/originals
	@op connect token create $(CLUSTER)-operator --server $(CLUSTER) --vault $(CLUSTER),r > provisioning/$(CLUSTER)/originals/token
	@echo "----------"



.PHONY: vault-config
vault-config:
	@echo "Prepare vault secrets for 1Password-Operator deployment"
	@cp templates/kustomization.yaml.template provisioning/$(CLUSTER)/kustomization.yaml
	@cp templates/namespace.yaml.template provisioning/$(CLUSTER)/namespace.yaml
	
#	add newline at end of 1password-credentials.json
	@sed -e '$$a\' provisioning/$(CLUSTER)/originals/1password-credentials.json > provisioning/$(CLUSTER)/1password-credentials.json

#	encode 1password-credentials.json as base64
	@base64 -i provisioning/$(CLUSTER)/1password-credentials.json > provisioning/$(CLUSTER)/1password-credentials.json.base64
	
#	remove newline at end of 1password-credentials.json.base64
	@tr -d '\n' < provisioning/$(CLUSTER)/1password-credentials.json.base64 > provisioning/$(CLUSTER)/1password-credentials.json.base64.nnl

#	clean up unnecessary extensions
	@rm provisioning/$(CLUSTER)/1password-credentials.json.base64
	@mv provisioning/$(CLUSTER)/1password-credentials.json.base64.nnl provisioning/$(CLUSTER)/1password-credentials.json

#	remove newline at end of token
	@tr -d '\n' < provisioning/$(CLUSTER)/originals/token > provisioning/$(CLUSTER)/token
	@echo "----------"



.PHONY: vault-secrets
vault-secrets:
	@echo "Provision secrets to vault"
	@python3 secrets_generator.py $(CLUSTER).secrets.yaml
	@echo "----------"
