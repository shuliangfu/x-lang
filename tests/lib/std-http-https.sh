#!/usr/bin/env bash
# std-http-https.sh — STD-034 (STD-HTTP-HTTPS) manifest + smoke helpers
#
# Usage (after source):
#   std_http_https_symbols_ok MOD_X HTTP_C TSV
#   std_http_https_run_smoke XLANG_BIN X TAG
#   std_http_https_run_c_smoke HTTP_O NET_O LDFLAGS   # observational
#   std_http_https_emit_report status check_ok run_ok skip
# 2026-08-26: report check=/run=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_HTTP_HTTPS_PREFIX="${XLANG_STD_HTTP_HTTPS_PREFIX:-xlang: [XLANG_STD_HTTP_HTTPS]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_http_https_symbols_ok() {
  local mod_x="$1"
  local http_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-http-https FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local target="${mod_path:-$http_c}"
        case "$target" in
          compiler/seeds/runtime_http_glue.from_x.c) target="$http_c" ;;
        esac
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-http-https FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-http-https FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|anchor|hook_script)
        # DOC ## 4. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run https smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
# PLATFORM: SHARED archaeology — product honesty path.
std_http_https_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_http_https_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-http-https FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-http-https FAIL: compile $src" >&2
      $RUN_XLANG build -L . "$src" -o "$exe" 2>&1 | tail -10 >&2 || true
      rm -f "$exe"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-http-https FAIL: compile $src" >&2
      "$xlang" -L . "$src" 2>&1 | tail -8 >&2 || true
      rm -f "$exe"
      return 1
    fi
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-http-https FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Observational C smoke (OpenSSL / stub); never the hard-green signal.
# PLATFORM: SHARED archaeology — optional host-TLS probe only.
std_http_https_run_c_smoke() {
  local http_o="$1"
  local net_o="$2"
  local ldflags="$3"
  local out="/tmp/xlang_std_http_https_c_$$"
  # shellcheck disable=SC2086
  cc -std=c11 -O1 -o "$out" tests/http/https_smoke_ok.c "$http_o" "$net_o" $ldflags 2>/dev/null || return 1
  set +e
  XLANG_HTTPS_SMOKE_PORT="${XLANG_HTTPS_SMOKE_PORT:-}" "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# Structured report line (honesty: check=/run=/skip=).
std_http_https_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_HTTP_HTTPS_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
