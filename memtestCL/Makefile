DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  memtestcl-sample:latest $(REGISTRY)/$(PROJECT)/memtestcl-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/memtestcl-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/memtestcl-sample:latest
	$(DOCKER) rmi memtestcl-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		memtestcl-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  memtestcl-sample:latest $(REGISTRY)/$(PROJECT)/memtestcl-sample:latest

