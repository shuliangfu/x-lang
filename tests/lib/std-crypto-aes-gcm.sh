#!/usr/bin/env bash
# std-crypto-aes-gcm.sh — STD-049 AES-GCM helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_crypto_aes_gcm_symbols_ok MOD_X CRYPTO_GLUE TSV
#   std_crypto_aes_gcm_run_smoke XLANG_BIN SRC [TAG]
#   std_crypto_aes_gcm_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / XLANG fallthrough /
# bootstrap-link remap; report run=/obs=/skip= (retired check=/main=/nist2=).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_CRYPTO_AES_GCM_PREFIX="${XLANG_STD_CRYPTO_AES_GCM_PREFIX:-xlang: [XLANG_STD_CRYPTO_AES_GCM]}"
# shellcheck source=tests/lib/std-crypto.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/std-crypto.sh"

# Validate manifest; echo miss count; return 0 iff miss==0.
# Kinds: api / const / symbol / file / smoke / script / section.
# Full-path TSV anchors preferred. Resolve C/glue via std_crypto_resolve_impl_path.
# PLATFORM: SHARED archaeology — inventory only; do not invoke make.
std_crypto_aes_gcm_symbols_ok() {
  local mod_x="$1"
  local crypto_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-crypto-aes-gcm FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
          echo "std-crypto-aes-gcm FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        path="$(std_crypto_resolve_impl_path "$mod_path")"
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-crypto-aes-gcm FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-crypto-aes-gcm FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        path="$anchor"
        if [ ! -f "$path" ]; then
          path="${mod_path:-}"
        fi
        if [ ! -f "$path" ]; then
          echo "std-crypto-aes-gcm FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        # DOC ## 5. Gate / section anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Product tip -o smoke. Caller decides hard vs obs (nist2 RUN≠0 = obs leave).
# PLATFORM: SHARED archaeology — product honesty path.
# Do not restore set -e between steps: return 1 must not trip the gate's set -e.
# Refuse RUN_XLANG / bootstrap-link remap (Darwin must not silently asm→c).
std_crypto_aes_gcm_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_crypto_aes_gcm_${tag}_$$"
  local log="/tmp/xlang_std_crypto_aes_gcm_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-crypto-aes-gcm FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-crypto-aes-gcm OBS tip product -o $src (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-crypto-aes-gcm OBS tip run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired check=/main=/nist2=).
# Hard-green signal = crypto/main.x product -o (run=1); check/nist2 = obs.
std_crypto_aes_gcm_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_CRYPTO_AES_GCM_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
