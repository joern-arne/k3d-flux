PW := $(shell kubectl --context $(CLUSTER) -n keycloak-realm-operator get secret keycloak-initial-admin -o jsonpath='{.data.password}' | base64 --decode)

.PHONY: get
get:
	@echo $(PW)

.PHONY: update
update:
	sed -i '' -E 's/(.*ADMIN_PASSWORD: )(.*)/\1$(PW)/' externalkeycloak.yaml


# while ! kubectl --context $(CLUSTER) -n keycloak-realm-operator get secret keycloak-initial-admin ; do echo "Waiting for my secret. CTRL-C to exit."; sleep 1; done

# while ! kubectl --context $CLUSTER -n keycloak-realm-operator get secret keycloak-initial-admin ; do echo "Waiting for my secret. CTRL-C to exit."; sleep 1; done