#!/usr/bin/env bash
# std-backtrace-symbolicate.sh — STD-052 manifest 与烟测辅助

STD_BACKTRACE_SYM_PREFIX="${SHUX_STD_BACKTRACE_SYM_PREFIX:-shux: [SHUX_STD_BACKTRACE_SYM]}"

# 探测宿主是否支持 execinfo/backtrace（Alpine/musl 无 glibc execinfo）。
std_backtrace_sym_gold_supported() {
  local probe="/tmp/shux_bt_probe_$$"
  if ! cc -std=c11 -x c - -o "$probe" 2>/dev/null <<'EOF'
#if (defined(__linux__) && defined(__GLIBC__)) || defined(__APPLE__)
#include <execinfo.h>
int main(void) { void *a[4]; return backtrace(a, 4) >= 0 ? 0 : 1; }
#else
int main(void) { return 2; }
#endif
EOF
  then
    rm -f "$probe"
    return 1
  fi
  set +e
  "$probe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$probe"
  [ "$ec" -eq 0 ]
}

# 遍历 manifest TSV，校验 api/const/symbol/file/smoke 锚点。
std_backtrace_sym_symbols_ok() {
  local mod_x="$1"
  local bt_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-backtrace-symbolicate FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
          echo "std-backtrace-symbolicate FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ -z "$path" ] || [ "$path" = "std/backtrace/backtrace_platform_glue.c" ] || [ "$path" = "compiler/src/asm/runtime_backtrace_platform.inc" ]; then
          path="$bt_c"
        fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-backtrace-symbolicate FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-backtrace-symbolicate FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .x 烟测。
std_backtrace_sym_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_backtrace_sym_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-backtrace-symbolicate FAIL: compile $src" >&2
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
    echo "std-backtrace-symbolicate FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# C 金样烟测：-g -rdynamic（Linux）链接 backtrace.o + runtime_backtrace_platform.o。
std_backtrace_sym_run_c_gold() {
  local bt_platform_c="$1"
  local src="tests/backtrace/symbolicate_gold.c"
  local out="/tmp/shux_backtrace_sym_gold_$$"
  local bt_o="std/backtrace/backtrace.o"
  local rt_o="compiler/runtime_backtrace_platform.o"
  if [ ! -f "$bt_o" ]; then
    echo "std-backtrace-symbolicate FAIL: missing $bt_o" >&2
    return 1
  fi
  if [ ! -f "$rt_o" ]; then
    make -C compiler -q runtime_backtrace_platform.o 2>/dev/null || make -C compiler runtime_backtrace_platform.o >/dev/null 2>&1 || true
  fi
  if [ ! -f "$rt_o" ]; then
    echo "std-backtrace-symbolicate FAIL: missing $rt_o" >&2
    return 1
  fi
  local extra=()
  case "$(uname -s)" in
    Linux) extra=(-rdynamic -ldl) ;;
    Darwin) extra=(-Wl,-export_dynamic) ;;
    MINGW*|MSYS*|CYGWIN*) extra=(-ldbghelp) ;;
  esac
  if ! cc -std=c11 -g -O0 -fno-omit-frame-pointer -o "$out" "$src" "$bt_o" "$rt_o" "${extra[@]}" 2>/dev/null; then
    echo "std-backtrace-symbolicate FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-backtrace-symbolicate FAIL: gold smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告行。
std_backtrace_sym_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  local host="$5"
  echo "${STD_BACKTRACE_SYM_PREFIX} status=${status} c_gold=${c_ok} x=${su_ok} skip=${skip} host=${host}"
}
