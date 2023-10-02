ifndef CLUSTER
$(error CLUSTER is not set)
endif

#macOS
LOCAL_IP := $(shell ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep '10.10.10' | tail -1)

ifndef LOCAL_IP
$(error LOCAL_IP is not set)
endif

.PHONY: enable-ingress
enable-ingress: update-ingress-ip
	@kubectl --kubeconfig $(HOME)/git/github.com/joern-arne/nexus-services/k3s/kubeconfig apply -k $(CLUSTER)

.PHONY: disable-ingress
disable-ingress:
	-@kubectl --kubeconfig $(HOME)/git/github.com/joern-arne/nexus-services/k3s/kubeconfig delete -k $(CLUSTER)

.PHONY: disable-all-ingress
disable-all-ingress:
	-@kubectl --kubeconfig $(HOME)/git/github.com/joern-arne/nexus-services/k3s/kubeconfig delete -k .

.PHONY: enable-all-ingress
enable-all-ingress: update-ingress-ip
	-@kubectl --kubeconfig $(HOME)/git/github.com/joern-arne/nexus-services/k3s/kubeconfig apply -k .

.PHONY: update-ingress-ip
update-ingress-ip:
	@echo "Update to local ip: $(LOCAL_IP)"
	@sed -i '' -E 's/(.*value: ")[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(".*)/\1$(LOCAL_IP)\2/' k3d-*/kustomization.yaml
