#!/usr/bin/env bash
# 文件职责：按需构建 std 下由 C 实现的 .o，供 asm/-o 链接解析 mod.sx 中的 extern（如 std.csv.next_field）。
# bootstrap-driver-seed 仅链 io/fs/heap，不构建全量 STD_AND_PANIC_O；依赖本脚本的 run-*.sh 须先 ensure。
# 用法：. "$(dirname "$0")/lib/build-std-c-o.sh" && ensure_std_c_o ../std/csv/csv.o

ensure_std_c_o() {
  local rel="$1"
  if [ -z "$rel" ]; then
    echo "ensure_std_c_o: missing path (e.g. ../std/csv/csv.o)" >&2
    return 1
  fi
  make -C compiler -q "$rel" 2>/dev/null || make -C compiler "$rel"
}
