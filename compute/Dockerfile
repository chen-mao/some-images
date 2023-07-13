FROM ubuntu:20.04
ENV LANG C.UTF-8

WORKDIR /

COPY sources.list /etc/apt/

#Dependencies for glvnd and X11.
RUN apt-get update \
  && apt-get install -y -qq --no-install-recommends \
    vim \
    make \
    gdb \
    build-essential \
    opencl-headers \
    clinfo \
  && rm -rf /var/lib/apt/lists/*
  
