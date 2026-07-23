#!/usr/bin/env bash
# collection-asm-gcc-link.sh — xlang_asm -o 失败时用 gcc 手动链 set/heap/map 烟测
#
# 背景：旧 xlang_asm 内嵌 runtime_link_abi 未按需链 std.set/heap/map；且 Docker gcc 镜像
# 仅提供 /usr/local/bin/gcc。本脚本 emit user.o 后 gcc 链 import_alias .o + runtime 最小集。
#
# 用法（仓库根）：
#   . tests/lib/collection-asm-gcc-link.sh
#   collection_asm_gcc_link ./compiler/xlang_asm tests/set/main.x /tmp/xlang_set set

# shellcheck source=tests/lib/build-std-c-o.sh
. "$(dirname "${BASH_SOURCE[0]:-$0}")/build-std-c-o.sh"

# 用 xlang_asm emit 用户 .o（-o *.o 只生成对象，不触发旧 link_abi 缺陷路径）。
collection_asm_emit_user_o() {
  local link_xlang="$1"
  local x="$2"
  local user_o="$3"
  "$link_xlang" -L . "$x" -o "$user_o"
}

# 确保 set/heap/map bootstrap .o 已构建。
collection_ensure_std_objs() {
  local kind="$1"
  case "$kind" in
    set)
      make -C compiler -q ../std/heap/heap.o ../std/heap/page_mmap.o ../std/set/set.o 2>/dev/null \
        || make -C compiler ../std/heap/heap.o ../std/heap/page_mmap.o ../std/set/set.o
      ;;
    heap)
      make -C compiler -q ../std/heap/heap.o ../std/heap/page_mmap.o 2>/dev/null \
        || make -C compiler ../std/heap/heap.o ../std/heap/page_mmap.o
      ;;
    map)
      # map.o → heap；heap.o → page_mmap + process_xlang_*（与 run-map/run-heap 一致）
      make -C compiler -q ../std/map/map.o ../std/heap/heap.o ../std/heap/page_mmap.o 2>/dev/null \
        || make -C compiler ../std/map/map.o ../std/heap/heap.o ../std/heap/page_mmap.o
      ;;
    *)
      echo "collection_asm_gcc_link: unknown kind $kind" >&2
      return 1
      ;;
  esac
}

# gcc -fPIE 链 collection 烟测可执行文件。
collection_asm_gcc_link() {
  local link_xlang="$1"
  local x="$2"
  local exe="$3"
  local kind="$4"
  local user_o="${5:-/tmp/xlang_collection_user.$$.o}"
  local gcc_bin="${XLANG_COLLECTION_GCC:-gcc}"
  local extra_objs=()

  collection_ensure_std_objs "$kind"
  ensure_runtime_panic_o
  ensure_runtime_process_argv_o

  collection_asm_emit_user_o "$link_xlang" "$x" "$user_o"

  case "$kind" in
    set)
      extra_objs=(std/heap/heap.o std/heap/page_mmap.o std/set/set.o core/mem/mem.o)
      ;;
    heap)
      extra_objs=(std/heap/heap.o std/heap/page_mmap.o core/mem/mem.o)
      ;;
    map)
      extra_objs=(std/map/map.o std/heap/heap.o std/heap/page_mmap.o core/mem/mem.o)
      ;;
  esac

  "$gcc_bin" -fPIE -o "$exe" "$user_o" \
    "${extra_objs[@]}" \
    compiler/runtime_panic.o \
    compiler/runtime_process_argv.o \
    -lc
}

# xlang_asm -o 直链失败时回退 gcc；其它链接器走原 -o。
collection_link_exe() {
  local link_xlang="$1"
  local x="$2"
  local exe="$3"
  local kind="$4"
  local errf="/tmp/xlang_collection_link_err.$$"

  if "$link_xlang" -L . "$x" -o "$exe" 2>"$errf"; then
    rm -f "$errf"
    return 0
  fi
  if [ "$(basename "$link_xlang")" = "xlang_asm" ]; then
    echo "collection: $link_xlang -o failed, fallback collection_asm_gcc_link ($kind)" >&2
    cat "$errf" >&2 || true
    rm -f "$errf"
    collection_asm_gcc_link "$link_xlang" "$x" "$exe" "$kind"
    return $?
  fi
  cat "$errf" >&2
  rm -f "$errf"
  return 1
}
