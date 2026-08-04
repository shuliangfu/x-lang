# Xlang Linux x86_64 local dev / gate image (build once, run many; skip apt-get each time)
# Build: ./tests/docker/build-linux-dev-image.sh
#
# Entry (G.7 · wave731 · 11.4.5):
#   Preferred:  ./xbuild <target>   (product + CI/cold outer entry)
#   Do not:     make -C compiler … from guest scripts (use ./xbuild / hub)
#
# residual host-cc/make (stage 12 zero-cc retires these packages):
#   gcc/make still required for build_tool.sh seeds, seed graph leaves, and
#   bench differential C until stage 11.5 / 12. Removing apt packages
#   before that is a false green.
#
# PLATFORM: LINUX|UBUNTU guest · SHARED entry names via ./xbuild

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV XLANG_CI_DOCKER=1
# Discoverability: outer entry is xbuild (not make)
ENV XLANG_PREFERRED_ENTRY=./xbuild

LABEL org.xlang.entry="./xbuild" \
      org.xlang.wave="731" \
      org.xlang.residual.host_cc="stage12"

RUN apt-get update -qq \
  && apt-get install -y -qq --no-install-recommends \
    gcc make perl binutils coreutils file curl xz-utils python3 \
    liburing-dev zlib1g-dev libzstd-dev libbrotli-dev libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src
