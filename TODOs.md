# TODOs

https://github.com/keycloak/keycloak/issues/10464
https://qdnqn.com/how-to-configure-traefik-on-k3s/

# Current TODO
* configure keycloak-realm-operator on k3d-example
  * continue at [step 4](https://github.com/keycloak/keycloak-realm-operator) - Create resources for the Realm Operator to tell it where the external Keycloak lives
  * properly setup realm for traefik-forward-auth

# All TODOs
## Cloud
* setup [oci.ampere](https://github.com/joern-arne/oci.ampere)
  * define oracle cloud cluster flux deployment

## Authentication
* test [authelia](https://www.authelia.com/)
* check how to automate keycloak ([keycloak operator](https://operatorhub.io/operator/keycloak-operator)?)

## Operations
* check out [OLM](https://github.com/operator-framework/operator-lifecycle-manager) / [operatorhub.io cert-manager](https://operatorhub.io/operator/cert-manager)
* check out [flux guides](https://fluxcd.io/flux/guides/)
## Domain management
* decide on dns (route53, cloudflare, oci) for prod cluster

## Secrets management
* check out flux + SOPS
* implement [ESO](https://external-secrets.io/v0.9.5/provider/1password-automation/) and integrate with 1Password

## Storage
* decide on storage solution at oci
  * nfs
  * longhorn
  * [openebs mayastor](https://github.com/openebs/mayastor)

