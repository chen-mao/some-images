DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  vkmark-sample:latest $(REGISTRY)/$(PROJECT)/vkmark-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/vkmark-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/vkmark-sample:latest
	$(DOCKER) rmi vkmark-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		vkmark-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  vkmark-sample:latest $(REGISTRY)/$(PROJECT)/vkmark-sample:latest

