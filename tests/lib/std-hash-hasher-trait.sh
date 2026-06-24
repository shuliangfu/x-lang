#!/usr/bin/env bash
# std-hash-hasher-trait.sh — STD-056 manifest 与烟测辅助

STD_HASH_HASHER_TRAIT_PREFIX="${SHUX_STD_HASH_HASHER_TRAIT_PREFIX:-shux: [SHUX_STD_HASH_HASHER_TRAIT]}"

# 遍历 manifest TSV，校验 api/const/symbol/file/smoke。
std_hash_hasher_trait_symbols_ok() {
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
          echo "std-hash-hasher-trait FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_sx" 2>/dev/null; then
          echo "std-hash-hasher-trait FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/hash/hash_glue.c" ]; then path="$hash_sx"; fi
        if [ "$path" = "std/hash/hash.sx" ]; then path="$hash_sx"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-hash-hasher-trait FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-hash-hasher-trait FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_hash_hasher_trait_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_hash_ht_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-hash-hasher-trait FAIL: compile $src" >&2
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
    echo "std-hash-hasher-trait FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# C 烟测：hasher_switch_ok.c + hash.o。
std_hash_hasher_trait_run_c_smoke() {
  local hash_sx="$1"
  local src="tests/std-hash/hasher_switch_ok.c"
  local out="/tmp/shux_std_hash_hasher_$$"
  local hash_o
  hash_o="$(dirname "$hash_sx")/hash.o"
  if [ ! -f "$hash_o" ]; then
    echo "std-hash-hasher-trait FAIL: missing $hash_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$hash_o" 2>/dev/null; then
    echo "std-hash-hasher-trait FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-hash-hasher-trait FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告行。
std_hash_hasher_trait_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_HASH_HASHER_TRAIT_PREFIX} status=${status} c_smoke=${c_ok} sx=${su_ok} skip=${skip}"
}
