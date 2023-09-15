.PHONY: build
build:
	docker buildx build . -t localhost:5500/webserver:latest --push

.PHONY: clean
clean:
	-docker rmi webserver
