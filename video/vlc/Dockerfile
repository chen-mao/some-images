FROM ubuntu:20.04

ENV LANG C.UTF-8
ENV XDXCT_VISIBLE_DEVICES=all
ENV XDXCT_DRIVER_CAPABILITIES=graphics,compute,video

WORKDIR /tmp/content

COPY sources.list /etc/apt/

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends vlc \
 && rm -rf /var/lib/apt/lists/*  

RUN sed -i 's/geteuid/getppid/' /usr/bin/vlc

# 设置 EntryPoint
ENTRYPOINT ["/bin/bash"]
