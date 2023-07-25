FROM ubuntu:20.04
ENV LANG C.UTF-8

WORKDIR /

COPY sources.list /etc/apt/

#Dependencies for glvnd and X11.
RUN apt-get update \
  && apt-get install -y -qq --no-install-recommends \
    python3 \
  && rm -rf /var/lib/apt/lists/*
  
