#!/usr/bin/env bash
# comp-win-backend.sh — COMP-011 Windows 目标后端共享辅助
#
# MSYS 探测、native shux、COFF 对象粗校验。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WIN_TRIPLE="${SHUX_WIN_TARGET:-x86_64-pc-windows-msvc}"

# 是否 Windows MSYS/MINGW 环境（可 link+run）。
comp_win_backend_is_msys() {
  if [ -n "${MSYSTEM:-}" ]; then
    return 0
  fi
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
  esac
  return 1
}

# 本机可执行的 shux（与 asm 烟测一致）。
comp_win_backend_native_shu() {
  local f="${1:-./compiler/shux}"
  [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# 探测 shux 是否支持 -backend asm -target Windows MSVC（C-only seed 返回 not available）。
comp_win_backend_asm_capable() {
  local shux="$1"
  local sample="${2:-$ROOT/tests/asm/windows_min.sx}"
  local err=""
  [ -x "$shux" ] && [ -f "$sample" ] || return 1
  err="$("$shux" -backend asm -target "$WIN_TRIPLE" "$sample" 2>&1 >/dev/null || true)"
  if echo "$err" | grep -qi 'not available'; then
    return 1
  fi
  if "$shux" -backend asm -target "$WIN_TRIPLE" "$sample" >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

# 选择首个 native 且 asm-capable 的 shux；无则返回 1。
comp_win_backend_pick_shux() {
  local cand
  for cand in ./compiler/shux_asm ./compiler/shux_asm.strict ./compiler/shux_asm.experimental \
              ./compiler/shux ./compiler/shux-c; do
    if comp_win_backend_native_shu "$cand" && comp_win_backend_asm_capable "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

# 粗判 COFF/PE 对象（file 或 x86_64 machine 0x8664 头）。
comp_win_backend_is_coff_obj() {
  local f="$1"
  [ -f "$f" ] && [ -s "$f" ] || return 1
  if command -v file >/dev/null 2>&1; then
    if file "$f" 2>/dev/null | grep -qiE 'COFF|PE32|MSVC|x86-64'; then
      return 0
    fi
  fi
  # MSVC x64 .obj：machine 0x8664（小端 64 86）
  local b0 b1
  b0="$(od -An -tx1 -N1 "$f" 2>/dev/null | tr -d ' ' || true)"
  b1="$(od -An -tx1 -j1 -N1 "$f" 2>/dev/null | tr -d ' ' || true)"
  if [ "$b0" = "64" ] && [ "$b1" = "86" ]; then
    return 0
  fi
  return 1
}

# 编译 Windows COFF .obj；成功时 echo 输出路径。
comp_win_backend_emit_coff() {
  local shux="$1"
  local sx="$2"
  local out="$3"
  rm -f "$out" 2>/dev/null || true
  if ! "$shux" -backend asm -target "$WIN_TRIPLE" -o "$out" "$sx" 2>/dev/null; then
    return 1
  fi
  if ! comp_win_backend_is_coff_obj "$out"; then
    return 1
  fi
  echo "$out"
}
