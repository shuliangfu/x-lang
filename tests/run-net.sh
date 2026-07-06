#!/usr/bin/env bash
# 测试 std.net 占位：Ipv4Addr、TcpStream、TcpListener、connect、listen、accept；UDP 切片化 udp_recv_many_buf/udp_send_many_buf
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
# B-strict gate 显式 SHUX_LINK_SHUX=shux_asm 时不必构建 shux-c（mac/无 seed 会失败）。
if [ -z "${SHUX_LINK_SHUX:-}" ]; then
  if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
    make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  fi
else
  if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
    make -C compiler -q shux-c 2>/dev/null || true
  fi
fi
ensure_std_c_o ../std/net/net.o
# net.o 合并 workers.x，链入时依赖 thread.o
ensure_std_c_o ../std/thread/thread.o
# Linux UDP batch / accept workers 胶层（net.o 内引用 shu_net_* / thread_create_c）
ensure_runtime_net_udp_batch_o
ensure_runtime_net_workers_o
ensure_runtime_asm_io_stubs_o
ensure_runtime_panic_o
ensure_runtime_process_argv_o
# ws.inc.c 内 shu_ws_fill_random16 依赖 random_fill_bytes_c
ensure_std_c_o ../std/random/random.o
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
# shellcheck source=lib/net-asm-gcc-link.sh
. "$(dirname "$0")/lib/net-asm-gcc-link.sh"
SHUX=${SHUX:-./compiler/shux}
LINK_SHUX="${SHUX_LINK_SHUX:-${RUN_SHUX:-$SHUX}}"

# shux_asm -o 直链失败时（旧 link_abi 未按需链 net.o）回退 gcc 手动链。
net_link_exe() {
  local x="$1"
  local exe="$2"
  local errf="/tmp/shux_net_link_err.$$"
  if "$LINK_SHUX" -L . "$x" -o "$exe" 2>"$errf"; then
    rm -f "$errf"
    return 0
  fi
  if [ "$(basename "$LINK_SHUX")" = "shux_asm" ]; then
    echo "run-net: $LINK_SHUX -o failed, fallback net_asm_gcc_link" >&2
    cat "$errf" >&2 || true
    rm -f "$errf"
    net_asm_gcc_link "$LINK_SHUX" "$x" "$exe"
    return $?
  fi
  cat "$errf" >&2
  rm -f "$errf"
  return 1
}

net_link_exe tests/net/main.x /tmp/shux_net
exitcode=0; /tmp/shux_net >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0, got $exitcode"; exit 1; }

net_link_exe tests/net/udp_batch_buf.x /tmp/shux_net_udp
exitcode=0; /tmp/shux_net_udp >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (udp_recv_many_buf/udp_send_many_buf), got $exitcode"; exit 1; }

echo "net test OK"
