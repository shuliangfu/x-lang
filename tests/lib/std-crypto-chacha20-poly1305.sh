#!/usr/bin/env bash
# std-crypto-chacha20-poly1305.sh — STD-113 manifest 与烟测辅助

STD_CRYPTO_CHACHA_PREFIX="${SHUX_STD113_CRYPTO_CHACHA_PREFIX:-shux: [SHUX_STD113_CRYPTO_CHACHA]}"
# shellcheck source=tests/lib/std-crypto.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/std-crypto.sh"

std_crypto_chacha_symbols_ok() {
  local mod_sx="$1"
  local crypto_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|const)
        if ! grep -qE "(function|const) ${anchor}" "$mod_sx" 2>/dev/null; then
          echo "std-crypto-chacha FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path
        path="$(std_crypto_resolve_impl_path "$mod_path")"
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-crypto-chacha FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-crypto-chacha FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_crypto_chacha_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_crypto_chacha_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-crypto-chacha FAIL: compile $src" >&2
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

std_crypto_chacha_run_c_smoke() {
  local crypto_o="$1"
  local src="tests/std-crypto/chacha_smoke_ok.c"
  local out="/tmp/shux_std_crypto_chacha_c_$$"
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t crypto_chacha20_poly1305_smoke_c(void);' \
      'int main(void) { return crypto_chacha20_poly1305_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$crypto_o" 2>/dev/null; then
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_crypto_chacha_emit_report() {
  echo "${STD_CRYPTO_CHACHA_PREFIX} status=$1 c=$2 sx=$3 skip=$4"
}
