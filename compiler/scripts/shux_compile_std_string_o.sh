#!/bin/sh
# shux_compile_std_string_o.sh — 构建 std/string/string.o
# 【Why】产品 -x -E 对 string 库模块会截断函数体；-o *.o 路径 emit 完整。
# Arena64 标签双名（heap_libc_Arena64 vs std_heap_libc_LibcArena64）在 cc 前 #define 对齐。
# 用法：在 compiler/ 下：sh scripts/shux_compile_std_string_o.sh
set -e
ROOT="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
COMP="$ROOT/compiler"
OUT="$ROOT/std/string/string.o"
SHUX="${SHUX:-$COMP/shux}"
[ -x "$SHUX" ] || SHUX="$COMP/shux"
[ -x "$SHUX" ] || { echo "no shux" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

# 1) mod.x → C：优先 -x -E（库模块 asm_entry_module_only：仅入口体，dep 为 extern，
#    避免 string.o 内嵌 core_mem_*）。-o KEEP_C 曾 co-emit 整树并引用未声明 heap 全局。
# PLATFORM: SHARED — do not rm global /tmp/shux_shux_x.*.c (races with concurrent -o).
if ! "$SHUX" build -x -E -L "$ROOT" "$ROOT/std/string/mod.x" >"$tmp/mod.c" 2>"$tmp/mod.log"; then
  echo "shux_compile_std_string_o: -x -E mod.x failed" >&2
  cat "$tmp/mod.log" >&2
  exit 1
fi
if [ ! -s "$tmp/mod.c" ]; then
  echo "shux_compile_std_string_o: empty C for mod.x" >&2
  exit 1
fi

# Arena64 + 库 -E 无完整 product preamble 时补 String/StrView（codegen ABI skip 依赖 preamble）
python3 - "$tmp/mod.c" <<'PY'
import sys, re
from pathlib import Path
p = Path(sys.argv[1])
s = p.read_text()
extra = []
if "std_heap_libc_LibcArena64" in s and "heap_libc_Arena64" in s and "#define heap_libc_Arena64" not in s:
    extra.append("#define heap_libc_Arena64 std_heap_libc_LibcArena64\n")
# entry-only 库 -E 跳过 String/StrView 完整体；此处注入权威布局。
# 注意：codegen 可能发 `struct String`（tag）而非 typedef `String`——二者在 C 中不是同一类型。
need_bare_string = "struct String" in s and "struct String {" not in s
need_std_string = "struct std_string_String" in s and "struct std_string_String {" not in s
need_bare_view = "struct StrView" in s and "struct StrView {" not in s
need_std_view = "struct std_string_StrView" in s and "struct std_string_StrView {" not in s
if need_bare_string:
    extra.append("struct String { uint8_t data[256]; int32_t len; };\n")
if need_std_string:
    extra.append("struct std_string_String { uint8_t data[256]; int32_t len; };\n")
if need_bare_view:
    extra.append("struct StrView { uint8_t *ptr; int32_t len; };\n")
if need_std_view:
    extra.append("struct std_string_StrView { uint8_t *ptr; int32_t len; };\n")
# 仅当源用裸标识符 String/StrView（非 struct String）时补 typedef
if re.search(r"\bString\b", s) and "typedef " not in s.split("String")[0][-40:]:
    if "typedef struct String String" not in s and need_bare_string:
        extra.append("typedef struct String String;\n")
    elif need_std_string and "typedef struct std_string_String String" not in s:
        extra.append("typedef struct std_string_String String;\n")
if re.search(r"\bStrView\b", s) and need_bare_view and "typedef struct StrView StrView" not in s:
    extra.append("typedef struct StrView StrView;\n")
elif re.search(r"\bStrView\b", s) and need_std_view and "typedef struct std_string_StrView StrView" not in s:
    extra.append("typedef struct std_string_StrView StrView;\n")
# init_globals 可能引用 dep 全局（heap trace / mem fence）；库 .o 不定义它们 → 补 BSS
if "shu_heap_trace_on" in s and "int32_t shu_heap_trace_on" not in s:
    extra.append(
        "int32_t shu_heap_trace_on;\n"
        "uint64_t shu_heap_trace_alloc_count;\n"
        "uint64_t shu_heap_trace_free_count;\n"
        "uint64_t shu_heap_trace_realloc_count;\n"
        "uint64_t shu_heap_trace_bytes;\n"
        "uint64_t g_mem_fence_seq;\n"
    )
# entry-only 对 heap 有 U 且本 TU 无定义时才补弱桩（勿与 co-emit 的真体重定义）
_has_arena_alloc_def = bool(re.search(
    r"^(uint8_t\s*\*|int32_t|void)\s+std_heap_libc_heap_arena64_alloc_c\s*\(",
    s, re.M))
if ("std_heap_libc_heap_arena64_alloc_c" in s
    and not _has_arena_alloc_def
    and "__attribute__((weak)) uint8_t *std_heap_libc_heap_arena64_alloc_c" not in s):
    extra.append(
        "#ifndef SHUX_STRING_HEAP_WEAK\n"
        "#define SHUX_STRING_HEAP_WEAK\n"
        "struct std_heap_libc_LibcArena64;\n"
        "extern uint8_t *malloc(size_t size);\n"
        "__attribute__((weak)) int32_t std_heap_libc_heap_arena64_init_c(struct std_heap_libc_LibcArena64 *a, size_t cap) {\n"
        "  (void)a; (void)cap; return 0;\n"
        "}\n"
        "__attribute__((weak)) uint8_t *std_heap_libc_heap_arena64_bump_c(struct std_heap_libc_LibcArena64 *a, size_t size, size_t obj_align) {\n"
        "  (void)a; (void)obj_align; return malloc(size ? size : 1);\n"
        "}\n"
        "__attribute__((weak)) uint8_t *std_heap_libc_heap_arena64_alloc_c(struct std_heap_libc_LibcArena64 *a, size_t size, size_t align_bytes) {\n"
        "  (void)a; (void)align_bytes; return malloc(size ? size : 1);\n"
        "}\n"
        "__attribute__((weak)) void std_heap_libc_heap_arena64_deinit_c(struct std_heap_libc_LibcArena64 *a) { (void)a; }\n"
        "#endif\n"
    )
if extra:
    last = None
    for m in re.finditer(r"^#include[^\n]*\n", s, re.M):
        last = m
    block = "".join(extra)
    if last:
        s = s[: last.end()] + block + s[last.end() :]
    else:
        s = block + s
    p.write_text(s)
PY

CFLAGS="-std=gnu11 -fPIE -ffunction-sections -fdata-sections -I$ROOT -I$COMP -I$COMP/include -I$COMP/src -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-sign-compare -Wno-incompatible-pointer-types"
cc $CFLAGS -c "$tmp/mod.c" -o "$tmp/mod.o"

# 2) string.x bare ABI (shux_string_*_c) — 必须裸符号。
# 【Why】产品 shux 为 SHUX_NO_C_FRONTEND 时 -lib-name 未接线（仅 C 前端 RUN_CC 解析），
#   路径前缀会把 shux_string_copy_c 打成 std_string_string_shux_string_copy_c。
# 权威裸实现与 path.o 同策略：seeds/runtime_string_fast.from_x.c（与 string.x 同语义）。
# -lib-name 接线后可改回 shux -lib-name "" string.x。
if [ -f "$COMP/seeds/runtime_string_fast.from_x.c" ]; then
  cc $CFLAGS -c "$COMP/seeds/runtime_string_fast.from_x.c" -o "$tmp/sx.o"
else
  SHUX_KEEP_C=1 "$SHUX" build -L "$ROOT" -lib-name "" -o "$tmp/sx.o" "$ROOT/std/string/string.x" >"$tmp/sx.log" 2>&1 || true
  if [ ! -f "$tmp/sx.o" ]; then
    if "$SHUX" build -x -E -lib-name "" -L "$ROOT" "$ROOT/std/string/string.x" >"$tmp/sx.c" 2>"$tmp/sx.err"; then
      cc $CFLAGS -c "$tmp/sx.c" -o "$tmp/sx.o"
    else
      echo "shux_compile_std_string_o: string.x bare failed (no seed, -lib-name unsupported)" >&2
      cat "$tmp/sx.log" "$tmp/sx.err" 2>/dev/null >&2
      exit 1
    fi
  fi
fi

ld -r -o "$OUT" "$tmp/mod.o" "$tmp/sx.o"
echo "shux_compile_std_string_o: OK -> $OUT"
