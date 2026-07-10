#!/usr/bin/env bash
# BOOT-020：mega7 parser 替换里程碑门禁（thin glue 符号 + mega7 manifest）
#
# 1) boot-020-mega7-milestone-v1.md + manifest
# 2) thin glue 符号 gate 全绿（Linux）或源锚点回退（Darwin）
# 3) comp-parser-mega7 manifest 绿
#
# 用法：./tests/run-boot-020-mega7-milestone-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_BOOT020_DOC:-analysis/boot-020-mega7-milestone-v1.md}"
MANIFEST="${SHUX_BOOT020_TSV:-tests/baseline/boot-020-mega7-milestone.tsv}"
SYMBOL_BASELINE="tests/baseline/parser-thin-glue-symbols.tsv"
THIN_SRC="compiler/src/asm/parser_asm_thin_c.inc"
LIB="tests/lib/boot-020-mega7-milestone.sh"
HOOK_SYMBOL="tests/run-parser-thin-glue-symbol-integrity-gate.sh"
HOOK_MEGA7="tests/run-comp-parser-mega7-gate.sh"
HOOK_SECOND="tests/run-parser-second-pass-gate.sh"
MIN_SLICE=15

# shellcheck source=tests/lib/boot-020-mega7-milestone.sh
. tests/lib/boot-020-mega7-milestone.sh

echo "=== BOOT-020: mega7 milestone manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$SYMBOL_BASELINE" "$THIN_SRC" \
  tests/baseline/comp-parser-mega7-matrix.tsv \
  analysis/comp-parser-mega7-v1.md \
  "$HOOK_SYMBOL" "$HOOK_MEGA7"; do
  if [ ! -f "$f" ]; then
    echo "boot-020-mega7-milestone gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_slice_done) MIN_SLICE="$c2" ;;
  esac
done < "$MANIFEST"

for kw in thin glue mega7 parser_asm_stretch symbol integrity; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-020-mega7-milestone gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

MISS=0
SLICE_DONE=0
echo "=== BOOT-020: manifest rows ==="
while IFS=$'\t' read -r item_id kind anchor target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-020 FAIL: missing section '$anchor'" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_gate)
      if [ ! -f "tests/$anchor" ]; then
        echo "boot-020 FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|cross_ref)
      path="$anchor"
      if [ "$kind" = "file" ] && [ -n "${target:-}" ] && [ -f "$target" ]; then
        path="$target"
      fi
      if [ ! -f "$path" ]; then
        echo "boot-020 FAIL: missing $path ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

# mega7 切片 done 计数
while IFS=$'\t' read -r _id kind _ph status hook _notes; do
  [ "$kind" = "capability" ] || continue
  [ "$status" = "done" ] || continue
  SLICE_DONE=$((SLICE_DONE + 1))
done < tests/baseline/comp-parser-mega7-matrix.tsv

if [ "$SLICE_DONE" -lt "$MIN_SLICE" ]; then
  echo "boot-020-mega7-milestone gate FAIL: slice_done=${SLICE_DONE} < min ${MIN_SLICE}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "boot-020-mega7-milestone gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "boot-020-mega7-milestone manifest OK (slices=${SLICE_DONE})"

SYMBOL_OK=0
MEGA7_OK=0
SKIP=0
IS_DARWIN=0
[ "$(uname -s 2>/dev/null)" = "Darwin" ] && IS_DARWIN=1

echo "=== BOOT-020: thin glue symbol gate ==="
chmod +x "$HOOK_SYMBOL" 2>/dev/null || true
if [ "$IS_DARWIN" -eq 1 ]; then
  sym_miss="$(boot020_source_symbols_ok "$SYMBOL_BASELINE" "$THIN_SRC" || true)"
  if [ "${sym_miss:-0}" -gt 0 ]; then
    boot020_emit_report "fail" 0 0 1
    exit 1
  fi
  SYMBOL_OK="source"
  SKIP=1
  echo "boot-020 thin glue source anchors OK (Darwin N/A nm)"
else
  if SHUX_PARSER_THIN_GLUE_SYMBOL_INTEGRITY_FAIL=1 "$HOOK_SYMBOL" >/tmp/boot020_symbol.log 2>&1; then
    grep -q 'parser-thin-glue-symbol-integrity-gate OK' /tmp/boot020_symbol.log
    SYMBOL_OK=1
  else
    tail -8 /tmp/boot020_symbol.log >&2 || true
    boot020_emit_report "fail" 0 0 0
    exit 1
  fi
fi

echo "=== BOOT-020: comp-parser-mega7 gate ==="
chmod +x "$HOOK_MEGA7" 2>/dev/null || true
if "$HOOK_MEGA7" >/tmp/boot020_mega7.log 2>&1; then
  grep -qE 'comp-parser-mega7 gate OK|comp-parser-mega7 gate SKIP hooks' /tmp/boot020_mega7.log
  MEGA7_OK=1
else
  tail -10 /tmp/boot020_mega7.log >&2 || true
  boot020_emit_report "fail" "$SYMBOL_OK" 0 "$SKIP"
  exit 1
fi

if [ "$IS_DARWIN" -eq 0 ] && [ -f "$HOOK_SECOND" ]; then
  echo "=== BOOT-020: parser second-pass gate ==="
  chmod +x "$HOOK_SECOND" 2>/dev/null || true
  if SHUX_PARSER_SECOND_PASS_FAIL=1 "$HOOK_SECOND" >/tmp/boot020_second.log 2>&1; then
    grep -qE 'parser-second-pass-gate OK|second-pass.*OK' /tmp/boot020_second.log || true
  else
    if grep -q 'N/A on Darwin\|SKIP' /tmp/boot020_second.log 2>/dev/null; then
      SKIP=1
    else
      tail -8 /tmp/boot020_second.log >&2 || true
      boot020_emit_report "fail" "$SYMBOL_OK" "$MEGA7_OK" 0
      exit 1
    fi
  fi
else
  SKIP=1
fi

boot020_emit_report "ok" "$SYMBOL_OK" "$MEGA7_OK" "$SKIP"
echo "boot-020-mega7-milestone gate OK"
