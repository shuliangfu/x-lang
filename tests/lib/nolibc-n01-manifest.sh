#!/usr/bin/env bash
# nolibc-n01-manifest.sh — NL-01 准备层 manifest 审计（F-no-libc）。
#
# 用法（source）：
#   . tests/lib/nolibc-n01-manifest.sh
#   nolibc_n01_audit_manifest tests/baseline/nolibc-n01-preparation.tsv || exit 1

# P0 syscall 符号须在 freestanding_io_x86_64.s 中存在。
NOLIBC_N01_P0_SYSCALLS="xlang_sys_write xlang_sys_read xlang_sys_open xlang_sys_close xlang_sys_exit xlang_sys_mmap xlang_sys_munmap xlang_sys_openat"

# NL-02 socket syscall 符号。
NOLIBC_N01_SOCKET_SYSCALLS="xlang_sys_socket xlang_sys_connect xlang_sys_bind xlang_sys_listen xlang_sys_accept"

# 审计 freestanding_io .s 是否包含给定符号列表（空格分隔）。
nolibc_n01_audit_asm_syms() {
  local asm_file="${1:-compiler/src/asm/freestanding_io_x86_64.s}"
  local syms="$2"
  local sym
  if [ ! -f "$asm_file" ]; then
    echo "nolibc-n01: missing $asm_file" >&2
    return 1
  fi
  for sym in $syms; do
    if ! grep -q "$sym" "$asm_file"; then
      echo "nolibc-n01: $asm_file missing symbol $sym" >&2
      return 1
    fi
  done
  return 0
}

# 审计 NL-01 preparation.tsv：gate_ref / exists / grep / grep_marker。
nolibc_n01_audit_manifest() {
  local manifest="${1:-tests/baseline/nolibc-n01-preparation.tsv}"
  local miss=0
  local item_id category anchor check_type _notes

  if [ ! -f "$manifest" ]; then
    echo "nolibc-n01: missing manifest $manifest" >&2
    return 1
  fi

  while IFS=$'\t' read -r item_id category anchor check_type _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$check_type" in
      gate_ref|exists)
        if [ ! -f "$anchor" ]; then
          echo "nolibc-n01 manifest missing file: $anchor ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      grep)
        if [ ! -f "$anchor" ] || ! grep -q "$_notes" "$anchor" 2>/dev/null; then
          echo "nolibc-n01 manifest grep fail: $anchor need '$_notes' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      grep_marker)
        if [ ! -f "$anchor" ]; then
          echo "nolibc-n01 manifest missing: $anchor" >&2
          miss=$((miss + 1))
        elif ! grep -q 'F-no-libc NL-05 BEGIN' "$anchor" || ! grep -q 'F-no-libc NL-05 END' "$anchor"; then
          echo "nolibc-n01 manifest NL-05 markers missing in $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$manifest"

  if [ "$miss" -gt 0 ]; then
    echo "nolibc-n01: $miss manifest item(s) failed" >&2
    return 1
  fi
  return 0
}

# 审计 linux.x 至少声明 xlang_sys_write extern。
nolibc_n01_audit_sys_linux() {
  local f="${1:-std/sys/linux.x}"
  grep -q 'extern function xlang_sys_write' "$f" || {
    echo "nolibc-n01: $f missing xlang_sys_write extern" >&2
    return 1
  }
  return 0
}
