#!/usr/bin/env bash
# net-asm-gcc-link.sh — shux_asm -o 失败时用 gcc 手动链 net 测试可执行文件
#
# 背景：旧 shux_asm 内嵌 runtime_link_abi 可能未按需链 net.o；本脚本 emit user.o 后
# 按 boot-std-link-contract 补齐 net/thread/runtime glue，供 run-net.sh 回退。
#
# 用法（仓库根）：
#   . tests/lib/net-asm-gcc-link.sh
#   net_asm_gcc_link tests/net/main.x /tmp/shux_net

# shellcheck source=tests/lib/build-std-c-o.sh
. "$(dirname "${BASH_SOURCE[0]:-$0}")/build-std-c-o.sh"

# 用 shux_asm emit 用户 .o（-o *.o 只生成对象，不触发旧 link_abi 缺陷路径）。
net_asm_emit_user_o() {
  local link_shux="$1"
  local x="$2"
  local user_o="$3"
  "$link_shux" -L . "$x" -o "$user_o"
}

# gcc -fPIE 链 net 烟测可执行文件；依赖 run-net.sh 已 ensure 的 std/runtime .o。
net_asm_gcc_link() {
  local link_shux="$1"
  local x="$2"
  local exe="$3"
  local user_o="${4:-/tmp/shux_net_user.$$.o}"
  local gcc_bin="${SHUX_NET_GCC:-gcc}"
  ensure_runtime_thread_glue_o
  net_asm_emit_user_o "$link_shux" "$x" "$user_o"
  "$gcc_bin" -fPIE -o "$exe" "$user_o" \
    std/net/net.o std/thread/thread.o \
    compiler/runtime_asm_io_stubs.o \
    compiler/runtime_net_udp_batch.o \
    compiler/runtime_net_workers.o \
    compiler/runtime_thread_glue.o \
    compiler/runtime_panic.o \
    compiler/runtime_process_argv.o \
    -pthread -lc
}
