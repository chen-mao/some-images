DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  luxmark-sample:latest $(REGISTRY)/$(PROJECT)/luxmark-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/luxmark-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/luxmark-sample:latest
	$(DOCKER) rmi luxmark-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		luxmark-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  luxmark-sample:latest $(REGISTRY)/$(PROJECT)/luxmark-sample:latest

