#!/usr/bin/env bash
# std-crypto-sha512-hmac.sh — STD-050 manifest 与烟测辅助

STD_CRYPTO_SHA512_HMAC_PREFIX="${SHUX_STD_CRYPTO_SHA512_HMAC_PREFIX:-shux: [SHUX_STD_CRYPTO_SHA512_HMAC]}"
# shellcheck source=tests/lib/std-crypto.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/std-crypto.sh"

# 遍历 manifest TSV，校验 api/const/symbol/file/smoke 锚点。
std_crypto_sha512_hmac_symbols_ok() {
  local mod_sx="$1"
  local crypto_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-crypto-sha512-hmac FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_sx" 2>/dev/null; then
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
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测 .sx；期望退出码 0。
std_crypto_sha512_hmac_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_crypto_sha512_hmac_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-crypto-sha512-hmac FAIL: compile $src" >&2
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
    echo "std-crypto-sha512-hmac FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告行。
std_crypto_sha512_hmac_emit_report() {
  local status="$1"
  local sha512_ok="$2"
  local hmac_ok="$3"
  local mac_ok="$4"
  local skip="$5"
  echo "${STD_CRYPTO_SHA512_HMAC_PREFIX} status=${status} sha512=${sha512_ok} hmac=${hmac_ok} mac512=${mac_ok} skip=${skip}"
}
