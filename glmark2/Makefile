DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  glmark-sample:latest $(REGISTRY)/$(PROJECT)/glmark-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/glmark-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/glmark-sample:latest
	$(DOCKER) rmi glmark-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		glmark-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  glmark-sample:latest $(REGISTRY)/$(PROJECT)/glmark-sample:latest

