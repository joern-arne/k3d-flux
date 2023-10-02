.PHONY: enable-ingress
enable-ingress:
	@( \
		export KUBECONFIG=/Users/u299496/git/github.com/joern-arne/nexus-services/k3s/kubeconfig && \
		kubectl apply -k . \
	)

.PHONY: disable-ingress
disable-ingress:
	-@( \
		export KUBECONFIG=/Users/u299496/git/github.com/joern-arne/nexus-services/k3s/kubeconfig && \
		kubectl delete -k . \
	)