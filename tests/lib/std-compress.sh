#!/usr/bin/env bash
# std-compress.sh — STD-007: std.compress helpers (false-authority honesty)
#
# Usage (after source):
#   std_compress_has_api MOD fn
#   std_compress_try_libs
#   std_compress_run_smoke XLANG src tag
#   std_compress_emit_report status check_ok gzip_ok zstd_ok legacy_ok skip
#
# Prefer product asm + RUN_XLANG (after gate pins XLANG_LINK_XLANG).
# PLATFORM: SHARED archaeology.

STD_COMPRESS_PREFIX="${XLANG_STD_COMPRESS_PREFIX:-xlang: [XLANG_STD_COMPRESS]}"

# Check mod.x exports the named function.
std_compress_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# F-04 v7: formats are .x; compress-o-* hub no-ops; runtime links -lz/-lzstd/-lbrotli*.
# G.7: xlang_compiler_make — ban bare make (MF phys-del). PLATFORM: SHARED
std_compress_try_libs() {
  if type xlang_compiler_make >/dev/null 2>&1; then
    xlang_compiler_make compress-o-zlib-zstd 2>/dev/null || true
  elif [ -f tests/lib/compiler-make.sh ]; then
    # shellcheck source=tests/lib/compiler-make.sh
    . tests/lib/compiler-make.sh
    xlang_compiler_make compress-o-zlib-zstd 2>/dev/null || true
  fi
  echo "std-compress: formats via .x (F-04 v7, no compress.o)" >&2
  return 0
}

std_compress_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# Prefer product asm; pin path used by gate via XLANG_LINK_XLANG.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
std_compress_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if std_compress_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

# Compile and run smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
# PLATFORM: SHARED archaeology — product honesty path.
std_compress_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_compress_${tag}_$$"
  local log="/tmp/xlang_std_compress_build_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-compress FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-compress FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-compress FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-compress FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: check=/gzip=/zstd=/legacy=/skip=).
std_compress_emit_report() {
  local status="$1"
  local check_ok="$2"
  local gzip_ok="$3"
  local zstd_ok="$4"
  local legacy_ok="$5"
  local skip="$6"
  echo "${STD_COMPRESS_PREFIX} status=${status} check=${check_ok} gzip=${gzip_ok} zstd=${zstd_ok} legacy=${legacy_ok} skip=${skip}"
}
