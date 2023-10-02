# keycloak
[documentation](https://www.keycloak.org/guides#operator)

```zsh
kubectl get secret keycloak-initial-admin -o jsonpath='{.data.username}' | base64 --decode
kubectl get secret keycloak-initial-admin -o jsonpath='{.data.password}' | base64 --decode
```