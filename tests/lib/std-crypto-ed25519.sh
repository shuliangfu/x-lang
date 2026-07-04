#!/usr/bin/env bash
# std-crypto-ed25519.sh — STD-126 manifest 与烟测辅助

STD_CRYPTO_ED25519_PREFIX="${SHUX_STD126_CRYPTO_ED25519_PREFIX:-shux: [SHUX_STD126_CRYPTO_ED25519]}"
# shellcheck source=tests/lib/std-crypto.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/std-crypto.sh"

# 校验 manifest 中 api/const/symbol/file/smoke 条目是否存在于对应文件。
std_crypto_ed25519_symbols_ok() {
  local mod_x="$1"
  local crypto_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|const)
        if ! grep -qE "(function|const) ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-crypto-ed25519 FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path
        path="$(std_crypto_resolve_impl_path "$mod_path")"
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-crypto-ed25519 FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-crypto-ed25519 FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .x 烟测；成功返回 0。
std_crypto_ed25519_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_crypto_ed25519_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-crypto-ed25519 FAIL: compile $src" >&2
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

# 链接 crypto.o 运行 C 层 ed25519_smoke；成功返回 0。
std_crypto_ed25519_run_c_smoke() {
  local crypto_o="$1"
  local src="tests/std-crypto/ed25519_smoke_ok.c"
  local out="/tmp/shux_std_crypto_ed25519_c_$$"
  if [ ! -f "$crypto_o" ]; then
    return 1
  fi
  if ! std_crypto_o_has_x_symbols "$crypto_o"; then
    echo "std-crypto-ed25519 SKIP c smoke (crypto.o missing .x symbols; need shux-c)" >&2
    return 2
  fi
  std_crypto_ensure_runtime_glue_o
  if ! nm "$crypto_o" 2>/dev/null | grep -qE ' crypto_ed25519_smoke_c$'; then
    echo "std-crypto-ed25519 SKIP c smoke (missing ed25519 smoke symbol)" >&2
    return 2
  fi
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t crypto_ed25519_smoke_c(void);' \
      'int main(void) { return crypto_ed25519_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" $(std_crypto_c_link_objs) 2>/dev/null; then
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# 输出 gate 报告行。
std_crypto_ed25519_emit_report() {
  echo "${STD_CRYPTO_ED25519_PREFIX} status=$1 c=$2 x=$3 skip=$4"
}
