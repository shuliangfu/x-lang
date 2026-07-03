#!/usr/bin/env bash
# shux-min-link.sh — bootstrap-min 编译器包装：-o 直链失败时走 min_asm_gcc_link（Docker gcc 镜像回退）
#
# 用法：export SHUX_MIN_LINK_REAL=./compiler/shux_asm && ./tests/lib/shux-min-link.sh -L . foo.sx -o /tmp/exe
# 非 -o 调用透明转发至 SHUX_MIN_LINK_REAL。

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
# shellcheck source=tests/lib/min-asm-gcc-link.sh
. "$ROOT/tests/lib/min-asm-gcc-link.sh"

REAL="${SHUX_MIN_LINK_REAL:-./compiler/shux_asm}"
case "$REAL" in
  /*) ;;
  *) REAL="$ROOT/$REAL" ;;
esac

if [ ! -x "$REAL" ]; then
  echo "shux-min-link: SHUX_MIN_LINK_REAL not executable: $REAL" >&2
  exit 127
fi

# Docker 官方 gcc 镜像仅提供 /usr/local/bin/gcc。
if [ -z "${SHUX_MIN_GCC:-}" ]; then
  if [ -x /usr/local/bin/gcc ]; then
    export SHUX_MIN_GCC=/usr/local/bin/gcc
  elif [ -x /usr/bin/gcc ]; then
    export SHUX_MIN_GCC=/usr/bin/gcc
  fi
fi

# 解析 -o 与入口 .sx（多文件时取首个 .sx，与 driver 主模块一致）。
has_o=0
exe=""
sx=""
args=("$@")
for ((i = 0; i < ${#args[@]}; i++)); do
  arg="${args[$i]}"
  if [ "$arg" = "-o" ] && [ $((i + 1)) -lt ${#args[@]} ]; then
    has_o=1
    exe="${args[$((i + 1))]}"
  fi
  if [[ "$arg" == *.sx ]] && [ -z "$sx" ]; then
    sx="$arg"
  fi
done

if [ "$has_o" -eq 1 ] && [ -n "$sx" ] && [ -n "$exe" ]; then
  min_link_exe_args "$REAL" "$@"
  exit $?
fi

exec "$REAL" "$@"
