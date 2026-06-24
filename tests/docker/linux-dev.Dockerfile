# Shux Linux x86_64 本地开发/门禁镜像（一次 build，多次 run，免 apt-get）
# 构建：./tests/docker/build-linux-dev-image.sh
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SHUX_CI_DOCKER=1

RUN apt-get update -qq \
  && apt-get install -y -qq --no-install-recommends \
    gcc make perl binutils coreutils file curl xz-utils python3 \
    liburing-dev zlib1g-dev libzstd-dev libbrotli-dev libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src
