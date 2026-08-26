#!/usr/bin/env bash
# std-async-api.sh — STD-004 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_async_api_symbols_ok MOD_X TSV
#   std_async_api_run_smoke XLANG_BIN X TAG
#   std_async_api_emit_report status check_ok switch_ok imp_ok drain_ok coop_ok skip

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
STD_ASYNC_API_PREFIX="${XLANG_STD_ASYNC_API_PREFIX:-xlang: [XLANG_STD_ASYNC_API]}"

# Count missing Tier-S symbols from one-symbol-per-line TSV against mod.x.
# Prints miss count on stdout; returns 0 iff miss==0.
std_async_api_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local n=0
  local line sym
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|'#'*) continue ;;
    esac
    # Ignore future structured TSV rows (kind in column 2).
    case "$line" in
      *$'\t'*) continue ;;
    esac
    sym="$line"
    n=$((n + 1))
    if ! grep -qE "(function|extern function) ${sym}[[:space:](]" "$mod_x" 2>/dev/null; then
      echo "std-async-api FAIL: missing symbol ${sym} in $mod_x" >&2
      miss=$((miss + 1))
    fi
  done < "$tsv"
  if [ "$n" -lt 1 ]; then
    echo "std-async-api FAIL: empty symbol list in $tsv" >&2
    echo 1
    return 1
  fi
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_async_api_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_async_api_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-async-api FAIL: missing $src" >&2
    return 1
  fi
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-async-api FAIL: compile $src" >&2
    "$xlang" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-async-api FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_async_api_emit_report() {
  local status="$1"
  local check_ok="$2"
  local switch_ok="$3"
  local imp_ok="$4"
  local drain_ok="$5"
  local coop_ok="$6"
  local skip="$7"
  echo "${STD_ASYNC_API_PREFIX} status=${status} check=${check_ok} switch=${switch_ok} imp=${imp_ok} drain=${drain_ok} coop=${coop_ok} skip=${skip}"
}
