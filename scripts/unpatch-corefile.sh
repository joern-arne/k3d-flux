#!/bin/bash
kubectl get -n kube-system configmap coredns -o yaml | yq -r '.data.Corefile' > Corefile

if grep -q whoami.127.0.0.1.nip.io Corefile; then
    cat Corefile | sed '/whoami.127.0.0.1.nip.io {/,/whoami}/d' > Corefile.clean
    mv Corefile.clean Corefile
    kubectl delete -n kube-system configmap coredns
    kubectl create -n kube-system configmap coredns --from-file=Corefile
else
    echo "Corefile needs no cleanup"
fi
