#!/usr/bin/env bash
# std-compress-brotli.sh — STD-125 manifest 与烟测辅助

STD_COMPRESS_BROTLI_PREFIX="${SHUX_STD125_COMPRESS_BROTLI_PREFIX:-shux: [SHUX_STD125_COMPRESS_BROTLI]}"

std_compress_brotli_symbols_ok() {
  local mod_sx="$1"
  local compress_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null || miss=$((miss + 1))
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/compress/brotli/brotli_lib.sx|std/compress/brotli/brotli.c) path="$compress_c" ;;
        esac
        grep -qF "$anchor" "$path" 2>/dev/null || miss=$((miss + 1))
        ;;
      target)
        grep -qF "$anchor" "${mod_path:-compiler/Makefile}" 2>/dev/null || miss=$((miss + 1))
        ;;
      file|smoke)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 尝试 rebuild compress.o with Brotli；成功 echo 1，失败 echo 0。
std_compress_brotli_try_build() {
  if (cd compiler && make compress-o-brotli 2>/dev/null); then
    return 0
  fi
  return 1
}

std_compress_brotli_run_c_smoke() {
  local compress_o="$1"
  # F-04 v6+：brotli 符号在 .sx；无 compress.o 或无 C 符号时 SKIP
  if [ -z "$compress_o" ] || [ ! -f "$compress_o" ]; then
    return 2
  fi
  if ! nm -g "$compress_o" 2>/dev/null | grep -q 'compress_brotli_smoke_c'; then
    return 2
  fi
  local out="/tmp/shux_std_compress_brotli_c_$$"
  if ! cc -std=c11 -O1 -o "$out" tests/std-compress/brotli_smoke_ok.c "$compress_o" -lbrotlienc -lbrotlidec 2>/dev/null; then
    return 2
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_compress_brotli_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_compress_brotli_sx_$$"
  "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1 || return 1
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_compress_brotli_emit_report() {
  echo "${STD_COMPRESS_BROTLI_PREFIX} status=$1 brotli=$2 skip=$3"
}
