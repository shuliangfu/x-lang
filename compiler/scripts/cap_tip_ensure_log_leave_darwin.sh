#!/usr/bin/env bash
# Cap tip leftover: true-cold wipe rebuilds runtime_log_os.o from cold seed
# only — 9.1 removed cold public wrappers, so log.o UNDEFs
# log_set_{file_sink,min_level,rotate,sink_mask}_c. Rebuild thin.x +
# darwin.x (prefer asm). Fallback: thin + FROM_X rest. No FORCE_CC /
# new host-cc .c. PLATFORM: MACOS|DARWIN Cap tip.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."


# note743y.6.23: tip pure-asm of source ___open emits Mach-O U ____open;
# libsystem_kernel exports ___open. Cap tip emits ___open. Same egg as
# NSGetArgc / ensure_log_os_darwin_pure. PLATFORM: MACOS|DARWIN.
_cap_tip_log_fix_open_egg() {
  local o="$1"
  [ -s "$o" ] || return 0
  if ! nm -u "$o" 2>/dev/null | awk '$NF=="____open" { f=1 } END { exit f?0:1 }'; then
    return 0
  fi
  local oc=""
  for c in "${LLVM_OBJCOPY:-}" /opt/homebrew/opt/llvm/bin/llvm-objcopy \
    /usr/local/opt/llvm/bin/llvm-objcopy; do
    [ -n "$c" ] && [ -x "$c" ] && oc="$c" && break
  done
  if [ -z "$oc" ] && command -v llvm-objcopy >/dev/null 2>&1; then
    oc="$(command -v llvm-objcopy)"
  fi
  [ -n "$oc" ] || {
    echo "cap_tip_ensure_log: llvm-objcopy missing for ____open→___open" >&2
    return 1
  }
  if ! "$oc" --redefine-sym '____open=___open' "$o"; then
    echo "cap_tip_ensure_log: ____open→___open redefine failed" >&2
    return 1
  fi
  if nm -u "$o" 2>/dev/null | awk '$NF=="____open" { f=1 } END { exit f?0:1 }'; then
    echo "cap_tip_ensure_log: U ____open remains after redefine" >&2
    return 1
  fi
  echo "cap_tip_ensure_log: Darwin tip ____open → ___open" >&2
  return 0
}


out=runtime_log_os.o
x_thin=src/asm/runtime_log_os.x
x_os=src/asm/runtime_log_os_darwin.x
seed=seeds/runtime_log_os.from_x.c
need_rebuild=0
if [ ! -s "$out" ]; then
  need_rebuild=1
else
  for s in _log_set_file_sink_c _log_set_min_level_c _log_set_rotate_c _log_set_sink_mask_c; do
    if ! nm -gU "$out" 2>/dev/null | grep -q "T ${s}\$"; then
      need_rebuild=1
      break
    fi
  done
fi
if [ "$need_rebuild" = "0" ]; then
  echo "cap_tip_ensure_log: $out already has public log_set_*_c wrappers" >&2
  # Still fix tip ____open egg left from a prior thin+darwin merge.
  _cap_tip_log_fix_open_egg "$out" || exit 1
  exit 0
fi

[ -f "$x_thin" ] || { echo "cap_tip_ensure_log: missing $x_thin" >&2; exit 1; }
[ -f "$x_os" ] || { echo "cap_tip_ensure_log: missing $x_os" >&2; exit 1; }

_xl=""
if [ -x ./xlang.product_legacy_bak ]; then
  _xl=./xlang.product_legacy_bak
elif [ -n "${XLANG:-}" ] && [ -x "${XLANG}" ]; then
  _xl="$XLANG"
elif [ -x ./xlang ]; then
  _xl=./xlang
fi
[ -n "$_xl" ] || { echo "cap_tip_ensure_log: no XLANG for tip-compile" >&2; exit 1; }

thin_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_log_thin.XXXXXX.o")"
os_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_log_os.XXXXXX.o")"
rest_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_log_rest.XXXXXX.o")"
cleanup() { rm -f "$thin_o" "$os_o" "$rest_o"; }
trap cleanup EXIT

if ! XLANG_PREFER_ASM_O=1 "$_xl" -backend asm -c "$x_thin" -o "$thin_o" 2>/dev/null \
  || ! nm -gU "$thin_o" 2>/dev/null | grep -q 'T _log_set_min_level_c$'; then
  echo "cap_tip_ensure_log: thin tip-compile failed ($_xl)" >&2
  exit 1
fi

merged=0
if XLANG_PREFER_ASM_O=1 "$_xl" -backend asm -c "$x_os" -o "$os_o" 2>/dev/null \
  && [ -s "$os_o" ] \
  && ld -r -o "$out" "$thin_o" "$os_o" 2>/dev/null; then
  merged=1
  echo "cap_tip_ensure_log: OK thin+darwin $out" >&2
elif [ -f "$seed" ] \
  && cc -c -I. -Iinclude -Isrc -Isrc/asm -DXLANG_RUNTIME_LOG_OS_FROM_X \
       -o "$rest_o" "$seed" 2>/dev/null \
  && [ -s "$rest_o" ] \
  && ld -r -o "$out" "$thin_o" "$rest_o" 2>/dev/null; then
  merged=1
  echo "cap_tip_ensure_log: OK thin+FROM_X rest $out" >&2
fi
[ "$merged" = "1" ] || { echo "cap_tip_ensure_log: merge failed" >&2; exit 1; }

for s in _log_set_file_sink_c _log_set_min_level_c _log_set_rotate_c _log_set_sink_mask_c; do
  nm -gU "$out" 2>/dev/null | grep -q "T ${s}\$" \
    || { echo "cap_tip_ensure_log: merged $out missing $s" >&2; exit 1; }
done
_cap_tip_log_fix_open_egg "$out" || exit 1
