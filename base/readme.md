# Linux Container Image Sources

Usage of the container images requires the Xdxct Container Runtime.

## Building from source

Here is an example on how to build an multi-arch container image for Ubuntu 20.04:

```bash
./build.sh --image-name hub.xdxct.com/xdxct-docker/ubuntu --arch x86_64 --os ubuntu --os-version 20.04  --load
```

See `./build.sh --help` for usage.
