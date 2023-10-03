# keycloak-realm-operator
[keycloak-realm-operator](https://github.com/keycloak/keycloak-realm-operator)

```zsh
kubectl get secret keycloak-initial-admin -o jsonpath='{.data.username}' | base64 --decode
kubectl get secret keycloak-initial-admin -o jsonpath='{.data.password}' | base64 --decode
```