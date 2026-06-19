#!/usr/bin/env bash
# BOOT-018：mega7 parser 与 std 迭代解耦 manifest 门禁
#
# 1) boot-018-parser-std-decouple-v1.md 双轨策略
# 2) mega7 B1-B7 保持 stub（不阻塞 STD P0）
# 3) portable-suite COMP-001 可 SKIP；eng-quality 无 mega7 ci_hard
#
# 用法：./tests/run-boot-018-parser-std-decouple-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_BOOT018_DOC:-analysis/boot-018-parser-std-decouple-v1.md}"
MANIFEST="${SHUX_BOOT018_TSV:-tests/baseline/boot-018-parser-std-decouple.tsv}"
MEGA_MATRIX="tests/baseline/comp-parser-mega7-matrix.tsv"
ENG_MATRIX="tests/baseline/eng-quality-gate-matrix.tsv"
PORTABLE="tests/run-portable-suite.sh"
STD_GATE="tests/run-stdlib-check-matrix-gate.sh"
LIB="tests/lib/boot-018-parser-std-decouple.sh"
MIN_STUB=7

# shellcheck source=tests/lib/boot-018-parser-std-decouple.sh
. tests/lib/boot-018-parser-std-decouple.sh

echo "=== BOOT-018: parser/std decouple manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MEGA_MATRIX" "$ENG_MATRIX" "$PORTABLE" "$STD_GATE" NEXT.md; do
  if [ ! -f "$f" ]; then
    echo "boot-018-parser-std-decouple gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_mega7_stub) MIN_STUB="$c2" ;;
  esac
done < "$MANIFEST"

for kw in STD P0 双轨 stub 不阻塞; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-018-parser-std-decouple gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

MISS=0
echo "=== BOOT-018: sections and cross-refs ==="
while IFS=$'\t' read -r item_id kind anchor target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-018 FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref|file)
      if [ ! -f "$anchor" ]; then
        echo "boot-018 FAIL: missing $anchor ($item_id)" >&2
        MISS=$((MISS + 1))
      elif [ "$kind" = "cross_ref" ] && [ "$anchor" != "$MANIFEST" ]; then
        if ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
          echo "boot-018 FAIL: doc missing xref $(basename "$anchor")" >&2
          MISS=$((MISS + 1))
        fi
      fi
      ;;
    std_gate|parser_gate)
      if ! boot018_std_gate_exists "$anchor" && [ ! -f "$anchor" ]; then
        echo "boot-018 FAIL: missing gate $anchor ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    forbidden)
      if ! grep -qF "$anchor" NEXT.md 2>/dev/null; then
        echo "boot-018 FAIL: NEXT.md missing policy '$anchor'" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$MISS" -gt 0 ]; then
  echo "boot-018-parser-std-decouple gate FAIL: missing=${MISS}" >&2
  exit 1
fi

STUB_N="$(boot018_mega7_stub_count "$MEGA_MATRIX")"
if [ "$STUB_N" -lt "$MIN_STUB" ]; then
  echo "boot-018-parser-std-decouple gate FAIL: mega7_stub=${STUB_N} < min ${MIN_STUB}" >&2
  exit 1
fi
echo "boot-018 mega7 stub OK (${STUB_N}/7)"

STD_IND=0
PARSER_PORT=0
if boot018_std_gate_exists "$STD_GATE"; then
  STD_IND=1
fi
if boot018_portable_allows_skip "$PORTABLE" && boot018_eng_parser_not_hard "$ENG_MATRIX"; then
  PARSER_PORT=1
fi

if [ "$STD_IND" -ne 1 ] || [ "$PARSER_PORT" -ne 1 ]; then
  boot018_emit_report "fail" "$STUB_N" "$STD_IND" "$PARSER_PORT"
  exit 1
fi

# boot-mega7-gap 须含解耦节
if ! grep -qF '## 7.' analysis/boot-mega7-gap.md 2>/dev/null; then
  echo "boot-018-parser-std-decouple gate FAIL: boot-mega7-gap.md missing §7 decouple" >&2
  exit 1
fi

boot018_emit_report "ok" "$STUB_N" "$STD_IND" "$PARSER_PORT"
echo "boot-018-parser-std-decouple manifest OK"
echo "boot-018-parser-std-decouple gate OK"
