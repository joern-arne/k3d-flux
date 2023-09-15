.PHONY: build
build:
	docker buildx build . -t webserver --load

.PHONY: clean
clean:
	-docker rmi webserver
