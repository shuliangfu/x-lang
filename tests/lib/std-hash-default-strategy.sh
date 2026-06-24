#!/usr/bin/env bash
# std-hash-default-strategy.sh — STD-148 manifest 与烟测辅助

STD148_PREFIX="${SHUX_STD148_HASH_DEFAULT_STRATEGY_PREFIX:-shux: [SHUX_STD148_HASH_DEFAULT_STRATEGY]}"

# 校验 manifest；echo 缺失数。
std_hash_default_strategy_symbols_ok() {
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
          echo "std-hash-default-strategy FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/hash/hash_glue.c" ]; then path="$hash_sx"; fi
        if [ "$path" = "std/hash/hash.sx" ]; then path="$hash_sx"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-hash-default-strategy FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-hash-default-strategy FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$anchor" ]; then
          echo "std-hash-default-strategy FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-hash-default-strategy-v1.md" 2>/dev/null; then
          echo "std-hash-default-strategy FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 校验策略向量 TSV 至少 3 条用例。
std_hash_default_strategy_vectors_ok() {
  local tsv="$1"
  local min="${2:-3}"
  local n=0
  while IFS=$'\t' read -r use_case _rest; do
    [ -z "${use_case:-}" ] && continue
    case "$use_case" in \#*) continue ;; esac
    n=$((n + 1))
  done < "$tsv"
  if [ "$n" -lt "$min" ]; then
    echo "std-hash-default-strategy FAIL: vectors $n < min $min" >&2
    return 1
  fi
  return 0
}

# 编译并运行 C 默认策略烟测。
std_hash_default_strategy_run_c_smoke() {
  local hash_sx="$1"
  local src="tests/std-hash/default_strategy_ok.c"
  local out="/tmp/shux_hash_default_strategy_c_$$"
  local hash_o
  hash_o="$(dirname "$hash_sx")/hash.o"
  if [ ! -f "$hash_o" ]; then
    echo "std-hash-default-strategy FAIL: missing $hash_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O0 -o "$out" "$src" "$hash_o" 2>/dev/null; then
    echo "std-hash-default-strategy FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-hash-default-strategy FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 编译并运行 .sx 烟测。
std_hash_default_strategy_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local hash_o="$3"
  local exe="/tmp/shux_hash_default_strategy_sx_$$"
  if ! "$shux" -L . "$src" -o "$exe" "$hash_o" >/dev/null 2>&1; then
    echo "std-hash-default-strategy FAIL: compile $src" >&2
    "$shux" -L . "$src" -o "$exe" "$hash_o" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-hash-default-strategy FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_hash_default_strategy_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD148_PREFIX} status=${status} c=${c_ok} sx=${su_ok} skip=${skip}"
}
