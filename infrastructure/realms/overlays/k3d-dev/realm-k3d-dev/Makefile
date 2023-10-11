.PHONY: get
get:
	@while ! kubectl --context $(CLUSTER) -n keycloak-realm-operator get secret keycloak-initial-admin ; do echo "Waiting for my secret. CTRL-C to exit."; sleep 5; done
	@echo $(shell kubectl --context $(CLUSTER) -n keycloak-realm-operator get secret keycloak-initial-admin -o jsonpath='{.data.password}' | base64 --decode)

.PHONY: update
update:
	@while ! kubectl --context $(CLUSTER) -n keycloak-realm-operator get secret keycloak-initial-admin ; do echo "Waiting for my secret. CTRL-C to exit."; sleep 5; done
	@sed -i '' -E 's/(.*ADMIN_PASSWORD: )(.*)/\1$(shell kubectl --context $(CLUSTER) -n keycloak-realm-operator get secret keycloak-initial-admin -o jsonpath='{.data.password}' | base64 --decode)/' externalkeycloak.yaml
	@echo ""
	@echo "  ADMIN_URL(s):   https://$(shell kubectl --context $(CLUSTER) -n keycloak-realm-operator get ingress -o yaml | yq '.items[].spec.rules[].host')/admin/"
	@grep ADMIN_ externalkeycloak.yaml
	@echo ""


.PHONY: enable
enable: update
	@kubectl --context $(CLUSTER) apply -k .

