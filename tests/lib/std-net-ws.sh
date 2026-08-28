#!/usr/bin/env bash
# std-net-ws.sh — STD-031 WebSocket manifest helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_net_ws_symbols_ok MOD_X WS_CODEC TSV
#   std_net_ws_run_c_smoke   # prebuilt std/net/net.o only
#   std_net_ws_run_smoke XLANG_BIN SRC TAG
#   std_net_ws_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_NET_WS_PREFIX="${XLANG_STD_NET_WS_PREFIX:-xlang: [XLANG_STD_NET_WS]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_net_ws_symbols_ok() {
  local mod_x="$1"
  local ws_inc="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-net-ws FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local target="${mod_path:-$ws_inc}"
        case "$mod_path" in
          std/net/ws_codec.x|std/net/ws_io.x) target="$mod_path" ;;
          std/net/ws.inc.c) target="std/net/ws_codec.x" ;;
        esac
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-net-ws FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD_NET_WS_DOC:-analysis/archive/std/std-net-ws-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-net-ws FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-net-ws FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-net-ws FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "std-net-ws FAIL: missing cross_ref '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology: prebuilt std/net/net.o only (refuse soft ensure_std_c_o).
# Returns 0 green, 1 link/run fail, 2 missing prebuilt .o.
# PLATFORM: SHARED — do not toggle set -e.
std_net_ws_run_c_smoke() {
  local src="/tmp/xlang_std_net_ws_accept_$$.c"
  local out="/tmp/xlang_std_net_ws_c_$$"
  local net_o="std/net/net.o"
  if [ ! -f "$net_o" ]; then
    echo "std-net-ws OBS c smoke (missing prebuilt $net_o; refuse soft auto-make)" >&2
    return 2
  fi
  # Ephemeral Accept probe under /tmp (do not dirtysrc tree).
  # PLATFORM: SHARED archaeology — observational only.
  printf '%s\n' \
    '#include <stdint.h>' \
    'extern int32_t net_ws_compute_accept_c(const char *key, char *out, int32_t out_cap);' \
    'int main(void) {' \
    '  char outb[64];' \
    '  int32_t n = net_ws_compute_accept_c("dGhlIHNhbXBsZSBub25jZQ==", outb, 64);' \
    '  return n > 0 ? 0 : 1;' \
    '}' > "$src"
  if ! ${CC:-cc} -std=c11 -O1 -o "$out" "$src" "$net_o" 2>/tmp/std_net_ws_c_$$.log; then
    echo "std-net-ws OBS c smoke link (refuse soft ensure)" >&2
    rm -f "$src"
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out" "$src"
  if [ "$ec" -ne 0 ]; then
    echo "std-net-ws OBS c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Product tip -o smoke. Caller decides hard vs obs (tip UNDEF = obs leave).
# PLATFORM: SHARED archaeology — product honesty path.
std_net_ws_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_net_ws_${tag}_$$"
  local log="/tmp/xlang_std_net_ws_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-net-ws FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-net-ws OBS tip product -o (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-net-ws OBS tip run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired accept=/frame=/typeck=).
std_net_ws_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_NET_WS_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
