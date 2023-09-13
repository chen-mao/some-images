DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu:20.04
# /*- NOTICE -*/
# When you run the make command for the first time, 
# invoke the download.sh script to download the project zip file
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
		--build-arg BASE_DIST=$(BASE) \
	    --file docker/Dockerfile.ubuntu .

