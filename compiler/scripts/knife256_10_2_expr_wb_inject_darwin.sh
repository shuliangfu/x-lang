#!/bin/bash
# 256/10.2 Darwin: p9a lex bridge + opaque memcpy writeback ptr faces into thin glue.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
R="${XLANG_RESTORED:-$ROOT/xlang.restored_1952}"
OC="${LLVM_OBJCOPY:-/opt/homebrew/opt/llvm/bin/llvm-objcopy}"
P9A="$ROOT/build_asm/selfhost_pabi/p9a_lex_bridge.o"
[ -x "$R" ] && [ -x "$OC" ] && [ -f parser_asm_thin_glue.o ] && [ -f "$P9A" ]

ST=$(mktemp -d "${TMPDIR:-/tmp}/knife256_wb.XXXXXX")
trap 'rm -rf "$ST"' EXIT

"$R" -backend asm -c src/asm/knife256/lex_wb_primary_ptr.x -o "$ST/lex_wb_ptr.o"
"$R" -backend asm -c src/asm/knife256/lex_wb_cast_ptr.x -o "$ST/lex_wb_cast.o"
"$R" -backend asm -c src/asm/knife256/lex_wb_logor_ptr.x -o "$ST/lex_wb_logor.o"

mkdir -p "$ST/g" && (
  cd "$ST/g"
  ar x "$ROOT/parser_asm_thin_glue.o"
  rm -f __.SYMDEF
  {
    nm -gU "$P9A" | awk '/ [TDB] /{print $3}'
    nm -gU "$ST"/lex_wb_*.o | awk '/ [TDB] /{print $3}'
  } | sort -u > "$ST/syms.txt"
  ren=0
  for m in g05_*; do
    [ -f "$m" ] || continue
    file "$m" | grep -q Mach-O || continue
    while read -r s; do
      if nm -gU "$m" 2>/dev/null | awk '{print $3}' | grep -qxF "$s"; then
        "$OC" --redefine-sym "${s}=${s}_OLD" "$m" 2>/dev/null && ren=$((ren+1)) || true
      fi
    done < "$ST/syms.txt"
  done
  echo "knife256 wb inject: renames=$ren" >&2
  MEMS=()
  for m in g05_*; do
    [ -f "$m" ] || continue
    file "$m" | grep -q Mach-O && MEMS+=("$m")
  done
  ar rcs "$ST/glue_new.a" "$P9A" "$ST"/lex_wb_*.o "${MEMS[@]}"
)
cp "$ST/glue_new.a" "$ROOT/parser_asm_thin_glue.o"
echo "knife256 wb inject: OK" >&2
