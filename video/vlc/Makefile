DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
SUBPROJECT ?= xdxgpu
BASE    ?= ubuntu:20.04

.PHONY: all
all: ubuntu

push-latest:
	$(DOCKER) tag  vlc-video-sample:latest $(REGISTRY)/$(PROJECT)/$(SUBPROJECT)/vlc-video-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/$(SUBPROJECT)/vlc-video-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/$(SUBPROJECT)/vlc-video-sample:latest
	$(DOCKER) rmi vlc-video-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		vlc-video-sample:latest \
		--build-arg BASE_DIST=$(BASE) \
	    --file docker/Dockerfile.ubuntu .

