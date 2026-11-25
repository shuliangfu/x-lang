# Xlang Linux x86_64 local dev / gate image (build once, run many; skip apt-get each time)
# Build: ./tests/docker/build-linux-dev-image.sh
#
# Entry (G.7 · wave731 · 11.4.5):
#   Preferred:  ./xbuild <target>   (product + CI/cold outer entry)
#   Do not:     make -C compiler … from guest scripts (use ./xbuild / hub)
#
# §6 10.5 · knife 11.09: default image does NOT install gcc/make.
# Optional residual host-cc/make (bench / seed archaeology):
#   XLANG_DOCKER_WITH_HOST_CC=1 ./tests/docker/build-linux-dev-image.sh
#   or: docker build --build-arg XLANG_DOCKER_WITH_HOST_CC=1 …
# Fallback guest scripts that apt-get when the image is missing remain separate
# residual (not this default image).
#
# PLATFORM: LINUX|UBUNTU guest · SHARED entry names via ./xbuild

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV XLANG_CI_DOCKER=1
# Discoverability: outer entry is xbuild (not make)
ENV XLANG_PREFERRED_ENTRY=./xbuild

LABEL org.xlang.entry="./xbuild" \
      org.xlang.wave="731" \
      org.xlang.docker.default_host_cc="0" \
      org.xlang.docker.optional_host_cc="XLANG_DOCKER_WITH_HOST_CC=1"

# Default 0 = no gcc/make (§6 10.5). Set 1 for optional residual host-cc image.
ARG XLANG_DOCKER_WITH_HOST_CC=0

RUN apt-get update -qq \
  && apt-get install -y -qq --no-install-recommends \
    perl binutils coreutils file curl xz-utils python3 \
    liburing-dev zlib1g-dev libzstd-dev libbrotli-dev libsqlite3-dev \
  && if [ "$XLANG_DOCKER_WITH_HOST_CC" = "1" ]; then \
       apt-get install -y -qq --no-install-recommends gcc make; \
     fi \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src
