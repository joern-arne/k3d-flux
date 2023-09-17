[ngrok for k8s](https://ngrok.com/blog-post/ngrok-k8s)

```bash
export NGROK_API_KEY=usr_2VXbeBymO3X0bYQz2r97Yzlon9r
export NGROK_AUTHTOKEN=2VXbe6quxsjbxYtkvuYgf0STLLG_6C9NPDwFJt2ZER5j41CFx

helm install ngrok-ingress-controller ngrok/kubernetes-ingress-controller \
  --set credentials.apiKey=$NGROK_API_KEY \
  --set credentials.authtoken=$NGROK_AUTHTOKEN

export NGROK_SUBDOMAIN="testsub-2349218723457623"

wget https://raw.githubusercontent.com/ngrok/kubernetes-ingress-controller/main/docs/examples/hello-world/manifests.yaml -O - | envsubst | kubectl apply -f -
```
