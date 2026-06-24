#!/usr/bin/env bash
# std-backtrace-xplat.sh — STD-147 manifest 与跨平台质量烟测辅助

STD147_PREFIX="${SHUX_STD147_BACKTRACE_XPLAT_PREFIX:-shux: [SHUX_STD147_BACKTRACE_XPLAT]}"

# 校验 manifest；echo 缺失数。
std_backtrace_xplat_symbols_ok() {
  local bt_c="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$bt_c" 2>/dev/null; then
          echo "std-backtrace-xplat FAIL: missing '$anchor' in $bt_c" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-backtrace-xplat FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$anchor" ]; then
          echo "std-backtrace-xplat FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-backtrace-xplat-v1.md" 2>/dev/null; then
          echo "std-backtrace-xplat FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 读取 TSV 中当前宿主匹配的向量行；echo "min_gold min_resolved min_total"。
std_backtrace_xplat_pick_vector() {
  local tsv="$1"
  local os arch pat
  os="$(uname -s 2>/dev/null || echo Unknown)"
  arch="$(uname -m 2>/dev/null || echo unknown)"
  while IFS=$'\t' read -r _vid pat min_gold min_resolved min_total _notes; do
    [ -z "${pat:-}" ] && continue
    case "$pat" in \#*) continue ;; esac
    case "$os" in
      Darwin)
        if [ "$pat" = "Darwin" ]; then
          echo "$min_gold $min_resolved $min_total"
          return 0
        fi
        ;;
      Linux)
        if [ "$pat" = "Linux" ]; then
          echo "$min_gold $min_resolved $min_total"
          return 0
        fi
        ;;
      MINGW*|MSYS*|CYGWIN*)
        if [[ "$pat" == *MINGW* ]] || [[ "$pat" == *MSYS* ]] || [[ "$pat" == *CYGWIN* ]] || [[ "$pat" == *Windows* ]]; then
          echo "$min_gold $min_resolved $min_total"
          return 0
        fi
        ;;
    esac
  done < "$tsv"
  echo "0 0 0"
  return 1
}

# 编译并运行 xplat_quality.c；校验 stderr 质量行。
std_backtrace_xplat_run_smoke() {
  local bt_platform_c="$1"
  local src="tests/backtrace/xplat_quality.c"
  local out="/tmp/shux_backtrace_xplat_$$"
  local err="/tmp/shux_backtrace_xplat_err_$$.log"
  local bt_o="std/backtrace/backtrace.o"
  local rt_o="compiler/runtime_backtrace_platform.o"
  if [ ! -f "$bt_o" ]; then
    echo "std-backtrace-xplat FAIL: missing $bt_o" >&2
    return 1
  fi
  if [ ! -f "$rt_o" ]; then
    make -C compiler -q runtime_backtrace_platform.o 2>/dev/null || make -C compiler runtime_backtrace_platform.o >/dev/null 2>&1 || true
  fi
  if [ ! -f "$rt_o" ]; then
    echo "std-backtrace-xplat FAIL: missing $rt_o" >&2
    return 1
  fi
  local extra=()
  case "$(uname -s)" in
    Linux) extra=(-rdynamic -ldl) ;;
    Darwin) extra=(-Wl,-export_dynamic) ;;
    MINGW*|MSYS*|CYGWIN*) extra=(-ldbghelp) ;;
  esac
  if ! cc -std=c11 -g -O0 -fno-omit-frame-pointer -o "$out" "$src" "$bt_o" "$rt_o" "${extra[@]}" 2>/dev/null; then
    echo "std-backtrace-xplat FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" 2>"$err"
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-backtrace-xplat FAIL: smoke exit=$ec" >&2
    return 1
  fi
  if ! grep -qF 'shux: [SHUX_BT_XPLAT]' "$err" 2>/dev/null; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-backtrace-xplat FAIL: missing quality line" >&2
    return 1
  fi
  rm -f "$err"
  return 0
}

std_backtrace_xplat_emit_report() {
  local status="$1"
  local qual_ok="$2"
  local skip="$3"
  local host="$4"
  echo "${STD147_PREFIX} status=${status} quality=${qual_ok} skip=${skip} host=${host}"
}
