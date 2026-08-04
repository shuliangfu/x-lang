#!/usr/bin/env bash
# g05_relink_xlang.sh — G-05：最终链接 xlang 的唯一 shell 实现
#
# 由 g05_prepare_and_relink.sh 在依赖齐备后调用（G05_* 来自 g05_relink_env.sh）。
# 目的：最终链接 + 同步 xlang-c/bootstrap_xlangc 仅在本脚本（G-05 100% 产品路径）。
#
# wave773 · 11.1.4 pure-ld (G.7 有则补全 pure_ld_shared.sh):
#   When freestanding-eligible (Darwin / Linux x86_64 crt0), pure-ld first.
# wave774 · 11.1.4 endgame slice: NO silent CC fallback after pure-ld fail.
#   · freestanding-eligible + not FORCE_CC → pure-ld required (hard fail on miss)
#   · FORCE_CC=1 or host ineligible → named $CC $CFLAGS -o residual only
#   Object list authority remains g05_relink_env (no second .o inventory).
#
# 环境变量（g05_relink_env.sh 注入）：
#   G05_CC          编译器（默认 cc）— residual path
#   G05_CFLAGS      完整 cflags + link flags（含 -e _start 等）— residual path
#   G05_OUT         输出二进制名（默认 xlang）
#   G05_OBJS        全部 .o 参数（空格分隔）
#   G05_XLANG_C      xlang-c 同步名（默认 xlang-c）
#   G05_BOOTSTRAP   bootstrap_xlangc 同步名（默认 bootstrap_xlangc）
#   G05_SYNC_ASM=1  同时 cp 到 xlang_asm（可选；prepare 亦可在外层做）
#
# Env overrides:
#   XLANG_G05_FORCE_CC=1 / XLANG_SEED_LINK_FORCE_CC=1 — skip pure-ld; CC residual only
#
# 用法（compiler/ 目录）：
#   eval "$(sh scripts/g05_relink_env.sh)" && sh scripts/g05_relink_xlang.sh
#
# PLATFORM: SHARED — pure-ld required when freestanding; Windows stays CC residual.
# PLATFORM: LINUX — nostdlib product drops -lc (static freestanding); libc cold uses -lc.
# PLATFORM: MACOS — pure_ld_shared syslibroot + -lSystem.
# Wave: 773 pure-ld prefer · 774 drop silent CC fallback.

set -e
cd "$(dirname "$0")/.."

CC="${G05_CC:-cc}"
CFLAGS="${G05_CFLAGS:-}"
OUT="${G05_OUT:-xlang}"
OBJS="${G05_OBJS:-}"
XLANG_C="${G05_XLANG_C:-xlang-c}"
BOOTSTRAP="${G05_BOOTSTRAP:-bootstrap_xlangc}"

if [ -z "$OBJS" ]; then
  echo "g05_relink_xlang: G05_OBJS empty (eval g05_relink_env.sh first)" >&2
  exit 1
fi

# G.7: pure-ld helpers — single authority (shared with cold seed link).
# shellcheck disable=SC1091
. scripts/pure_ld_shared.sh
# nostdlib policy for Linux product (same as g05_relink_env).
# shellcheck disable=SC1091
. scripts/bootstrap_nostdlib_shared.sh

n_objs=$(printf '%s\n' "$OBJS" | wc -w | tr -d ' ')

g05_force_cc() {
  [ "${XLANG_G05_FORCE_CC:-0}" = "1" ] || [ "${XLANG_SEED_LINK_FORCE_CC:-0}" = "1" ]
}

# Named CC residual only (FORCE_CC escape or pure-ld ineligible host).
# wave774: not used as silent fallback after pure-ld failure.
run_g05_cc_residual() {
  # shellcheck disable=SC2086
  echo "g05_relink_xlang: $CC ... -o $OUT  ($n_objs objs; CC residual)"
  # shellcheck disable=SC2086
  $CC $CFLAGS -o "$OUT" $OBJS
  echo "g05_relink_xlang: OK CC residual $OUT" >&2
}

# pure-ld required when freestanding-eligible and not forced to CC residual.
run_g05_pure_ld_required() {
  entry=""
  tail=""
  extra=""

  # Product freestanding entry (matches MAIN_LINK_FLAGS / cold SEED_LINK_ENTRY).
  entry="$(pure_ld_default_entry)"
  if bootstrap_wants_nostdlib; then
    # PLATFORM: LINUX — map cc -nostdlib -static -Wl,--gc-sections → pure ld flags.
    # No -lc; freestanding_io + nostdlib stubs already in G05_OBJS.
    extra="-static --gc-sections"
    tail=""
  else
    # Darwin / Linux-with-libc freestanding (nostartfiles-style).
    tail="$(pure_ld_default_libc_tail)"
  fi
  echo "g05_relink_xlang: pure-ld → $OUT  ($n_objs objs)" >&2
  if pure_ld_try_link "$OUT" "$OBJS" "$entry" "$tail" "$extra" ""; then
    echo "g05_relink_xlang: OK pure-ld $OUT" >&2
    return 0
  fi
  echo "g05_relink_xlang: FAIL pure-ld for $OUT (no silent CC fallback; set XLANG_G05_FORCE_CC=1 for escape)" >&2
  exit 1
}

# Decision tree (wave774):
#   FORCE_CC=1              → named CC residual only
#   !freestanding_ok        → named CC residual only (ineligible host)
#   else                    → pure-ld required (hard fail on miss)
if g05_force_cc; then
  echo "g05_relink_xlang: pure-ld skipped (FORCE_CC) → CC residual only" >&2
  run_g05_cc_residual
elif ! pure_ld_freestanding_ok; then
  echo "g05_relink_xlang: pure-ld ineligible (host not freestanding) → CC residual only" >&2
  run_g05_cc_residual
else
  run_g05_pure_ld_required
fi

cp -f "$OUT" "$XLANG_C"
cp -f "$OUT" "$BOOTSTRAP"
echo "g05_relink_xlang OK ($OUT → $XLANG_C + $BOOTSTRAP)"

if [ "${G05_SYNC_ASM:-}" = "1" ]; then
  cp -f "$OUT" xlang_asm
  echo "g05_relink_xlang: synced xlang_asm"
fi
