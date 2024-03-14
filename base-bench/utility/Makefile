DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker

BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	$(DOCKER) tag  xdxsmi-sample:latest $(REGISTRY)/$(PROJECT)/xdxsmi-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/xdxsmi-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/xdxsmi-sample:latest
	$(DOCKER) rmi xdxsmi-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		xdxsmi-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file docker/Dockerfile.ubuntu .

buildx:
	$(DOCKER) buildx build --platform linux/arm64,linux/amd64 -t \
		$(REGISTRY)/$(PROJECT)/xdxsmi-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu --push .