DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  glxgears-sample:latest $(REGISTRY)/$(PROJECT)/glxgears-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/glxgears-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/glxgears-sample:latest
	$(DOCKER) rmi glxgears-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		glxgears-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  glxgears-sample:latest $(REGISTRY)/$(PROJECT)/glxgears-sample:latest

