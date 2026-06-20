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
  # make -C compiler 使用 compiler/ 为 cwd 的相对路径；gate 从仓库根 source 时传入 ../std/...。
  local make_rel="$rel"
  local repo_rel="$rel"
  case "$rel" in
    ../std/*) repo_rel="${rel#../}" ;;
  esac
  # STD-139 stub 会覆盖 std/db/sqlite/sqlite.o；后续 gate 须恢复 SQLite3 后端。
  case "$repo_rel" in
    std/db/sqlite/sqlite.o)
      make_rel="../std/db/sqlite/sqlite.o"
      if [ -f "$repo_rel" ] && strings "$repo_rel" 2>/dev/null | grep -qF 'stub backend'; then
        rm -f "$repo_rel"
      fi
      ;;
  esac
  make -C compiler -q "$make_rel" 2>/dev/null || make -C compiler "$make_rel"
}
