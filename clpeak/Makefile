DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/clpeak-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/clpeak-sample:latest
	$(DOCKER) rmi clpeak-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		clpeak-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  clpeak-sample:latest $(REGISTRY)/$(PROJECT)/clpeak-sample:latest

