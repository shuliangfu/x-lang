#!/usr/bin/env bash
# std-net-dns.sh — STD-029 manifest + smoke helpers
#
# Usage (after source):
#   std_net_dns_symbols_ok MOD_X NET_DNS_X TSV
#   std_net_dns_run_smoke XLANG_BIN X TAG
#   std_net_dns_emit_report status check_ok resolve_ok main_ok skip
# 2026-08-26: report check=/resolve=/main=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_NET_DNS_PREFIX="${XLANG_STD_NET_DNS_PREFIX:-xlang: [XLANG_STD_NET_DNS]}"

# Validate manifest symbol/file/api; echo miss count; return 0 iff miss==0.
std_net_dns_symbols_ok() {
  local mod_x="$1"
  local net_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-net-dns FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/net/net.c) mod_path="${net_c:-std/net/dns.x}" ;;
          std/net/dns.x) mod_path="std/net/dns.x" ;;
          *) mod_path="${mod_path:-$mod_x}" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-net-dns FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-net-dns FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|anchor|hook_script|cross_ref)
        # DOC ## 5. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run a smoke .x (net.o must already be ensured by the gate).
# Honors XLANG / XLANG_LINK_XLANG when the caller pinned prefer-asm.
std_net_dns_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_net_dns_${tag}_$$"
  local run_xlang="${XLANG:-$xlang}"
  if [ ! -f "$src" ]; then
    echo "std-net-dns FAIL: missing $src" >&2
    return 1
  fi
  if ! "$run_xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-net-dns FAIL: compile $src" >&2
    "$run_xlang" -L . "$src" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-net-dns FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: check=/resolve=/main=/skip=).
# Hard-green signal = resolve= + main=; check observational.
std_net_dns_emit_report() {
  local status="$1"
  local check_ok="$2"
  local resolve_ok="$3"
  local main_ok="$4"
  local skip="$5"
  echo "${STD_NET_DNS_PREFIX} status=${status} check=${check_ok} resolve=${resolve_ok} main=${main_ok} skip=${skip}"
}
