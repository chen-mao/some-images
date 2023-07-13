FROM ubuntu:20.04
ENV LANG C.UTF-8

WORKDIR /tmp/content

COPY sources.list /etc/apt/

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends vlc \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
    glmark2 \
    vim \
    make \
    gdb \
    build-essential \
    opencl-headers \
    clinfo \
    openssh-server \
 && rm -rf /var/lib/apt/lists/*  

RUN sed -i 's/geteuid/getppid/' /usr/bin/vlc
