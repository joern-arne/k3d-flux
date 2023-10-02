# k3d-flux
This repository allows to locally provision [k3s](https://k3s.io/) clusters via [k3d](https://k3d.io/).

All components within the clusters will be provisioned via flux2.

The idea is to locally test out new deployments before rolling these out to k3s-based production clusters.

## Features
* [flux2](https://fluxcd.io/)
  * [weave](https://github.com/weaveworks/weave-gitops)
* [cert-manager](https://cert-manager.io/)
* [Keycloak](https://www.keycloak.org/)
* traefik-forward-auth

## Operators
* [1Password Connect Operator](https://developer.1password.com/docs/connect/)
  * [automatic provisioning of secrets to a cluster-specific 1Password Vault](secrets/README.md)
* [Keycloak Operator](https://www.keycloak.org/guides#operator)
* [Postgres Operator](https://github.com/CrunchyData/postgres-operator)

## Applications
* [game-2048](https://github.com/alexwhen/docker-2048)
* [icinga](https://icinga.com/)
* [node-red](https://nodered.org/)
* [podinfo](https://github.com/stefanprodan/podinfo)
* webserver
* [whoami](https://github.com/traefik/whoami)

# Instructions
All following `make` commands are run from the repository root.
## Select cluster
First you need to select the desired cluster by exporting the CLUSTER variable to your environment

```zsh
export CLUSTER=k3d-dev
```

## Prepare secrets vault for selected cluster
Ensure that a dedicated 1Password Vault is available. Create a vault if it has not yet been setup.

```zsh
make vault
```

## Start selected cluster
To configure the external k3s-ingress, start the cluster, provision the 1Password operator secrets and bootstrap flux, use:
```zsh
make cluster-up
```

## Stop / delete selected cluster
To de-configure the external k3s-ingress and delete the cluster, use:
```zsh
make cluster-delete
```
