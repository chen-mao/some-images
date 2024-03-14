DOCKER   ?= docker
REGISTRY ?= hub.xdxct.com
PROJECT  ?= xdxct-docker
BASE    ?= ubuntu20.04

.PHONY: all
all: ubuntu

push-latest:
	# $(DOCKER) tag  geekbench5-sample:latest $(REGISTRY)/$(PROJECT)/geekbench5-sample:latest
	$(DOCKER) push $(REGISTRY)/$(PROJECT)/geekbench5-sample:latest

clean:
	$(DOCKER) rmi $(REGISTRY)/$(PROJECT)/geekbench5-sample:latest
	$(DOCKER) rmi geekbench5-sample:latest

ubuntu: check
	$(DOCKER) build --pull -t \
		geekbench5-sample:latest \
		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
	    --file Dockerfile.ubuntu .
	$(DOCKER) tag  geekbench5-sample:latest $(REGISTRY)/$(PROJECT)/geekbench5-sample:latest

# buildx: check
# 	$(DOCKER) buildx build --platform linux/amd64,linux/arm64 -t \
# 		$(REGISTRY)/$(PROJECT)/geekbench5-sample:latest \
# 		--build-arg BASE_DIST=$(REGISTRY)/$(PROJECT)/ubuntu:base-$(BASE) \
# 	    --file Dockerfile.ubuntu . --push

check:
	./check.sh

