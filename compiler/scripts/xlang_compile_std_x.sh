#!/bin/sh
# xlang_compile_std_x.sh — compile std/*.x → .o (Makefile std-objs + shell-primary)
#
# PLATFORM: SHARED — host product path for pure .x std leaves (asm prefer, C fallback).
# Authority for host pick + -E/cc / -backend asm; Makefile must only thin-call this script
# (wave811: G.7 有则补全 — no second xlang-pick ladder in Makefile).
#
# Usage (cwd = compiler/):
#   xlang_compile_std_x.sh <xlang-bin|auto|auto-soft|auto-merge|auto-soft-merge> <x-path> <out.o>
#
# Modes:
#   auto              hard-fail if no host; pick xlang_asm → xlang → xlang-c
#   auto-soft         same pick; exit 0 if no host (F-ZC soft leaves)
#   auto-merge        compile to ${out%.o}_main.o then ld -r → out.o (hard)
#   auto-soft-merge   same merge; exit 0 if no host (socketio)
#   <path-to-bin>     use explicit driver
#
# auto: prefer xlang_asm → xlang → xlang-c (lib modules need asm .o; do not prefer xlang-c
# unless XLANG_COMPILE_STD_USE_C=1).
# Wave: pre-811 body in Makefile if-ladder; 811 body fully here (not physical delete).
set -e
xlang_bin="$1"
x_path="$2"
out_o="$3"
if [ -z "$xlang_bin" ] || [ -z "$x_path" ] || [ -z "$out_o" ]; then
  echo "usage: xlang_compile_std_x.sh <xlang|auto|auto-soft|auto-merge|auto-soft-merge> <file.x> <out.o>" >&2
  exit 1
fi

# wave811: mode flags before path normalization.
# PLATFORM: SHARED — soft vs hard is product leaf policy (F-ZC), not OS branch.
_soft=0
_merge=0
case "$xlang_bin" in
  auto-soft-merge)
    _soft=1
    _merge=1
    xlang_bin=auto
    ;;
  auto-merge)
    _merge=1
    xlang_bin=auto
    ;;
  auto-soft)
    _soft=1
    xlang_bin=auto
    ;;
esac

# Final OUT for merge mode; compile may target *_main.o first.
_final_out="$out_o"
if [ "$_merge" = "1" ]; then
  case "$out_o" in
    *.o) _main_o="${out_o%.o}_main.o" ;;
    *)
      echo "xlang_compile_std_x.sh: merge mode needs .o out, got $out_o" >&2
      exit 1
      ;;
  esac
  out_o="$_main_o"
fi

# Makefile runs under compiler/; entry paths must be ../std/... for -L ..
case "$x_path" in
  std/*) x_path="../$x_path" ;;
esac
if [ "$xlang_bin" = "auto" ]; then
  # 【Why 根源】run-all 批量回归时 XLANG_COMPILE_STD_USE_C=1 强制走 xlang-c：
  # xlang_asm/xlang（seed）在 macOS -backend asm 对部分 .x 产出 code_len=0 或语义错误 .o，
  # 且 exit=0 不回退，污染 std/*.o 导致单独通过批量失败。
  # 设此变量后优先 xlang-c，确保 .o 与测试程序同源（都用 C 前端）。
  if [ -n "${XLANG_COMPILE_STD_USE_C:-}" ] && [ -x ./xlang-c ]; then
    xlang_bin=./xlang-c
  elif [ -x ./xlang_asm ]; then
    xlang_bin=./xlang_asm
  elif [ -x ./xlang ]; then
    xlang_bin=./xlang
  elif [ -x ./xlang-c ]; then
    xlang_bin=./xlang-c
  else
    if [ "$_soft" = "1" ]; then
      echo "xlang_compile_std_x.sh: no xlang host; soft-skip ${_final_out} (auto-soft)" >&2
      exit 0
    fi
    echo "xlang_compile_std_x.sh: need xlang_asm, xlang, or xlang-c in compiler/" >&2
    exit 1
  fi
fi
# PLATFORM: SHARED (host -E+cc path; required on MACOS when -backend asm code_len=0)
# rt_preamble injects weak args_iter_* for programs that do not link std.env.
# env.x provides strong #[no_mangle] args_iter_* in the same TU. Clang rejects
# weak+strong redefinition (Linux cold usually stays on asm .o and never hits this).
# Authority: strip only the preamble weak defs when a non-weak def exists in gen.c.
xlang_strip_conflicting_weak_args_iter() {
  _gen="$1"
  [ -f "$_gen" ] || return 0
  if grep -qE '__attribute__\(\(weak\)\).*args_iter_count_c' "$_gen" 2>/dev/null \
    && grep -qE '^int32_t args_iter_count_c\(' "$_gen" 2>/dev/null; then
    sed -e '/__attribute__((weak)) int32_t args_iter_count_c(void)/d' \
        -e '/__attribute__((weak)) uint8_t \*args_iter_at_c(int32_t/d' \
        "$_gen" >"$_gen.strip" && mv "$_gen.strip" "$_gen"
  fi
}

# PLATFORM: MACOS/LINUX — std/net cfg errno bodies call __error / __errno_location.
# Codegen may omit the extern prototype; host-cc then fails (Darwin cold net.o).
# Inject after last #include when the gen C actually references the symbol.
xlang_inject_errno_externs() {
  _gen="$1"
  [ -f "$_gen" ] || return 0
  _need=0
  if grep -qE '__error\s*\(' "$_gen" 2>/dev/null \
    && ! grep -qE 'extern\s+.*\*?\s*__error\s*\(' "$_gen" 2>/dev/null; then
    _need=1
  fi
  if grep -qE '__errno_location\s*\(' "$_gen" 2>/dev/null \
    && ! grep -qE 'extern\s+.*\*?\s*__errno_location\s*\(' "$_gen" 2>/dev/null; then
    _need=1
  fi
  [ "$_need" = "1" ] || return 0
  if grep -q '^#include' "$_gen" 2>/dev/null; then
    last_inc_line=$(grep -n '^#include' "$_gen" | tail -1 | cut -d: -f1)
  else
    last_inc_line=1
  fi
  [ -n "$last_inc_line" ] || last_inc_line=1
  # Portable insert: write block then splice (sed -i a\\ differs BSD/GNU).
  {
    head -n "$last_inc_line" "$_gen"
    echo '/* PLATFORM: injected by xlang_compile_std_x — errno TLS accessors */'
    echo '#if defined(__APPLE__)'
    echo 'extern int *__error(void);'
    echo '#elif defined(__linux__)'
    echo 'extern int *__errno_location(void);'
    echo '#endif'
    tail -n +"$((last_inc_line + 1))" "$_gen"
  } >"$_gen.errno" && mv "$_gen.errno" "$_gen"
}

case "$(basename "$xlang_bin")" in
  xlang-c)
    # -o may use ASM backend which fails on some .x files (pointer arith, arrays).
    # Use -E + cc -c instead for reliable C backend compilation.
    gen_c="$out_o.gen.c"
    "$xlang_bin" -E -L .. "$x_path" > "$gen_c" 2>/dev/null || { rm -f "$gen_c"; exit 1; }
    if grep -q '^#include' "$gen_c" 2>/dev/null; then
      last_inc_line=$(grep -n '^#include' "$gen_c" | tail -1 | cut -d: -f1)
      if [ -n "$last_inc_line" ]; then
        sed -i.bak "${last_inc_line}a\\
#undef htonl\\
#undef htons\\
#undef ntohl\\
#undef ntohs" "$gen_c"
        rm -f "$gen_c.bak"
      fi
    fi
    xlang_strip_conflicting_weak_args_iter "$gen_c"
    xlang_inject_errno_externs "$gen_c"
    cc -Wall -Wextra -I. -Iinclude -Isrc -c -o "$out_o" "$gen_c" || { rm -f "$gen_c"; exit 1; }
    rm -f "$gen_c"
    ;;
  *)
    # 【Why 根源】Darwin 的 bootstrap-driver-seed 使用 asm_backend_partial.o 中的
    # seed_mega 桩（仅 14 个弱符号返回 0），真实 ARM64 指令发射器未被 -E 编入。
    # 因此 -backend asm 在 macOS 上产出 code_len=0，所有 std/*.o 编译失败。
    # 【修复】-backend asm 失败时回退到 xlang-c（-E + cc -c），保证 std .o 可用。
    if env XLANG_ASM_WPO_DCE=0 "$xlang_bin" -backend asm -L .. "$x_path" -o "$out_o" 2>/dev/null; then
      :
    else
      if [ -x ./xlang-c ]; then
        gen_c="$out_o.gen.c"
        ./xlang-c -E -L .. "$x_path" > "$gen_c" || { rm -f "$gen_c"; exit 1; }
        if grep -q '^#include' "$gen_c"; then
          last_inc_line=$(grep -n '^#include' "$gen_c" | tail -1 | cut -d: -f1)
          if [ -n "$last_inc_line" ]; then
            sed -i.bak "${last_inc_line}a\\
#undef htonl\\
#undef htons\\
#undef ntohl\\
#undef ntohs" "$gen_c"
            rm -f "$gen_c.bak"
          fi
        fi
        xlang_strip_conflicting_weak_args_iter "$gen_c"
        xlang_inject_errno_externs "$gen_c"
        cc -Wall -Wextra -I. -Iinclude -Isrc -c -o "$out_o" "$gen_c" || { rm -f "$gen_c"; exit 1; }
        rm -f "$gen_c"
      else
        exit 1
      fi
    fi
    ;;
esac

# wave811: socketio-style single-TU merge — compile landed on *_main.o; ld -r → final OUT.
# PLATFORM: SHARED — host ld -r only (no second Makefile hybrid ladder).
if [ "$_merge" = "1" ]; then
  if [ ! -f "$out_o" ]; then
    echo "xlang_compile_std_x.sh: merge missing intermediate $out_o" >&2
    exit 1
  fi
  ld -r -o "$_final_out" "$out_o" || exit 1
fi
