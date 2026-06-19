#!/usr/bin/env bash
# std-crypto-aes-gcm.sh — STD-049 manifest 与烟测辅助

STD_CRYPTO_AES_GCM_PREFIX="${SHUX_STD_CRYPTO_AES_GCM_PREFIX:-shux: [SHUX_STD_CRYPTO_AES_GCM]}"

std_crypto_aes_gcm_symbols_ok() {
  local mod_su="$1"
  local crypto_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-crypto-aes-gcm FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_su" 2>/dev/null; then
          echo "std-crypto-aes-gcm FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/crypto/crypto.c) mod_path="$crypto_c" ;;
          std/crypto/aes_gcm.inc.c)
            mod_path="$(dirname "$crypto_c")/aes_gcm.inc.c"
            ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-crypto-aes-gcm FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-crypto-aes-gcm FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_crypto_aes_gcm_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_crypto_aes_gcm_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-crypto-aes-gcm FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-crypto-aes-gcm FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_crypto_aes_gcm_emit_report() {
  local status="$1"
  local seal_ok="$2"
  local open_ok="$3"
  local main_ok="$4"
  local skip="$5"
  echo "${STD_CRYPTO_AES_GCM_PREFIX} status=${status} seal=${seal_ok} open=${open_ok} main=${main_ok} skip=${skip}"
}
