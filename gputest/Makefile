DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  gputest-sample:latest $(REGISTRY)/$(PROJECT)/gputest-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/gputest-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/gputest-sample:latest
	$(DOCKER) rmi gputest-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		gputest-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  gputest-sample:latest $(REGISTRY)/$(PROJECT)/gputest-sample:latest

