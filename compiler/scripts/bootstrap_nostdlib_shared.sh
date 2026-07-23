#!/bin/sh
# bootstrap_nostdlib_shared.sh — NL-07 / G-03 nostdlib link policy (single authority)
#
# PLATFORM: LINUX — bootstrap product zero-libc tail for:
#   · build_xlang_asm.sh (crt0 / experimental / strict / driver tails)
#   · g05_relink_env.sh + g05_ensure_relink_prereqs.sh (product default g05 chain)
#
# G.7: one wants_nostdlib + one freestanding_io + one bootstrap_nostdlib_stubs + one weak atoi.
# Do not open a second stub table or a second ALLOW_LIBC policy.
#
# Usage (from compiler/ cwd):
#   . scripts/bootstrap_nostdlib_shared.sh
#   # or:  . "$(dirname "$0")/bootstrap_nostdlib_shared.sh"
#
# ensure_* progress must go to stderr when callers capture stdout for link lines.

# NL-07 v5: Linux x86_64 defaults to nostdlib unless XLANG_BOOTSTRAP_ALLOW_LIBC=1.
# Explicit XLANG_BOOTSTRAP_NOSTDLIB=1 still forces try on non-x86_64 Linux.
bootstrap_wants_nostdlib() {
  if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
    return 1
  fi
  if [ -n "${XLANG_BOOTSTRAP_ALLOW_LIBC:-}" ]; then
    return 1
  fi
  if [ -n "${XLANG_BOOTSTRAP_NOSTDLIB:-}" ]; then
    return 0
  fi
  if [ "$(uname -m 2>/dev/null)" = "x86_64" ] || [ "$(uname -m 2>/dev/null)" = "amd64" ]; then
    return 0
  fi
  return 1
}

# PLATFORM: LINUX — freestanding syscall face (xlang_sys_*); not a second libc stub table.
ensure_freestanding_io_x86_64_obj() {
  _cc="${CC:-cc}"
  if [ -f src/asm/freestanding_io_x86_64.s ]; then
    if [ ! -f src/asm/freestanding_io_x86_64.o ] || [ src/asm/freestanding_io_x86_64.s -nt src/asm/freestanding_io_x86_64.o ]; then
      echo " cc -c src/asm/freestanding_io_x86_64.o <- src/asm/freestanding_io_x86_64.s" >&2
      "$_cc" -c -o src/asm/freestanding_io_x86_64.o src/asm/freestanding_io_x86_64.s
    fi
  fi
}

# PLATFORM: LINUX — POSIX/stdio face stubs for nostdlib (G.7 authority = this seed only).
ensure_bootstrap_nostdlib_stubs_obj() {
  if [ -f seeds/bootstrap_nostdlib_stubs.from_x.c ]; then
    if [ ! -f src/asm/bootstrap_nostdlib_stubs.o ] || [ seeds/bootstrap_nostdlib_stubs.from_x.c -nt src/asm/bootstrap_nostdlib_stubs.o ]; then
      echo " cc -c src/asm/bootstrap_nostdlib_stubs.o <- seeds/bootstrap_nostdlib_stubs.from_x.c" >&2
      sh scripts/cc_inc_tu.sh seeds/bootstrap_nostdlib_stubs.from_x.c src/asm/bootstrap_nostdlib_stubs.o
    fi
  fi
}

# PLATFORM: LINUX — weak atoi for generated pipeline (libc face without -lc).
# G.7: single TU atoi_stub.o. Skip link if runtime_panic.o already has strong T atoi.
# Sets CRT0_ATOI_LINK to "atoi_stub.o" or "" (also echoes that value on stdout for capture).
ensure_atoi_stub_obj() {
  _cc="${CC:-cc}"
  _cflags="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}"
  # Always rebuild weak atoi (cheap; avoids stale strong multi-def).
  echo " cc -c atoi_stub.o (weak atoi for nostdlib link)" >&2
  _tmp="/tmp/atoi_stub_$$.c"
  printf '%s\n' \
    '#include <stddef.h>' \
    '__attribute__((weak)) int atoi(const char *n) { int v=0; if(!n) return 0; while(*n>=48&&*n<=57){v=v*10+(*n-48);n++;} return v; }' \
    > "$_tmp"
  # shellcheck disable=SC2086
  "$_cc" $_cflags -c -o atoi_stub.o "$_tmp"
  rm -f "$_tmp"
  CRT0_ATOI_LINK=""
  if [ -f atoi_stub.o ]; then
    if [ -f runtime_panic.o ] && nm runtime_panic.o 2>/dev/null | grep -q ' T atoi$'; then
      CRT0_ATOI_LINK=""
    else
      CRT0_ATOI_LINK="atoi_stub.o"
    fi
  fi
  echo "$CRT0_ATOI_LINK"
}

# PLATFORM: LINUX — flags for final product link when nostdlib (stdout pure).
bootstrap_nostdlib_link_flags() {
  if bootstrap_wants_nostdlib; then
    echo "-nostdlib -static -Wl,--gc-sections"
  fi
}

# PLATFORM: LINUX — extra .o for nostdlib final link (stdout pure; ensure to stderr).
# Call ensure first from prereq scripts so missing .o does not fail later.
bootstrap_nostdlib_extra_objs() {
  if ! bootstrap_wants_nostdlib; then
    return 0
  fi
  ensure_freestanding_io_x86_64_obj
  ensure_bootstrap_nostdlib_stubs_obj
  _atoi="$(ensure_atoi_stub_obj)"
  _extra="src/asm/freestanding_io_x86_64.o src/asm/bootstrap_nostdlib_stubs.o"
  if [ -n "$_atoi" ]; then
    _extra="$_extra $_atoi"
  fi
  echo "$_extra"
}
