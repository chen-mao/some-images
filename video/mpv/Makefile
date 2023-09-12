DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
SUBPROJECT ?= xdxgpu
BASE    ?= ubuntu:20.04

.PHONY: all
all: ubuntu

push-latest:
	$(DOCKER) tag  mpv-video-sample:latest $(REGISTRY)/$(PROJECT)/$(SUBPROJECT)/mpv-video-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/$(SUBPROJECT)/mpv-video-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/$(SUBPROJECT)/mpv-video-sample:latest
	$(DOCKER) rmi mpv-video-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		mpv-video-sample:latest \
		--build-arg BASE_DIST=$(BASE) \
	    --file docker/Dockerfile.ubuntu .

