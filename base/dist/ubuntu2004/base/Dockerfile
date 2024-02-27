FROM ubuntu:20.04 as base

FROM base as base-amd64

ENV XDXCTARCH x86_64

FROM base as base-arm64
ENV XDXCTARCH sbsa

FROM base-${TARGETARCH}

ARG TARGETARCH

LABEL maintainer "XDXCT CORPORATION"

COPY sources.list /etc/apt/

ENV LD_LIBRARY_PATH /opt/xdxgpu/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu:/usr/lib64/xdxgpu:/usr/lib/aarch64-linux-gnu/xdxgpu:${LD_LIBRARY_PATH}

# xdxct-container-runtime
ENV XDXCT_VISIBLE_DEVICES all
ENV XDXCT_DRIVER_CAPABILITIES compute,utility

RUN apt-get update \
	&& apt-get install -y --no-install-recommends libpciaccess-dev \
 	&& rm -rf /var/lib/apt/lists/*
