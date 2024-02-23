DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  gfxbench-sample:latest $(REGISTRY)/$(PROJECT)/gfxbench-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/gfxbench-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/gfxbench-sample:latest
	$(DOCKER) rmi gfxbench-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		gfxbench-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  gfxbench-sample:latest $(REGISTRY)/$(PROJECT)/gfxbench-sample:latest

