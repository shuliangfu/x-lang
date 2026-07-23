#!/usr/bin/env bash
# vec-asm-gcc-link.sh — xlang_asm -o 失败时用 gcc 手动链 vec 烟测
#
# 背景：旧 xlang_asm 内嵌 runtime_link_abi 直链失败（Docker 仅 /usr/local/bin/gcc）；
# vec_len_empty / vec_placeholder_i32 由 user.o 内联 emit，无需预编 std/vec/vec.o。
#
# 用法（仓库根）：
#   . tests/lib/vec-asm-gcc-link.sh
#   vec_link_exe ./compiler/xlang_asm tests/vec/main.x /tmp/xlang_vec

# shellcheck source=tests/lib/build-std-c-o.sh
. "$(dirname "${BASH_SOURCE[0]:-$0}")/build-std-c-o.sh"

# 用 xlang_asm emit 用户 .o（-o *.o 只生成对象，不触发旧 link_abi 缺陷路径）。
vec_asm_emit_user_o() {
  local link_xlang="$1"
  local x="$2"
  local user_o="$3"
  "$link_xlang" -L . "$x" -o "$user_o"
}

# gcc -fPIE 链 vec 烟测可执行文件。
vec_asm_gcc_link() {
  local link_xlang="$1"
  local x="$2"
  local exe="$3"
  local user_o="${4:-/tmp/xlang_vec_user.$$.o}"
  local gcc_bin="${XLANG_VEC_GCC:-gcc}"

  ensure_runtime_panic_o
  ensure_runtime_process_argv_o
  vec_asm_emit_user_o "$link_xlang" "$x" "$user_o"
  "$gcc_bin" -fPIE -o "$exe" "$user_o" \
    compiler/runtime_panic.o \
    compiler/runtime_process_argv.o \
    -lc
}

# xlang_asm -o 直链失败时回退 gcc；其它链接器走原 -o。
vec_link_exe() {
  local link_xlang="$1"
  local x="$2"
  local exe="$3"
  local errf="/tmp/xlang_vec_link_err.$$"

  if "$link_xlang" -L . "$x" -o "$exe" 2>"$errf"; then
    rm -f "$errf"
    return 0
  fi
  if [ "$(basename "$link_xlang")" = "xlang_asm" ]; then
    echo "vec: $link_xlang -o failed, fallback vec_asm_gcc_link" >&2
    cat "$errf" >&2 || true
    rm -f "$errf"
    vec_asm_gcc_link "$link_xlang" "$x" "$exe"
    return $?
  fi
  cat "$errf" >&2
  rm -f "$errf"
  return 1
}
