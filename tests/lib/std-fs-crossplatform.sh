#!/usr/bin/env bash
# std-fs-crossplatform.sh — STD-003 cross-platform matrix helpers.
#
# Usage (after source):
#   std_fs_xplat_run_x_smoke XLANG_BIN SRC OUT_PREFIX
#   std_fs_xplat_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check = obs; must-policy product -o hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_FS_XPLAT_PREFIX="${XLANG_STD_FS_XPLAT_PREFIX:-xlang: [XLANG_STD_FS_XPLAT]}"

# Build+run one .x smoke via product XLANG_BIN -L . -o; expect exit 0.
# Refuse soft RUN_XLANG remap / soft ensure rebuild (gate pins XLANG_LINK_XLANG).
# PLATFORM: SHARED archaeology — product honesty path.
# @param $1 XLANG_BIN — resolved product compiler (prefer asm)
# @param $2 SRC — .x smoke path under tests/fs/
# @param $3 OUT_PREFIX — /tmp prefix for binary + build log
std_fs_xplat_run_x_smoke() {
  local xlang_bin="$1"
  local src="$2"
  local out_prefix="$3"
  local out="${out_prefix}"
  local log="${out_prefix}.log"
  rm -f tests/fs/.crossplatform_tmp tests/fs/.mmap_ro_tmp
  rm -f "$out" "$log"
  set +e
  "$xlang_bin" -L . "$src" -o "$out" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    echo "std-fs-crossplatform FAIL: link $src" >&2
    tail -n 20 "$log" 2>/dev/null >&2 || true
    rm -f "$out" "$log"
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out" "$log" tests/fs/.crossplatform_tmp tests/fs/.mmap_ro_tmp
  if [ "$ec" -ne 0 ]; then
    echo "std-fs-crossplatform FAIL: $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal is must-policy runnable (folded into run=); check = obs.
# @param $1 status — ok|fail
# @param $2 run_ok — must-policy hard green (0/1)
# @param $3 obs — observational residuals (check / optional)
# @param $4 skip — 1 only for manifest-only
std_fs_xplat_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_FS_XPLAT_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
