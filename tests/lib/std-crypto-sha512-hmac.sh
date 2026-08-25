#!/usr/bin/env bash
# std-crypto-sha512-hmac.sh — STD-050 manifest + smoke helpers
#
# Usage (after source):
#   std_crypto_sha512_hmac_symbols_ok MOD_X CRYPTO_GLUE TSV
#   std_crypto_sha512_hmac_run_smoke XLANG_BIN X TAG
#   std_crypto_sha512_hmac_emit_report status check_ok sha512_ok hmac_ok mac_ok skip
# 2026-08-26: report check=/sha512=/hmac=/mac512=/skip= (honesty; prefer asm;
# sha512/hmac runnable hard; mac512 observational).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_CRYPTO_SHA512_HMAC_PREFIX="${XLANG_STD_CRYPTO_SHA512_HMAC_PREFIX:-xlang: [XLANG_STD_CRYPTO_SHA512_HMAC]}"
# shellcheck source=tests/lib/std-crypto.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/std-crypto.sh"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_crypto_sha512_hmac_symbols_ok() {
  local mod_x="$1"
  local crypto_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-crypto-sha512-hmac FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
          echo "std-crypto-sha512-hmac FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path
        path="$(std_crypto_resolve_impl_path "$mod_path")"
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-crypto-sha512-hmac FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-crypto-sha512-hmac FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|anchor|hook_script)
        # DOC ## 5. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
# PLATFORM: SHARED archaeology — product honesty path.
std_crypto_sha512_hmac_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_crypto_sha512_hmac_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-crypto-sha512-hmac FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-crypto-sha512-hmac FAIL: compile $src" >&2
      $RUN_XLANG build -L . "$src" -o "$exe" 2>&1 | tail -10 >&2 || true
      rm -f "$exe"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-crypto-sha512-hmac FAIL: compile $src" >&2
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
    echo "std-crypto-sha512-hmac FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: check=/sha512=/hmac=/mac512=/skip=).
# Hard-green signal = sha512= + hmac=; check + mac512 observational.
std_crypto_sha512_hmac_emit_report() {
  local status="$1"
  local check_ok="$2"
  local sha512_ok="$3"
  local hmac_ok="$4"
  local mac_ok="$5"
  local skip="$6"
  echo "${STD_CRYPTO_SHA512_HMAC_PREFIX} status=${status} check=${check_ok} sha512=${sha512_ok} hmac=${hmac_ok} mac512=${mac_ok} skip=${skip}"
}
