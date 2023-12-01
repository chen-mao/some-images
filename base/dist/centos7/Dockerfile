FROM centos:7 as base

FROM base as base-amd64

ENV XDXCTARCH x86_64

FROM base as base-arm64
ENV XDXCTARCH sbsa

FROM base-${TARGETARCH}

ARG TARGETARCH

LABEL maintainer "XDXCT CORPORATION"

COPY Centos-7.repo /etc/yum.repos.d/

ENV LD_LIBRARY_PATH=/lib64/xdxgpu:${LD_LIBRARY_PATH}

# xdxct-container-runtime
ENV XDXCT_VISIBLE_DEVICES all
ENV XDXCT_DRIVER_CAPABILITIES compute,utility