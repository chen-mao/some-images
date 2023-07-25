FROM ubuntu:20.04
ENV LANG C.UTF-8

WORKDIR /

COPY sources.list /etc/apt/

#Dependencies for glvnd and X11.
RUN apt-get update \
  && apt-get install -y -qq --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
    glmark2 \
  && rm -rf /var/lib/apt/lists/*

# 设置 EntryPoint
ENTRYPOINT ["/bin/bash"]
  
