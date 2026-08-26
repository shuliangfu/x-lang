#!/usr/bin/env bash
# std-url-ipv6-host.sh — STD-134 manifest and smoke helpers (honesty).
# PLATFORM: SHARED archaeology.

STD_URL_IPV6_HOST_PREFIX="${XLANG_STD134_URL_IPV6_HOST_PREFIX:-xlang: [XLANG_STD134_URL_IPV6_HOST]}"

# Validate manifest entries; echo missing count.
# @param $1 mod_x — std/url/mod.x
# @param $2 url_x — std/url/url.x
# @param $3 tsv — baseline manifest
std_url_ipv6_host_symbols_ok() {
  local mod_x="$1"
  local url_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-url-ipv6-host FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/url/url_glue.c) path="$url_x" ;;
          std/url/url.x) path="$url_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-url-ipv6-host FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "${XLANG_STD_URL_IPV6_HOST_DOC:-analysis/archive/std/std-url-ipv6-host-v1.md}" 2>/dev/null; then
          echo "std-url-ipv6-host FAIL: doc missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script)
        if [ ! -f "$anchor" ]; then
          echo "std-url-ipv6-host FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run .x smoke with given compiler.
# @param $1 xlang — compiler binary
# @param $2 src — .x smoke path
std_url_ipv6_host_run_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_std_url_ipv6_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-url-ipv6-host FAIL: compile $src" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

# Link url.o and run host-C archaeology smoke (observational only).
# @param $1 url_o — path to url.o
std_url_ipv6_host_run_c_smoke() {
  local url_o="$1"
  local src="tests/std-url/ipv6_host_smoke_ok.c"
  local out="/tmp/xlang_std_url_ipv6_c_$$"
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t url_ipv6_host_smoke_c(void);' \
      'int main(void) { return url_ipv6_host_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$url_o" 2>/dev/null; then
    echo "std-url-ipv6-host FAIL: link C smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# Emit structured report line (honesty: check=/run=/skip=).
# @param $1 status — ok|fail
# @param $2 check_ok — observational check (0/1; not hard green)
# @param $3 run_ok — runnable .x smoke exit0 (hard green signal)
# @param $4 skip — 1 only for manifest-only / no-native paths
std_url_ipv6_host_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_URL_IPV6_HOST_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
