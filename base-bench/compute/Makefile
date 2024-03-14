DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker

BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	$(DOCKER) tag  clinfo-sample:latest $(REGISTRY)/$(PROJECT)/clinfo-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/clinfo-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/clinfo-sample:latest
	$(DOCKER) rmi clinfo-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		clinfo-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .

buildx:
	$(DOCKER) buildx build --platform linux/arm64,linux/amd64 -t \
		$(REGISTRY)/$(PROJECT)/clinfo-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu --push .