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

# w1484: refuse to link when ensure / relink_env logged a g05 pure-asm crash
# (a retry or cc fallback may have hidden it). PLATFORM: SHARED.
if [ -s build_asm/g05_xasm_crash.log ]; then
  echo "g05_relink_xlang: g05 pure-asm compiler crashed (build_asm/g05_xasm_crash.log):" >&2
  sed 's/^/  /' build_asm/g05_xasm_crash.log >&2
  if [ "${XLANG_G05_XASM_ALLOW_CRASH:-0}" != "1" ]; then
    echo "  fix the product and rm the log, or XLANG_G05_XASM_ALLOW_CRASH=1 to only warn" >&2
    exit 1
  fi
fi

CC="${G05_CC:-cc}"
CFLAGS="${G05_CFLAGS:-}"

# Stage 12.2.1: XLANG_FORBID_HOST_CC gate (no-op when flag unset; zero impact
# on normal builds). When XLANG_FORBID_HOST_CC=1, replaces $CC with a wrapper
# that logs and blocks all host-CC invocations — builds the zero-CC problem map.
# PLATFORM: SHARED.
. "$(dirname "$0")/forbid_host_cc.sh"

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

# w1010: PE mega same-TU leftover body_sync / emit_let_init → jmp to host-gcc twin.
# PLATFORM: WINDOWS only (script no-ops on Mach-O/ELF).
# MinGW -o xlang often materializes as xlang.exe; resolve before cp/patch.
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    if [ -f "${OUT}.exe" ]; then
      OUT="${OUT}.exe"
    fi
    if [ -f scripts/win_patch_body_sync_jmp.py ] && [ -f "$OUT" ]; then
      python3 scripts/win_patch_body_sync_jmp.py "$OUT" || true
    fi
    ;;
esac

# w1499: copy onto a fresh inode. macOS keeps the code signature of an
# executable it already ran cached per vnode, so cp over the old file can make
# the next exec die with SIGKILL ("load code signature error 2").
# PLATFORM: MACOS needs it; SHARED harmless.
_g05_cp_fresh() {
  [ "$1" = "$2" ] && return 0
  rm -f "$2"
  cp -f "$1" "$2"
}
_g05_cp_fresh "$OUT" "$XLANG_C"
_g05_cp_fresh "$OUT" "$BOOTSTRAP"
echo "g05_relink_xlang OK ($OUT → $XLANG_C + $BOOTSTRAP)"

# Always sync product asm name after g05. On Windows MinGW, L2 defaults to
# ./compiler/xlang_asm (no .exe) while -o xlang materializes as xlang.exe —
# a stale bare xlang_asm silently fails hello/si while xlang_asm.exe is green.
# PLATFORM: WINDOWS sync both names; SHARED sync bare xlang_asm.
_g05_cp_fresh "$OUT" xlang_asm
echo "g05_relink_xlang: synced xlang_asm"
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    _g05_cp_fresh "$OUT" xlang_asm.exe
    echo "g05_relink_xlang: synced xlang_asm.exe"
    ;;
esac

# w1545: refresh cached formal std/core leaves after the product changes.
# Leaves are built once and only rebuilt when missing or older than their .x
# sources, so a calling-convention change in the product (w1545: Windows 9-16
# byte structs via hidden pointer) leaves callee bodies on the old ABI. On
# Windows the product's own ensure hook cannot run the bash command line, so
# the relink step rebuilds every leaf that already exists with the new
# product (Windows leaves go through the asm backend, no host cc). Keep the
# old leaf when the rebuild fails.
# PLATFORM: WINDOWS only (Mach-O/ELF leaves are C-backend objects whose ABI
# follows the host C compiler, unaffected by product call-lowering changes).
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    case "$OUT" in /*|?:*) _refresh_x="$OUT" ;; *) _refresh_x="./$OUT" ;; esac
    for _leaf in ../core/*/*.o ../std/*/*.o ../std/*/*/*.o; do
      [ -s "$_leaf" ] || continue
      cp -f "$_leaf" "$_leaf.w1545bak"
      if FORCE=1 XLANG="$_refresh_x" bash scripts/xlang_compile_std_module.sh ensure "$_leaf" >/dev/null 2>&1 \
          && [ -s "$_leaf" ]; then
        rm -f "$_leaf.w1545bak"
        echo "g05_relink_xlang: refreshed $_leaf"
      else
        mv -f "$_leaf.w1545bak" "$_leaf"
        echo "g05_relink_xlang: WARN refresh failed, kept $_leaf" >&2
      fi
    done
    ;;
esac

# w2055: Linux leaves were only ever built when missing. A source change in a
# leaf module (80fd8b8ee: core/option out-pointer returns) left the old object
# in place and user programs linked the stale ABI (L2 opt exit 134). Rebuild
# only leaves the std module script reports stale (ensure without FORCE), with
# the product's asm backend so no host C compiler runs. Keep the old leaf when
# the rebuild fails.
# PLATFORM: LINUX only (Darwin leaves are refreshed by their own gate).
case "$(uname -s 2>/dev/null)" in
  Linux)
    case "$OUT" in /*) _refresh_x="$OUT" ;; *) _refresh_x="./$OUT" ;; esac
    _kept_stale=""
    for _leaf in ../core/*/*.o ../std/*/*.o ../std/*/*/*.o; do
      [ -s "$_leaf" ] || continue
      _before=$(stat -c %Y "$_leaf" 2>/dev/null || echo 0)
      cp -fp "$_leaf" "$_leaf.w2055bak"
      _erc=0
      XLANG_FORCE_LINK_BACKEND=asm XLANG="$_refresh_x" bash scripts/xlang_compile_std_module.sh ensure "$_leaf" >/dev/null 2>&1 || _erc=$?
      if [ "$_erc" = 3 ]; then
        # Not a catalog leaf (exit 3): the product never ensures it; leave it.
        mv -f "$_leaf.w2055bak" "$_leaf"
        continue
      fi
      if [ "$_erc" = 0 ] && [ -s "$_leaf" ]; then
        rm -f "$_leaf.w2055bak"
        _after=$(stat -c %Y "$_leaf" 2>/dev/null || echo 0)
        if [ "$_after" != "$_before" ]; then
          echo "g05_relink_xlang: refreshed stale $_leaf"
        fi
      else
        mv -f "$_leaf.w2055bak" "$_leaf"
        _kept_stale="$_kept_stale $_leaf"
        echo "g05_relink_xlang: !!!!! STALE LEAF KEPT: $_leaf (asm rebuild failed; programs linking it get the OLD object) !!!!!" >&2
      fi
    done
    if [ -n "$_kept_stale" ]; then
      echo "g05_relink_xlang: !!!!! STALE LEAVES KEPT ($(echo $_kept_stale | wc -w)):$_kept_stale !!!!!" >&2
    fi
    ;;
esac
