DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	$(DOCKER) tag  mpv-video-sample:latest $(REGISTRY)/$(PROJECT)/mpv-video-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/mpv-video-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/mpv-video-sample:latest
	$(DOCKER) rmi mpv-video-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		mpv-video-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file docker/Dockerfile.ubuntu .

