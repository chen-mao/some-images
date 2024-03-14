DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  unigine-sample:latest $(REGISTRY)/$(PROJECT)/unigine-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/unigine-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/unigine-sample:latest
	$(DOCKER) rmi unigine-sample:latest

ubuntu: check
	$(DOCKER) build --pull -t \
		unigine-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  unigine-sample:latest $(REGISTRY)/$(PROJECT)/unigine-sample:latest

check:
	./check.sh