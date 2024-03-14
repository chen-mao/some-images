DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  babelstream-sample:latest $(REGISTRY)/$(PROJECT)/babelstream-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/babelstream-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/babelstream-sample:latest
	$(DOCKER) rmi babelstream-sample:latest

ubuntu: check
	$(DOCKER) build --pull -t \
		babelstream-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  babelstream-sample:latest $(REGISTRY)/$(PROJECT)/babelstream-sample:latest

buildx: check
	$(DOCKER) buildx build --platform linux/arm64,linux/amd64 -t \
		$(REGISTRY)/$(PROJECT)/babelstream-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu . --push

check:
	./check.sh
