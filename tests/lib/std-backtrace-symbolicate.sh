#!/usr/bin/env bash
# std-backtrace-symbolicate.sh — STD-052 manifest + smoke helpers
#
# Usage (after source):
#   std_backtrace_sym_symbols_ok MOD_X BT_RUNTIME TSV
#   std_backtrace_sym_run_smoke XLANG_BIN X TAG
#   std_backtrace_sym_run_c_gold BT_RUNTIME
#   std_backtrace_sym_emit_report status check_ok c_ok x_ok skip host
# 2026-08-26: report check=/c_gold=/x=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
STD_BACKTRACE_SYM_PREFIX="${XLANG_STD_BACKTRACE_SYM_PREFIX:-xlang: [XLANG_STD_BACKTRACE_SYM]}"

# Probe whether the host supports execinfo/backtrace (Alpine/musl lacks glibc execinfo).
# PLATFORM: POSIX — Linux glibc + Darwin; musl/Alpine → unsupported.
std_backtrace_sym_gold_supported() {
  local probe="/tmp/xlang_bt_probe_$$"
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

# Walk manifest TSV; validate api/const/symbol/file/smoke anchors.
# Echo miss count; return 0 iff miss==0.
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
        # Fossil path std/backtrace/backtrace.x for smoke_c retired → seed.
        if [ -z "$path" ] \
          || [ "$path" = "std/backtrace/backtrace_platform_glue.c" ] \
          || [ "$path" = "compiler/seeds/runtime_backtrace_platform.from_x.c" ] \
          || [ "$path" = "std/backtrace/backtrace.x" ]; then
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
      section|script|gate|anchor|hook_script|cross_ref)
        # DOC ## 5. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run a smoke .x (backtrace.o / runtime must already be ensured).
# Honors XLANG / XLANG_LINK_XLANG when the caller pinned prefer-asm.
std_backtrace_sym_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_backtrace_sym_${tag}_$$"
  local run_xlang="${XLANG:-$xlang}"
  if [ ! -f "$src" ]; then
    echo "std-backtrace-symbolicate FAIL: missing $src" >&2
    return 1
  fi
  if ! "$run_xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-backtrace-symbolicate FAIL: compile $src" >&2
    "$run_xlang" -L . "$src" 2>&1 | tail -10 >&2 || true
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

# C gold smoke: -g -rdynamic (Linux) link backtrace.o + runtime_backtrace_platform.o
# plus process_argv / link_abi_user_env (crash-evidence + process deps pulled by
# backtrace.o / runtime; fossil symbol_miss used to mask this UNDEF).
# PLATFORM: POSIX — Linux uses -rdynamic -ldl; Darwin -export_dynamic; Windows dbghelp.
std_backtrace_sym_run_c_gold() {
  local bt_platform_c="$1"
  local src="tests/backtrace/symbolicate_gold.c"
  local out="/tmp/xlang_backtrace_sym_gold_$$"
  local bt_o="std/backtrace/backtrace.o"
  local rt_o="compiler/runtime_backtrace_platform.o"
  local argv_o="compiler/runtime_process_argv.o"
  local env_o="compiler/runtime_link_abi_user_env.o"
  if [ ! -f "$bt_o" ]; then
    echo "std-backtrace-symbolicate FAIL: missing $bt_o" >&2
    return 1
  fi
  if [ ! -f "$rt_o" ]; then
    xlang_compiler_make -q runtime_backtrace_platform.o 2>/dev/null || xlang_compiler_make runtime_backtrace_platform.o >/dev/null 2>&1 || true
  fi
  if [ ! -f "$argv_o" ]; then
    xlang_compiler_make -q runtime_process_argv.o 2>/dev/null || xlang_compiler_make runtime_process_argv.o >/dev/null 2>&1 || true
  fi
  if [ ! -f "$env_o" ]; then
    xlang_compiler_make -q runtime_link_abi_user_env.o 2>/dev/null || xlang_compiler_make runtime_link_abi_user_env.o >/dev/null 2>&1 || true
  fi
  if [ ! -f "$rt_o" ] || [ ! -f "$argv_o" ] || [ ! -f "$env_o" ]; then
    echo "std-backtrace-symbolicate FAIL: missing $rt_o / $argv_o / $env_o" >&2
    return 1
  fi
  local extra=()
  case "$(uname -s)" in
    Linux) extra=(-rdynamic -ldl) ;;
    Darwin) extra=(-Wl,-export_dynamic) ;;
    MINGW*|MSYS*|CYGWIN*) extra=(-ldbghelp) ;;
  esac
  if ! cc -std=c11 -g -O0 -fno-omit-frame-pointer -o "$out" \
      "$src" "$bt_o" "$rt_o" "$argv_o" "$env_o" "${extra[@]}" 2>/dev/null; then
    echo "std-backtrace-symbolicate FAIL: compile $src" >&2
    cc -std=c11 -g -O0 -fno-omit-frame-pointer -o "$out" \
      "$src" "$bt_o" "$rt_o" "$argv_o" "$env_o" "${extra[@]}" 2>&1 | tail -15 >&2 || true
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

# Structured report line (honesty: check=/c_gold=/x=/skip=).
# Hard-green signal = x= (+ c_gold= when execinfo supported); check observational.
std_backtrace_sym_emit_report() {
  local status="$1"
  local check_ok="$2"
  local c_ok="$3"
  local su_ok="$4"
  local skip="$5"
  local host="$6"
  echo "${STD_BACKTRACE_SYM_PREFIX} status=${status} check=${check_ok} c_gold=${c_ok} x=${su_ok} skip=${skip} host=${host}"
}
