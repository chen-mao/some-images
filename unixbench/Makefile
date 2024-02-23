DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  unixbench-sample:latest $(REGISTRY)/$(PROJECT)/unixbench-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/unixbench-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/unixbench-sample:latest
	$(DOCKER) rmi unixbench-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		unixbench-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  unixbench-sample:latest $(REGISTRY)/$(PROJECT)/unixbench-sample:latest

