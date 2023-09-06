DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu:20.04

.PHONY: all
all: ubuntu

push-latest:
	$(DOCKER) tag  xdxsmi-sample:latest $(REGISTRY)/$(PROJECT)/xdxsmi-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/xdxsmi-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/xdxsmi-sample:latest
	$(DOCKER) rmi vulkan-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		xdxsmi-sample:latest \
		--build-arg BASE_DIST=$(BASE) \
	    --file docker/Dockerfile.ubuntu .

