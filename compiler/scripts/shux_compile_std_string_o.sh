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

# 1) mod.x → complete C via -o (cc may fail; keep C)
rm -f /tmp/shux_shux_x.*.c 2>/dev/null || true
keep_before=$(ls /tmp/shux_shux_x.*.c 2>/dev/null | wc -l)
SHUX_KEEP_C=1 "$SHUX" -L "$ROOT" -o "$tmp/mod.o" "$ROOT/std/string/mod.x" >"$tmp/mod.log" 2>&1 || true
gen=$(ls -t /tmp/shux_shux_x.*.c 2>/dev/null | head -1)
if [ -z "$gen" ] || [ ! -f "$gen" ]; then
  echo "shux_compile_std_string_o: no kept C for mod.x" >&2
  cat "$tmp/mod.log" >&2
  exit 1
fi
cp "$gen" "$tmp/mod.c"

# Arena64 tag unify + optional incomplete forwards for pointer-only tags
python3 - "$tmp/mod.c" <<'PY'
import sys, re
from pathlib import Path
p = Path(sys.argv[1])
s = p.read_text()
extra = []
if "std_heap_libc_LibcArena64" in s and "heap_libc_Arena64" in s and "#define heap_libc_Arena64" not in s:
    extra.append("#define heap_libc_Arena64 std_heap_libc_LibcArena64\n")
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

# 2) string.x bare (fast-path names)
SHUX_KEEP_C=1 "$SHUX" -L "$ROOT" -lib-name "" -o "$tmp/sx.o" "$ROOT/std/string/string.x" >"$tmp/sx.log" 2>&1 || true
if [ ! -f "$tmp/sx.o" ]; then
  # fallback: compile string.x -E if -o failed but maybe small enough
  if "$SHUX" -x -E -lib-name "" -L "$ROOT" "$ROOT/std/string/string.x" >"$tmp/sx.c" 2>"$tmp/sx.err"; then
    # trim incomplete tail if needed
    if ! tail -c 1 "$tmp/sx.c" | grep -q '}'; then
      python3 - "$tmp/sx.c" <<'PY'
import sys
from pathlib import Path
s = Path(sys.argv[1]).read_text()
depth = last = 0
for i,c in enumerate(s):
    if c=='{': depth+=1
    elif c=='}':
        depth-=1
        if depth==0: last=i
if last>0:
    Path(sys.argv[1]).write_text(s[:last+1]+"\n")
PY
    fi
    cc $CFLAGS -c "$tmp/sx.c" -o "$tmp/sx.o"
  else
    echo "shux_compile_std_string_o: string.x failed" >&2
    cat "$tmp/sx.log" "$tmp/sx.err" 2>/dev/null >&2
    exit 1
  fi
fi

ld -r -o "$OUT" "$tmp/mod.o" "$tmp/sx.o"
echo "shux_compile_std_string_o: OK -> $OUT"
