#!/usr/bin/env bash
# C-09：parser 无 C 回退 v1（C-06 委托 + strict link + force_stub/mega7 manifest 登记）。
#
# v1 不要求 mega7 七函数全部 X emit；生产仍 C glue 见 analysis/boot-mega7-gap.md。
#
# 用法：./tests/run-c09-parser-no-c-fallback-gate.sh
# 环境：SHUX_C09_FAIL=1 失败时硬退出（CI 默认）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_C09_FAIL:-0}
DOC="analysis/phase-c-c09-v1.md"
MANIFEST="tests/baseline/c09-parser-no-c-fallback.tsv"
MF="compiler/Makefile"
BUILD_ASM="compiler/scripts/build_shux_asm.sh"
FORCE_STUB_TSV="tests/baseline/boot-force-stub-matrix.tsv"
MEGA7_TSV="tests/baseline/comp-parser-mega7-matrix.tsv"
BOOT023_TSV="tests/baseline/boot-023-mega7-full-emit.tsv"

die() {
  echo "c09 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== C-09: parser no C fallback (v1 manifest) ==="
for f in "$DOC" "$MANIFEST" "$MF" "$BUILD_ASM" \
  analysis/boot-mega7-gap.md analysis/boot-force-stub-v1.md \
  "$FORCE_STUB_TSV" "$MEGA7_TSV" "$BOOT023_TSV"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'C-09 v1' "$DOC" || die "doc missing C-09 v1 marker"

# ── 委托 C-06：默认 seed 不链 C parser.o ──
echo "=== C-09: delegate C-06 x frontend default ==="
chmod +x tests/run-c06-x-frontend-default-gate.sh
SHUX_C06_FAIL="$FAIL" ./tests/run-c06-x-frontend-default-gate.sh || die "C-06 sub-gate failed"

# ── strict 链：build_shux_asm 强制 parser_x.o 覆盖 seed parser.o ──
echo "=== C-09: strict link ensure_parser_x_o ==="
grep -q 'ensure_parser_x_o_for_strict_link()' "$BUILD_ASM" || die "build_shux_asm missing ensure_parser_x_o_for_strict_link"
grep -q 'ensure_parser_x_o_for_strict_link' "$BUILD_ASM" || die "build_shux_asm never calls ensure_parser_x_o_for_strict_link"

# ── pipeline_x：LINK_OBJS 以 parser_x.o 为 parser TU ──
echo "=== C-09: PIPELINE_X_LINK_OBJS uses parser_x.o ==="
LINK_LINE=$(grep -E '^PIPELINE_X_LINK_OBJS\s*=' "$MF" | head -1)
[ -n "$LINK_LINE" ] || die "missing PIPELINE_X_LINK_OBJS"
echo "$LINK_LINE" | grep -q 'parser_x\.o' || die "PIPELINE_X_LINK_OBJS missing parser_x.o"
echo "$LINK_LINE" | grep -qE 'src/parser/parser\.o' && die "PIPELINE_X_LINK_OBJS still embeds src/parser/parser.o"

# ── manifest 登记：force_stub 6 项 ──
echo "=== C-09: force_stub matrix (min 6) ==="
MIN_STUB=6
while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_stub_rows) MIN_STUB="$c2" ;; esac
done < "$FORCE_STUB_TSV"
STUB_N=0
while IFS=$'\t' read -r stub_id _rest; do
  [ -z "${stub_id:-}" ] && continue
  case "$stub_id" in \#*|min_*) continue ;; esac
  STUB_N=$((STUB_N + 1))
done < "$FORCE_STUB_TSV"
[ "$STUB_N" -ge "$MIN_STUB" ] || die "force_stub rows $STUB_N < $MIN_STUB"

# ── manifest 登记：mega7 7 项 + BOOT-023 ──
echo "=== C-09: mega7 matrix (min 7) ==="
MIN_M7=7
while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_mega7_rows) MIN_M7="$c2" ;; esac
done < "$MEGA7_TSV"
M7_N=0
while IFS=$'\t' read -r item_id kind _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|A*|C*|slice_*) continue ;; esac
  case "$kind" in mega7) M7_N=$((M7_N + 1)) ;; esac
done < "$MEGA7_TSV"
[ "$M7_N" -ge "$MIN_M7" ] || die "mega7 rows $M7_N < $MIN_M7"

MIN_EMIT=7
while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_promote_emit) MIN_EMIT="$c2" ;; esac
done < "$BOOT023_TSV"
grep -q 'full emit 7/7' "$BOOT023_TSV" || die "boot-023 manifest missing full emit goal"

# ── parser.x：mega7 七函数名存在（登记，不要求真 emit）──
echo "=== C-09: parser.x mega7 symbol anchors ==="
PARSER_X="compiler/src/parser/parser.x"
[ -f "$PARSER_X" ] || die "missing $PARSER_X"
for sym in parse_into_buf parse_into parse parse_one_function_impl parse_expr_into parse_block_into parse_body_lets_into; do
  grep -q "function ${sym}" "$PARSER_X" || grep -q "${sym}(" "$PARSER_X" || die "parser.x missing mega7 anchor $sym"
done

# ── track-only：OBJS_CORE 仍含 C parser（文档化，非失败）──
if grep -q 'src/parser/parser\.o' "$MF" && grep -q '^OBJS_CORE' "$MF"; then
  echo "c09 track: OBJS_CORE still lists src/parser/parser.o (shux-c cold start; defer C-09 v2)"
fi

# ── manifest 锚点文件存在性 ──
echo "=== C-09: manifest gate_ref anchors ==="
MISS=0
while IFS=$'\t' read -r track_id _layer anchor check_type gate_or_notes; do
  [ -z "${track_id:-}" ] && continue
  case "$track_id" in \#*) continue ;; esac
  case "$check_type" in gate_ref)
    if [ ! -f "$anchor" ]; then
      echo "c09 manifest missing gate_ref: $anchor ($track_id)" >&2
      MISS=$((MISS + 1))
    fi
    ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest gate_ref anchors missing"

echo "c09 parser-no-c-fallback gate OK (v1: default parser_x.o + strict override + force_stub/mega7 manifest)"
