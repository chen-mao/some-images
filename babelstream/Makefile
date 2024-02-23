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

ubuntu:
	$(DOCKER) build --pull -t \
		babelstream-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  babelstream-sample:latest $(REGISTRY)/$(PROJECT)/babelstream-sample:latest

