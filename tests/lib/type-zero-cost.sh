#!/usr/bin/env bash
# type-zero-cost.sh — TYPE-005 zero-cost abstraction shared helpers.
#
# Honesty (2026-08-28): fossil bench/{loop_i32,mem_copy,struct_param,call_boundary}.x
# retired — live = r01_/m03_/r10_/a01_*. Prefer product native via dod_native_exe
# when available; keep type_zero_cost_native_xlang for callers that have not yet
# sourced dod-native-exe.sh.
# PLATFORM: SHARED archaeology.

# Return 0 if path is a native executable for this host (Mach-O/ELF match).
type_zero_cost_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# Map fossil bench basenames to live r01_/m03_/r10_/a01_ names.
# PLATFORM: SHARED — same rename as codegen-regression honesty.
type_zero_cost_live_bench_name() {
  local file="$1"
  case "$file" in
    loop_i32.x) echo "r01_loop_i32.x" ;;
    mem_copy.x) echo "m03_mem_copy.x" ;;
    struct_param.x) echo "r10_struct_param.x" ;;
    call_boundary.x) echo "a01_call_boundary.x" ;;
    *) echo "$file" ;;
  esac
}

# Resolve bench matrix .x path (bench/ or tests/typeck/linear/).
# Accepts live names or fossils; never invents missing files.
type_zero_cost_bench_x() {
  local file="$1"
  local live
  live=$(type_zero_cost_live_bench_name "$file")
  if [ -f "bench/${live}" ]; then
    echo "bench/${live}"
  elif [ -f "bench/${file}" ]; then
    echo "bench/${file}"
  elif [ -f "tests/typeck/linear/${file}" ]; then
    echo "tests/typeck/linear/${file}"
  elif [ -f "tests/typeck/linear/${live}" ]; then
    echo "tests/typeck/linear/${live}"
  else
    return 1
  fi
}
