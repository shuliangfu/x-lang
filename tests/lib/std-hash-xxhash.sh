#!/usr/bin/env bash
# std-hash-xxhash.sh — STD-105 manifest 与 xxHash64 烟测辅助

STD_HASH_XXHASH_PREFIX="${SHUX_STD_HASH_XXHASH_PREFIX:-shux: [SHUX_STD105_HASH_XXHASH]}"

# 校验 manifest 中 api/const/symbol/file。
std_hash_xxhash_symbols_ok() {
  local mod_sx="$1"
  local hash_sx="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-hash-xxhash FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_sx" 2>/dev/null; then
          echo "std-hash-xxhash FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/hash/hash_glue.c" ]; then path="$hash_sx"; fi
        if [ "$path" = "std/hash/hash.sx" ]; then path="$hash_sx"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-hash-xxhash FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-hash-xxhash FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_hash_xxhash_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-xxhash}"
  local exe="/tmp/shux_std_hash_xx_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-hash-xxhash FAIL: compile $src" >&2
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
    echo "std-hash-xxhash FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# C 烟测：xxhash64_smoke_ok.c + hash.o。
std_hash_xxhash_run_c_smoke() {
  local hash_sx="$1"
  local src="tests/std-hash/xxhash64_smoke_ok.c"
  local out="/tmp/shux_std_hash_xxhash_$$"
  local hash_o
  hash_o="$(dirname "$hash_sx")/hash.o"
  if [ ! -f "$hash_o" ]; then
    echo "std-hash-xxhash FAIL: missing $hash_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$hash_o" 2>/dev/null; then
    echo "std-hash-xxhash FAIL: compile C smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-hash-xxhash FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_hash_xxhash_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_HASH_XXHASH_PREFIX} status=${status} c=${c_ok} sx=${su_ok} skip=${skip}"
}
