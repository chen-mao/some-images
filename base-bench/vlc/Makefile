DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	$(DOCKER) tag  vlc-video-sample:latest $(REGISTRY)/$(PROJECT)/vlc-video-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/vlc-video-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/vlc-video-sample:latest
	$(DOCKER) rmi vlc-video-sample:latest

ubuntu:
	$(DOCKER) build --pull -t \
		vlc-video-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .

buildx:
	$(DOCKER) buildx build --platform linux/arm64,linux/amd64 -t \
		$(REGISTRY)/$(PROJECT)/vlc-video-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu --push .

