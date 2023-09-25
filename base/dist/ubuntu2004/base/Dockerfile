FROM ubuntu:20.04 as base

FROM base as base-amd64

ENV XDXCTARCH x86_64

FROM base as base-arm64
ENV XDXCTARCH sbsa

FROM base-${TARGETARCH}

ARG TARGETARCH

LABEL maintainer "XDXCT CORPORATION"

COPY sources.list /etc/apt/

ENV LD_LIBRARY_PATH=/opt/xdxgpu/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}

# xdxct-container-runtime
ENV XDXCT_VISIBLE_DEVICES all
ENV XDXCT_DRIVER_CAPABILITIES compute,utility