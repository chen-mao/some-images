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

ubuntu: check
	$(DOCKER) build --pull -t \
		vkmark-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  vkmark-sample:latest $(REGISTRY)/$(PROJECT)/vkmark-sample:latest

buildx: check
	$(DOCKER) buildx build --platform linux/amd64,linux/arm64 -t \
		$(REGISTRY)/$(PROJECT)/vkmark-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu . --push

check:
	./check.sh