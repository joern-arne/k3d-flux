# 1Password Connect and Operator

* [helm chart](https://github.com/1Password/connect-helm-charts/tree/main/charts/connect)
* [operator](https://github.com/1Password/onepassword-operator)
* [operator usage guide](https://github.com/1Password/onepassword-operator/blob/main/USAGEGUIDE.md)
* [examples/my-example-secret.yaml](../../overlays/k3d-dev/op-connect-operator/examples/my-example-secret.yaml)
* [examples/my-example-deployment.yaml](../../overlays/k3d-dev/op-connect-operator/examples/my-example-deployment.yaml)

## New Overlay
The idea is to use one vault per cluster

Hence when creating a new overlay a new vault including
* connect-credentials (json)
* operator-token (key)
is required.

Both values are configured through the helm-release values.