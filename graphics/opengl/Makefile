DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu:20.04

.PHONY: all
all: ubuntu

push-latest:
	$(DOCKER) tag  opengl-sample:latest $(REGISTRY)/$(PROJECT)/opengl-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/opengl-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/opengl-sample:latest
	$(DOCKER) rmi opengl-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		opengl-sample:latest \
		--build-arg BASE_DIST=$(BASE) \
	    --file docker/Dockerfile.ubuntu .

