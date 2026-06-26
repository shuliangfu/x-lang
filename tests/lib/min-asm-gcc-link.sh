#!/usr/bin/env bash
# min-asm-gcc-link.sh — 最小 user.o emit 后 gcc 链（Docker gcc 镜像 / 旧 link_abi 回退）
#
# 用于 i64-ctfe、bootstrap-min 等单文件烟测；与 collection-asm-gcc-link 同类但无 std 模块依赖。
#
# 用法（仓库根）：
#   . tests/lib/min-asm-gcc-link.sh
#   min_asm_gcc_link ./compiler/shux_asm tests/typeck/ctfe/i64_min_not_zero.sx /tmp/i64_exe

# shellcheck source=tests/lib/build-std-c-o.sh
. "$(dirname "${BASH_SOURCE[0]}")/build-std-c-o.sh"

# 解析 gcc 可执行路径（Docker gcc 镜像优先 /usr/local/bin/gcc）。
min_asm_pick_gcc() {
  if [ -n "${SHUX_MIN_GCC:-}" ]; then
    echo "$SHUX_MIN_GCC"
    return 0
  fi
  if [ -x /usr/local/bin/gcc ]; then
    echo /usr/local/bin/gcc
    return 0
  fi
  if [ -x /usr/bin/gcc ]; then
    echo /usr/bin/gcc
    return 0
  fi
  echo gcc
}

# 用 link_shux emit 用户 .o；透传 SHUX_LINK_BACKEND_ARGS（shux-c 须 -backend asm）。
min_asm_emit_user_o() {
  local link_shux="$1"
  local sx="$2"
  local user_o="$3"
  # shellcheck disable=SC2086
  "$link_shux" ${SHUX_LINK_BACKEND_ARGS:-} -L . "$sx" -o "$user_o"
}

# gcc -fPIE 链最小 runtime + 可选 base64/encoding（link_abi minimal 路径对齐）。
min_asm_gcc_link() {
  local link_shux="$1"
  local sx="$2"
  local exe="$3"
  local user_o="${4:-/tmp/shux_min_user.$$.o}"
  local gcc_bin
  gcc_bin="$(min_asm_pick_gcc)"
  local extra=()

  ensure_runtime_panic_o
  ensure_runtime_process_argv_o
  min_asm_emit_user_o "$link_shux" "$sx" "$user_o"
  if [ ! -s "$user_o" ]; then
    echo "min_asm_gcc_link: empty user.o from $link_shux" >&2
    return 1
  fi

  if [ -f std/base64/base64.o ]; then
    extra+=(std/base64/base64.o)
  fi
  if [ -f std/encoding/encoding.o ]; then
    extra+=(std/encoding/encoding.o)
  fi
  # std.io 烟测才链 io 桩；须容器内 -B 重编 -fPIE（避免 macOS 挂载 .o 与 -fPIE 链冲突）。
  if [ -n "${SHUX_MIN_LINK_IO:-}" ]; then
    make -C compiler -B runtime_asm_io_stubs.o
    extra+=(compiler/runtime_asm_io_stubs.o)
  fi

  "$gcc_bin" -fPIE -o "$exe" "$user_o" \
    compiler/runtime_panic.o \
    compiler/runtime_process_argv.o \
    "${extra[@]}" \
    -lc
}

# shux_asm -o 直链失败时回退 gcc（单文件简写）。
min_link_exe() {
  local link_shux="$1"
  local sx="$2"
  local exe="$3"
  # shellcheck disable=SC2086
  min_link_exe_args "$link_shux" ${SHUX_LINK_BACKEND_ARGS:-} -L . "$sx" -o "$exe"
}

# 保留完整 argv（-L / -backend 等）尝试直链；失败时对 shux/shux_asm/shux-c 回退 gcc。
min_link_exe_args() {
  local link_shux="$1"
  shift
  local errf="/tmp/shux_min_link_err.$$"
  local sx=""
  local exe=""
  local args=("$@")
  local arg i

  for ((i = 0; i < ${#args[@]}; i++)); do
    arg="${args[$i]}"
    if [ "$arg" = "-o" ] && [ $((i + 1)) -lt ${#args[@]} ]; then
      exe="${args[$((i + 1))]}"
    fi
    if [[ "$arg" == *.sx ]] && [ -z "$sx" ]; then
      sx="$arg"
    fi
  done

  if [ -z "$sx" ] || [ -z "$exe" ]; then
    echo "min_link_exe_args: missing .sx or -o exe in argv" >&2
    return 1
  fi

  if "$link_shux" "${args[@]}" 2>"$errf"; then
    rm -f "$errf"
    return 0
  fi

  if case "$(basename "$link_shux")" in shux_asm|shux|shux-c|shux_asm2|shux_asm_stage1) true ;; *) false ;; esac; then
    echo "min: $link_shux -o failed, fallback min_asm_gcc_link ($sx -> $exe)" >&2
    cat "$errf" >&2 || true
    rm -f "$errf"
    min_asm_gcc_link "$link_shux" "$sx" "$exe"
    return $?
  fi

  cat "$errf" >&2
  rm -f "$errf"
  return 1
}
