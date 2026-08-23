#!/bin/bash
# g05_prepare_and_relink.sh — G-05 100%：产品路径编排（依赖准备 + 最终链接）
#
# 产品日常 xlang/xlang_asm 的**编排图**全部在 shell：
#   g05_ensure_relink_prereqs.sh → g05_relink_env.sh → g05_relink_xlang.sh
# Makefile **不**参与产品路径（仅冷启动 / 单文件 .o 规则兜底）。
#
# 用法（compiler/ 目录）：
#   bash scripts/g05_prepare_and_relink.sh              # default: sync xlang → xlang_asm
#   bash scripts/g05_prepare_and_relink.sh --no-sync     # xlang only (relink-xlang)
#   bash scripts/g05_prepare_and_relink.sh --sync        # force sync (explicit)
#   G05_SYNC_ASM=0 bash scripts/g05_prepare_and_relink.sh  # env still honored when no CLI flag
#
# wave885 B7B residual G05_SYNC inject hygiene (G.7 有则补全):
#   Makefile no longer injects G05_SYNC_ASM=0/1 on recipes. CLI --no-sync is the
#   intentional override for relink-xlang; bare call defaults to sync (=1).
#   Env G05_SYNC_ASM remains for xbuild / refresh / probes (not recipe inject).
# PLATFORM: SHARED — product link path identical on mac / Ubuntu / Windows host.
# NOT physical delete — thin edges + B2 + mk lists + LD / pipeline bags remain.

set -e
cd "$(dirname "$0")/.."

# Default: sync xlang_asm (historic G05_SYNC_ASM:-1).
SYNC_ASM="${G05_SYNC_ASM:-1}"
_cli_sync_set=0
for arg in "$@"; do
  case "$arg" in
    --no-sync|nosync|0)
      SYNC_ASM=0
      _cli_sync_set=1
      ;;
    --sync|sync|1)
      SYNC_ASM=1
      _cli_sync_set=1
      ;;
    -h|--help)
      cat <<'EOF'
Usage: g05_prepare_and_relink.sh [--no-sync|--sync]
  --no-sync  build/relink xlang only (do not cp to xlang_asm)
  --sync     also sync xlang → xlang_asm (default when unset)
  G05_SYNC_ASM=0|1 still honored when no CLI flag is given
EOF
      exit 0
      ;;
    *)
      echo "g05_prepare_and_relink: unknown arg: $arg (try --help)" >&2
      exit 2
      ;;
  esac
done
# CLI flag is authoritative when present; else env/default already applied.
if [ "$_cli_sync_set" = "1" ]; then
  :
fi

echo "g05_prepare_and_relink: ensure prereqs (shell, no make)"
bash scripts/g05_ensure_relink_prereqs.sh

echo "g05_prepare_and_relink: export link env (shell) + final link"
# shellcheck disable=SC2046
eval "$(bash scripts/g05_relink_env.sh)"
export G05_CC G05_CFLAGS G05_OUT G05_XLANG_C G05_BOOTSTRAP G05_OBJS
# g05_relink_xlang also reads G05_SYNC_ASM; prepare owns outer cp when SYNC_ASM=1.
# Keep inner sync off so we do not double-cp; outer block below is the authority.
export G05_SYNC_ASM=0
bash scripts/g05_relink_xlang.sh

if [ "$SYNC_ASM" = "1" ]; then
  cp -f "${G05_OUT:-xlang}" xlang_asm
  echo "g05_prepare_and_relink: xlang_asm OK (synced from ${G05_OUT:-xlang})"
fi

# Stage-2: pin egg may have baked fmt_check_cmd_driver via host-C (auto-deny
# pure-asm when lea_rax missing) or a stale pure-asm thin. Once this-wave
# xlang_asm carries pipeline_asm_modlet_lea_rax_*, FORCE rebuild fmt with it
# and relink once so product ships pure-asm fmt. PLATFORM: SHARED · G.7
# single ensure body (try-other-l2-prefer); skip when lea_rax absent.
_fmt_o="src/driver/fmt_check_cmd_driver.o"
_stage2_xl=""
if [ -x ./xlang_asm ]; then
  _stage2_xl=./xlang_asm
elif [ -x ./xlang ]; then
  _stage2_xl=./xlang
fi
if [ -n "$_stage2_xl" ] \
  && nm "$_stage2_xl" 2>/dev/null | grep -q 'pipeline_asm_modlet_lea_rax_' \
  && [ -f scripts/ensure_host_cc_seed_o.sh ]; then
  _fmt_before=0
  if [ -f "$_fmt_o" ]; then
    _fmt_before=$(stat -f %m "$_fmt_o" 2>/dev/null || stat -c %Y "$_fmt_o" 2>/dev/null || echo 0)
  fi
  echo "g05_prepare_and_relink: stage2 FORCE fmt_check_cmd_driver (lea_rax tip)"
  # shellcheck disable=SC2097,SC2098
  if XLANG="$_stage2_xl" FORCE=1 XLANG_G05_PREFER_X_O=1 \
    bash scripts/ensure_host_cc_seed_o.sh try-other-l2-prefer "$_fmt_o"; then
    _fmt_after=0
    if [ -f "$_fmt_o" ]; then
      _fmt_after=$(stat -f %m "$_fmt_o" 2>/dev/null || stat -c %Y "$_fmt_o" 2>/dev/null || echo 0)
    fi
    if [ "$_fmt_after" != "$_fmt_before" ]; then
      echo "g05_prepare_and_relink: stage2 fmt rebuilt; relink once"
      # shellcheck disable=SC2046
      eval "$(bash scripts/g05_relink_env.sh)"
      export G05_CC G05_CFLAGS G05_OUT G05_XLANG_C G05_BOOTSTRAP G05_OBJS
      export G05_SYNC_ASM=0
      bash scripts/g05_relink_xlang.sh
      if [ "$SYNC_ASM" = "1" ]; then
        cp -f "${G05_OUT:-xlang}" xlang_asm
        echo "g05_prepare_and_relink: stage2 xlang_asm re-synced"
      fi
    else
      echo "g05_prepare_and_relink: stage2 fmt unchanged (already tip)"
    fi
  else
    echo "g05_prepare_and_relink: WARN stage2 fmt ensure failed (keep prior .o)" >&2
  fi
fi

echo "g05_prepare_and_relink OK"
