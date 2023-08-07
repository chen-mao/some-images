FROM ubuntu:20.04
ENV LANG C.UTF-8

WORKDIR /tmp/content

COPY sources.list /etc/apt/

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends mpv \
 && rm -rf /var/lib/apt/lists/*  

# 设置 EntryPoint
ENTRYPOINT ["/bin/bash"]
