#!/usr/bin/env bash
# shu-link-env.sh — 链接阶段常见库搜索路径（Homebrew /usr/local）
#
# 用法：source tests/lib/shu-link-env.sh
# 影响：LIBRARY_PATH、DYLD_LIBRARY_PATH（macOS）、LD_LIBRARY_PATH（Linux）

# Homebrew（Apple Silicon / Intel）
if [ -d /opt/homebrew/lib ]; then
  export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
  if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    export DYLD_LIBRARY_PATH="/opt/homebrew/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
  fi
fi
if [ -d /usr/local/lib ]; then
  export LIBRARY_PATH="/usr/local/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
  if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    export DYLD_LIBRARY_PATH="/usr/local/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
  fi
fi

# Linux：常见 multiarch 路径（apt libzstd-dev / zlib1g-dev）
for d in /usr/lib/x86_64-linux-gnu /usr/lib/aarch64-linux-gnu /usr/lib; do
  if [ -d "$d" ]; then
    export LIBRARY_PATH="$d${LIBRARY_PATH:+:$LIBRARY_PATH}"
    export LD_LIBRARY_PATH="$d${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  fi
done
