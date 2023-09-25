DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04
HELPER	?= jrottenberg/ffmpeg:4.1-vaapi

.PHONY: all
all: ubuntu

push-latest:
	$(DOCKER) tag  ffmpeg-sample:latest $(REGISTRY)/$(PROJECT)/ffmpeg-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/ffmpeg-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/ffmpeg-sample:latest
	$(DOCKER) rmi ffmpeg-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		ffmpeg-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
		--build-arg HELPER_DIST=$(HELPER) \
	    --file docker/Dockerfile.ubuntu .
