#!/usr/bin/env bash
# std-socketio.sh — STD-SOCKETIO-001 helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_socketio_symbols_ok MOD_X SIO_X TSV
#   std_socketio_run_smoke XLANG_BIN SRC [TAG]
#   std_socketio_run_c_smoke SOCKETIO_O   # prebuilt only; refuse soft ensure
#   std_socketio_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SOCKETIO_PREFIX="${XLANG_STD_SOCKETIO_PREFIX:-xlang: [XLANG_STD_SOCKETIO]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_socketio_symbols_ok() {
  local mod_x="$1"
  local c_src="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-socketio FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        if ! grep -qF "${anchor}" "$c_src" 2>/dev/null; then
          echo "std-socketio FAIL: missing symbol '$anchor' in $c_src" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD_SOCKETIO_DOC:-analysis/archive/std/std-socketio-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-socketio FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|file)
        if [ ! -f "$anchor" ]; then
          echo "std-socketio FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-socketio FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Product tip -o smoke. Caller decides hard vs obs (tip UNDEF/SEGV = obs leave).
# PLATFORM: SHARED archaeology — product honesty path.
# Do not restore set -e between steps: return 1 must not trip the gate's set +e window.
std_socketio_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local base
  base=$(basename "$src" .x)
  local exe="/tmp/xlang_std_socketio_${tag}_${base}_$$"
  local log="/tmp/xlang_std_socketio_${tag}_${base}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-socketio FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-socketio OBS tip product -o $src (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-socketio OBS tip run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Host-C archaeology: prebuilt std/socketio/socketio.o only.
# Refuse soft ensure_std_c_o / soft auto-make.
# Returns 0 green, 1 link/run fail, 2 missing prebuilt / missing smoke symbol.
# PLATFORM: SHARED — do not toggle set -e (leaks make return 1 kill the gate).
std_socketio_run_c_smoke() {
  local socketio_o="$1"
  local src="tests/socketio/packet_smoke_ok.c"
  local out="/tmp/xlang_std_socketio_c_$$"
  if [ ! -f "$socketio_o" ]; then
    echo "std-socketio OBS c smoke (missing prebuilt $socketio_o; refuse soft ensure)" >&2
    return 2
  fi
  if ! nm "$socketio_o" 2>/dev/null | grep -qE ' (sio_packet_smoke_c|socketio_packet_smoke_c)$'; then
    echo "std-socketio OBS c smoke (socketio.o missing packet smoke symbol; refuse soft rebuild)" >&2
    return 2
  fi
  if [ ! -f "$src" ]; then
    # Minimal harness when archaeology C smoke source is absent.
    # PLATFORM: SHARED — obs path only; not a soft product rebuild.
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t sio_packet_smoke_c(void);' \
      'int main(void) { return sio_packet_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$socketio_o" 2>/tmp/std_socketio_c_$$.log; then
    echo "std-socketio OBS c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-socketio OBS c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired smoke=).
std_socketio_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_SOCKETIO_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
