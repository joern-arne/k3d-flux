[ngrok for k8s](https://ngrok.com/blog-post/ngrok-k8s)

[keycloak and ngrok](https://gist.github.com/rafi/ec8c584e3a3a3c898903a714c2d62976)

```bash
export NGROK_API_KEY=usr_2VXbeBymO3X0bYQz2r97Yzlon9r
export NGROK_AUTHTOKEN=2VXbe6quxsjbxYtkvuYgf0STLLG_6C9NPDwFJt2ZER5j41CFx
export NAMESPACE=ngrok-ingress-controller

# kubectl apply -f
cat - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ngrok-ingress-controller-credentials
  namespace: $NAMESPACE
data:
  API_KEY: $(echo $NGROK_API_KEY | base64)
  AUTHTOKEN: $(echo $NGROK_AUTHTOKEN | base64)
EOF

# kubectl create secret generic ngrok-ingress-controller-credentials \
#   --from-literal=api-key=$NGROK_API_KEY \
#   --from-literal=auth-token=$NGROK_AUTHTOKEN


helm install ngrok-ingress-controller ngrok/kubernetes-ingress-controller \
  --namespace $NAMESPACE \
  --create-namespace \
  -f values.yaml \
  --dry-run --debug


# kubectl apply -n $NAMESPACE \
#   -f https://raw.githubusercontent.com/ngrok/kubernetes-ingress-controller/main/manifest-bundle.yaml
```

