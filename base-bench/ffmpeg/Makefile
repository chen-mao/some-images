DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04
HELPER	?= jrottenberg/ffmpeg:4.1-vaapi
# HELPER ?= linuxserver/ffmpeg:4.4-cli-ls62

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
	    --file Dockerfile.ubuntu .

buildx:
	$(DOCKER) buildx build --platform linux/arm64,linux/amd64 -t \
		$(REGISTRY)/$(PROJECT)/ffmpeg-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
		--build-arg HELPER_DIST=$(HELPER) \
	    --file Dockerfile.ubuntu --push .
