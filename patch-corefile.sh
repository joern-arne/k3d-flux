#!/bin/bash
ip=$(kubectl get -n kube-system service traefik --no-headers | awk '{print$3}')
kubectl get -n kube-system configmap coredns -o yaml | yq -r '.data.Corefile' > Corefile

if grep -q whoami.127.0.0.1.nip.io Corefile; then
    echo "Corefile has already been patched."
    exit 0
fi

cat <<EOF >> Corefile
whoami.127.0.0.1.nip.io {
	hosts {
		$ip whoami.127.0.0.1.nip.io
		fallthrough
	}
	whoami
}
EOF
kubectl delete -n kube-system configmap coredns
kubectl create -n kube-system configmap coredns --from-file=Corefile
