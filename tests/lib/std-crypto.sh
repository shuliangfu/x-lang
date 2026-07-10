#!/usr/bin/env bash
# std-crypto.sh — STD-006 共享：std.crypto / std.random 烟测辅助
#
# 用法（source 后）：
#   std_crypto_has_api MOD_X fn_name
#   std_crypto_run_smoke SHUX_BIN smoke_x [tag]
#   std_crypto_run_hook SHUX_BIN tests/run-*.sh

# 检查 mod.x 是否导出指定函数。
std_crypto_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# 编译并运行烟测 .x；期望退出码 0。
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

# crypto.o 是否含 core.x 链入符号（无 shux-c 时仅 glue）。
std_crypto_o_has_x_symbols() {
  local o="$1"
  nm "$o" 2>/dev/null | grep -qE ' crypto_(mem_eq_c|sha256_c|hmac_sha256_c)$'
}

# manifest mod_path → 实际源文件（sha256 在 .x，sha512/AEAD 在 runtime glue）。
std_crypto_resolve_impl_path() {
  local mod_path="$1"
  case "$mod_path" in
    std/crypto/crypto.c|std/crypto/core.x) echo "std/crypto/core.x" ;;
    std/crypto/crypto_inc_glue.c|compiler/src/asm/runtime_crypto_inc_glue.c)
      echo "compiler/src/asm/runtime_crypto_inc_glue.c"
      ;;
    std/crypto/ed25519.x|std/crypto/ed25519.inc.c|std/crypto/aes_gcm.x|std/crypto/chacha20_poly1305.x)
      echo "std/crypto/$(basename "$mod_path")"
      ;;
    std/crypto/ed25519_ref10_glue.c|compiler/src/asm/runtime_ed25519_ref10_glue.inc)
      echo "compiler/src/asm/runtime_ed25519_ref10_glue.inc"
      ;;
    *) echo "$mod_path" ;;
  esac
}

# F-ZC：crypto C smoke 须链 crypto.o + runtime 胶层（ref10 须在 inc 前）。
std_crypto_c_link_objs() {
  echo "std/crypto/crypto.o compiler/runtime_ed25519_ref10_glue.o compiler/runtime_crypto_inc_glue.o"
}

# 确保 crypto runtime 胶层 .o 已编译。
std_crypto_ensure_runtime_glue_o() {
  # shellcheck source=tests/lib/build-std-c-o.sh
  . "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/build-std-c-o.sh"
  ensure_runtime_ed25519_ref10_glue_o
  ensure_runtime_crypto_inc_glue_o
}
