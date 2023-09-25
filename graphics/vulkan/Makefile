DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	$(DOCKER) tag  vulkan-sample:latest $(REGISTRY)/$(PROJECT)/vulkan-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/vulkan-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/vulkan-sample:latest
	$(DOCKER) rmi vulkan-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		vulkan-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file docker/Dockerfile.ubuntu .

