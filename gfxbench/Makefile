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

ubuntu: check
	$(DOCKER) build --pull -t \
		gfxbench-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  gfxbench-sample:latest $(REGISTRY)/$(PROJECT)/gfxbench-sample:latest

buildx: check
	$(DOCKER) buildx build --platform linux/amd64,linux/arm64 -t \
		$(REGISTRY)/$(PROJECT)/gfxbench-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu . --push

check:
	./check.sh
