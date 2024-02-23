DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  shoc-sample:latest $(REGISTRY)/$(PROJECT)/shoc-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/shoc-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/shoc-sample:latest
	$(DOCKER) rmi shoc-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		shoc-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  shoc-sample:latest $(REGISTRY)/$(PROJECT)/shoc-sample:latest

