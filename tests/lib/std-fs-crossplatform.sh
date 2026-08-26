#!/usr/bin/env bash
# std-fs-crossplatform.sh — STD-003 cross-platform matrix helpers.
#
# Usage (after source):
#   std_fs_xplat_run_x_smoke XLANG_BIN SRC OUT_PREFIX
#   std_fs_xplat_emit_report status check_ok x_ok skip
# 2026-08-26: report check=/x=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_FS_XPLAT_PREFIX="${XLANG_STD_FS_XPLAT_PREFIX:-xlang: [XLANG_STD_FS_XPLAT]}"

# Build+run one .x smoke; return 0 when process exits 0.
# @param $1 XLANG_BIN — resolved product compiler (prefer asm)
# @param $2 SRC — .x smoke path under tests/fs/
# @param $3 OUT_PREFIX — /tmp prefix for binary + build log
std_fs_xplat_run_x_smoke() {
  local xlang_bin="$1"
  local src="$2"
  local out_prefix="$3"
  local out="${out_prefix}"
  local log="${out_prefix}.log"
  # Prefer bootstrap-link RUN_XLANG when caller pinned XLANG_LINK_XLANG.
  # PLATFORM: SHARED — product path honesty.
  local runner="${RUN_XLANG:-}"
  if [ -z "$runner" ]; then
    runner="$xlang_bin"
  fi
  rm -f tests/fs/.crossplatform_tmp tests/fs/.mmap_ro_tmp
  if ! $runner -L . "$src" -o "$out" 2>"$log"; then
    echo "std-fs-crossplatform FAIL: link $src" >&2
    tail -20 "$log" 2>/dev/null >&2 || true
    rm -f "$out"
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  rm -f "$out" tests/fs/.crossplatform_tmp tests/fs/.mmap_ro_tmp
  if [ "$ec" -ne 0 ]; then
    echo "std-fs-crossplatform FAIL: $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (check observational; x runnable hard; skip only
# for manifest-only paths — never soft-OK when no native compiler).
# @param $1 status — ok|fail
# @param $2 check_ok — observational check (0/1; not hard green)
# @param $3 x_ok — all must-policy cases exit0 (hard green)
# @param $4 skip — 1 only for manifest-only
std_fs_xplat_emit_report() {
  local status="$1"
  local check_ok="$2"
  local x_ok="$3"
  local skip="$4"
  echo "${STD_FS_XPLAT_PREFIX} status=${status} check=${check_ok} x=${x_ok} skip=${skip}"
}
