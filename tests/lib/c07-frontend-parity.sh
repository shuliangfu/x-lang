#!/usr/bin/env bash
# C-07 前端 parity 辅助：shux-c（C 前端 REF）vs shux/shux_asm（.sx 前端 CAND）同输入比对。
#
# 用法：source tests/lib/c07-frontend-parity.sh

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "${BASH_SOURCE[0]:-$0}")/ci-host.sh"

# 判断可执行文件是否可在当前宿主运行（Mach-O/ELF 架构匹配）。
# 参数：$1 = 编译器二进制路径；返回 0 可运行，1 不可。
c07_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(ci_host_os)-$(ci_host_arch)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# 解析 REF/CAND 编译器路径；CAND 优先 shux_asm → shux。
# 设置 C07_REF / C07_CAND；缺 REF 返回 1，缺 CAND 返回 2。
c07_resolve_compilers() {
  C07_REF="${C07_REF:-./compiler/shux-c}"
  if [ -z "${C07_CAND:-}" ]; then
    for cand in ./compiler/shux_asm ./compiler/shux; do
      if c07_native_shu "$cand"; then
        C07_CAND="$cand"
        break
      fi
    done
  fi
  if ! c07_native_shu "$C07_REF"; then
    return 1
  fi
  if [ -z "${C07_CAND:-}" ] || ! c07_native_shu "$C07_CAND"; then
    return 2
  fi
  return 0
}

# typeck-only 编译（无 -o）：CAND 加 -backend c 与 shux-c 路径对齐。
# 参数：$1=编译器 $2=源码 $3=日志文件；返回编译器退出码。
c07_typeck_sx() {
  local bin="$1" src="$2" log="$3"
  local args=(-L .)
  if [ "${bin##*/}" != "shux-c" ]; then
    args+=(-backend c)
  fi
  "$bin" "${args[@]}" "$src" >"$log" 2>&1
}

# 编译并链接 -o（可选 run parity；需 liburing 等完整链接环境）。
# 参数：$1=编译器 $2=源码 $3=输出可执行文件 $4=日志文件；返回编译器退出码。
c07_compile_sx() {
  local bin="$1" src="$2" out="$3" log="$4"
  local args=(-L .)
  if [ "${bin##*/}" != "shux-c" ]; then
    args+=(-backend c)
  fi
  rm -f "$out" 2>/dev/null || true
  "$bin" "${args[@]}" "$src" -o "$out" >"$log" 2>&1
}

# 运行可执行文件并 echo 进程退出码（0～255）。
# 参数：$1=可执行文件路径。
c07_run_exit() {
  local exe="$1"
  local rc=0
  "$exe" >/dev/null 2>&1 || rc=$?
  echo "$rc"
}

# 日志是否含 typeck OK（shux-c / shux 成功路径常见输出）。
# 参数：$1=日志文件。
c07_log_typeck_ok() {
  grep -q 'typeck OK' "$1" 2>/dev/null
}

# 日志是否含 typeck error（负例路径）。
# 参数：$1=日志文件。
c07_log_typeck_error() {
  grep -q 'typeck error' "$1" 2>/dev/null
}
