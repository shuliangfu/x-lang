#!/usr/bin/env bash
# std-crypto.sh — STD-006 共享：std.crypto / std.random 烟测辅助
#
# 用法（source 后）：
#   std_crypto_has_api MOD_SU fn_name
#   std_crypto_run_smoke SHUX_BIN smoke_su [tag]
#   std_crypto_run_hook SHUX_BIN tests/run-*.sh

# 检查 mod.sx 是否导出指定函数。
std_crypto_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# 编译并运行烟测 .sx；期望退出码 0。
std_crypto_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_crypto_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-crypto FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    "$shux" -L . "$src" -o "$exe" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  local ec=0
  "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-crypto FAIL: $tag exit=$ec ($src)" >&2
    return 1
  fi
  return 0
}

# 运行 hook 脚本（run-crypto.sh / run-random.sh）。
std_crypto_run_hook() {
  local shux="$1"
  local hook="$2"
  if [ ! -f "$hook" ]; then
    echo "std-crypto FAIL: missing hook $hook" >&2
    return 1
  fi
  chmod +x "$hook" 2>/dev/null || true
  SHUX="$shux" "$hook"
}

# 判断本机能否直接执行给定 shux 二进制。
std_crypto_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# 解析可用 shux；失败返回 1。
std_crypto_resolve_shu() {
  if [ -n "${SHUX:-}" ] && std_crypto_native_shu "$SHUX"; then
    echo "$SHUX"
    return 0
  fi
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if std_crypto_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}
