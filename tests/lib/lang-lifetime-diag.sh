#!/usr/bin/env bash
# lang-lifetime-diag.sh — LANG-008 生命周期诊断共享辅助

# 判断本机能否直接执行给定 shu 二进制。
lang_lifetime_diag_native_shu() {
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

# 校验 typeck 输出含子串且 at line:col（line 为 1-based 源行）。
lang_lifetime_diag_expect_at_line() {
  local err_text="$1"
  local substr="$2"
  local want_line="$3"
  if ! echo "$err_text" | grep -qF "$substr"; then
    echo "lang-lifetime-diag FAIL: missing substr '$substr'" >&2
    return 1
  fi
  if ! echo "$err_text" | grep -qE "at ${want_line}:[0-9]+"; then
    echo "lang-lifetime-diag FAIL: missing at ${want_line}:col for '$substr'" >&2
    echo "$err_text" >&2
    return 1
  fi
  return 0
}
